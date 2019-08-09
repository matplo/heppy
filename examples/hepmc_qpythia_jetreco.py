#!/usr/bin/env python

from __future__ import print_function

import fastjet as fj
import fjcontrib
import fjext

import tqdm
import argparse
import os
import sys
import numpy as np
import array 

import hepmc2wrap
import ROOT
import math

def logbins(xmin, xmax, nbins):
        lspace = np.logspace(np.log10(xmin), np.log10(xmax), nbins+1)
        arr = array.array('f', lspace)
        return arr


def find_jets_hepmc(jet_def, jet_selector, hepmc_reader, final=True):
	fjparts = []
	for i, part in enumerate(hepmc_reader.HepMCParticles(final)):
		psj = fj.PseudoJet(part.momentum().px(), part.momentum().py(), part.momentum().pz(), part.momentum().e())
		# psj.set_user_index(i)
		fjparts.append(psj)
	jets = jet_selector(jet_def(fjparts))
	return jets


def main():
	parser = argparse.ArgumentParser(description='pythia8 in python', prog=os.path.basename(__file__))
	parser.add_argument('-i', '--input', help='input file', default='low', type=str, required=True)
	parser.add_argument('--nev', help='number of events', default=-1, type=int)
	args = parser.parse_args()	

	if args.nev <= 0:
		args.nev = hepmc2wrap.statfile(args.input)
                print("[i] found {} events in {}".format(args.nev, args.input))
	###
	# now lets read the HEPMC file and do some jet finding
	input_hepmc = hepmc2wrap.ReadHepMCFile(args.input)

	if input_hepmc.failed():
		print ("[error] unable to read from {}".format(args.input))
		sys.exit(1)

	# jet finder
	# print the banner first
	fj.ClusterSequence.print_banner()
	print()
	jet_R0 = 0.4
	jet_def = fj.JetDefinition(fj.antikt_algorithm, jet_R0)
	jet_selector = fj.SelectorPtMin(10.0) & fj.SelectorPtMax(500.0) & fj.SelectorAbsEtaMax(3)

	all_jets = []
	pbar = tqdm.tqdm(range(args.nev))
	while not input_hepmc.failed():
		if input_hepmc.NextEvent():
			jets_hepmc = find_jets_hepmc(jet_def, jet_selector, input_hepmc, final=True)
			all_jets.extend(jets_hepmc)
			pbar.update()
		if pbar.n >= args.nev:
			break

	jet_def_lund = fj.JetDefinition(fj.cambridge_algorithm, 1.0)
	lund_gen = fjcontrib.LundGenerator(jet_def_lund)

	print('[i] making lund diagram for all jets...')
	lunds = [lund_gen.result(j) for j in all_jets]

	print('[i] listing lund plane points... Delta, kt - for {} selected jets'.format(len(all_jets)))
	for l in lunds:
		if len(l) < 1:
			continue
		print ('- jet pT={0:5.2f} eta={1:5.2f}'.format(l[0].pair().perp(), l[0].pair().eta()))
		print ('  Deltas={}'.format([s.Delta() for s in l]))
		print ('  kts={}'.format([s.kt() for s in l]))
		print ( )

	print('[i] reclustering and using soft drop...')
	jet_def_rc = fj.JetDefinition(fj.cambridge_algorithm, 0.1)
	print('[i] Reclustering:', jet_def_rc)

	all_jets_sd = []
	rc = fjcontrib.Recluster(jet_def_rc, True)
	sd = fjcontrib.SoftDrop(0, 0.1, 1.0)
	for i,j in enumerate(all_jets):
		j_rc = rc.result(j)
		print()
		print('- [{0:3d}] orig pT={1:10.3f} reclustered pT={2:10.3f}'.format(i, j.perp(), j_rc.perp()))
		j_sd = sd.result(j)
		print('  |-> after soft drop pT={0:10.3f} delta={1:10.3f}'.format(j_sd.perp(), j_sd.perp() - j.perp()))
		all_jets_sd.append(j_sd)
		sd_info = fjcontrib.get_SD_jet_info(j_sd)
		print("  |-> SD jet params z={0:10.3f} dR={1:10.3f} mu={2:10.3f}".format(sd_info.z, sd_info.dR, sd_info.mu))

	fout = ROOT.TFile('hepmc_jetreco.root', 'recreate')
	lbins = logbins(1., 500, 50)
	hJetPt04 = ROOT.TH1D("hJetPt04", "hJetPt04", 50, lbins)
	hJetPt04sd = ROOT.TH1D("hJetPt04sd", "hJetPt04sd", 50, lbins)
	[hJetPt04.Fill(j.perp()) for j in all_jets]
	[hJetPt04sd.Fill(j.perp()) for j in all_jets_sd]
	hLund = ROOT.TH2D("hLund", "hLund", 60, 0, 6, 100, -4, 5)
	lunds = [lund_gen.result(j) for j in all_jets if j.perp() > 100]
	j100 = [j for j in all_jets if j.perp() > 100]
	print('{} jets above 100 GeV/c'.format(len(j100)))
	for l in lunds:
		for s in l:
			hLund.Fill(math.log(1./s.Delta()), math.log(s.kt()))
	fout.Write()

if __name__ == '__main__':
	main()
