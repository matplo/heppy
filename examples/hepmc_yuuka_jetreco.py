#!/usr/bin/env python

from __future__ import print_function

import fastjet as fj
import fjcontrib
import fjext

import tqdm
import argparse
import os
import fnmatch
import sys
import numpy as np
import array 

import hepmc3ext
import ROOT
import math


def find_files(rootdir, pattern):
    return [os.path.join(rootdir, filename)
            for rootdir, dirnames, filenames in os.walk(rootdir)
            for filename in filenames
            if fnmatch.fnmatch(filename, pattern)]


def logbins(xmin, xmax, nbins):
		lspace = np.logspace(np.log10(xmin), np.log10(xmax), nbins+1)
		arr = array.array('f', lspace)
		return arr


def find_jets_hepmc(jet_def, jet_selector, hepmc_reader, accept_status = []):
	fjparts = []
	for i, part in enumerate(hepmc_reader.HepMCParticles()):
		if part.status() not in accept_status:
			continue
		mom = part.getMomentum()
		# print(part)
		# print(mom, mom.px(), mom.py(), mom.pz(), mom.e())
		psj = fj.PseudoJet(mom.px(), mom.py(), mom.pz(), mom.e())
		# psj.set_user_index(i)
		fjparts.append(psj)
	jets = jet_selector(jet_def(fjparts))
	return jets


def main():
	parser = argparse.ArgumentParser(description='pythia8 in python', prog=os.path.basename(__file__))
	parser.add_argument('-i', '--input', help='input file', default='low', type=str, required=True)
	parser.add_argument('--nev', help='number of events', default=-1, type=int)
	parser.add_argument('--jetptcut', help='jet pt cut', default=10., type=float)	
	args = parser.parse_args()	

	files = find_files(args.input, "*.txt")
	print(files)
	print('[i] number of files found {}'.format(len(files)))

	# jet finder
	# print the banner first
	fj.ClusterSequence.print_banner()
	print()
	jet_R0 = 0.4
	jet_def = fj.JetDefinition(fj.antikt_algorithm, jet_R0)
	jet_selector = fj.SelectorPtMin(10.0) & fj.SelectorAbsEtaMax(3)

	if args.nev < 0:
		args.nev = len(files)
	if args.nev > len(files):
		args.nev = len(files)	

	print("[i] running on {}".format(files[:args.nev]))
	all_jets = []
	for fin in tqdm.tqdm(files[:args.nev]):
		input_hepmc = hepmc3ext.YuukaRead(fin)
		if input_hepmc.failed():
			print ("[error] unable to read from {}".format(fin))
			sys.exit(1)
		if input_hepmc.nextEvent():
			jets = find_jets_hepmc(jet_def, jet_selector, input_hepmc, accept_status=[62])
			all_jets.extend(jets)

	jet_def_lund = fj.JetDefinition(fj.cambridge_algorithm, 1.0)
	lund_gen = fjcontrib.LundGenerator(jet_def_lund)

	print('[i] making lund diagram for all jets...')
	lunds = [lund_gen.result(j) for j in all_jets]

	print('[i] reclustering and using soft drop...')
	jet_def_rc = fj.JetDefinition(fj.cambridge_algorithm, 0.1)
	print('[i] Reclustering:', jet_def_rc)

	all_jets_sd = []
	rc = fjcontrib.Recluster(jet_def_rc, True)
	sd = fjcontrib.SoftDrop(0, 0.1, 1.0)

	fout = ROOT.TFile('hepmc_jetreco.root', 'recreate')
	lbins = logbins(1., 500, 50)
	hJetPt04 = ROOT.TH1D("hJetPt04", "hJetPt04", 50, lbins)
	hJetPt04sd = ROOT.TH1D("hJetPt04sd", "hJetPt04sd", 50, lbins)
	[hJetPt04.Fill(j.perp()) for j in all_jets]
	[hJetPt04sd.Fill(j.perp()) for j in all_jets_sd]
	hLund = ROOT.TH2D("hLund", "hLund", 60, 0, 6, 100, -4, 5)
	lunds = [lund_gen.result(j) for j in all_jets if j.perp() > args.jetptcut]
	jsel = [j for j in all_jets if j.perp() > args.jetptcut]
	print('[i] {} jets above {} GeV/c'.format(len(jsel), args.jetptcut))
	for l in lunds:
		for s in l:
			hLund.Fill(math.log(1./s.Delta()), math.log(s.kt()))
	if len(jsel) > 0:
		hLund.Scale(1./len(jsel))
	fout.Write()

if __name__ == '__main__':
	main()
