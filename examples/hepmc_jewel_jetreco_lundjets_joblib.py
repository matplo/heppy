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

import hepmc2wrap
import ROOT
import math

import joblib

from fjutils import lundjet

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


def find_files(rootdir, pattern):
	return [os.path.join(rootdir, filename)
			for rootdir, dirnames, filenames in os.walk(rootdir)
			for filename in filenames
			if fnmatch.fnmatch(filename, pattern)]


def main():
	parser = argparse.ArgumentParser(description='read jewel to lund jets object and pickle with joblib', prog=os.path.basename(__file__))
	parser.add_argument('-d', '--dir', help='input directory', default='', type=str, required=True)
	parser.add_argument('-n', '--nfiles', help='number of files', default=-1, type=int, required=False)
	parser.add_argument('-p', '--pattern', help='input directory', default='', type=str, required=True)
	parser.add_argument('--nev', help='number of events', default=-1, type=int)
	args = parser.parse_args()	

	files = find_files(args.dir, args.pattern)

	# jet finder
	# print the banner first
	fj.ClusterSequence.print_banner()
	print()
	jet_R0 = 0.4
	jet_def = fj.JetDefinition(fj.antikt_algorithm, jet_R0)
	jet_selector = fj.SelectorPtMin(40.0) & fj.SelectorPtMax(500.0) & fj.SelectorAbsEtaMax(2)

	jet_def_lund = fj.JetDefinition(fj.cambridge_algorithm, 1.0)
	lund_gen = fjcontrib.LundGenerator(jet_def_lund)

	sd = fjcontrib.SoftDrop(0, 0.1, 1.0)

	if args.nfiles > 0:
		rfiles = files[:args.nfiles]
	else:
		rfiles = files
	print("[i] found {} files - running for {} files".format(len(files), len(rfiles)))
	for ifile, fn in enumerate(tqdm.tqdm(rfiles)):
		# now lets read the HEPMC file and do some jet finding
		input_hepmc = hepmc2wrap.ReadHepMCFile(fn)
		if input_hepmc.failed():
			print ("[error] unable to read from {}".format(fn))
			sys.exit(1)

		all_jets = []
		pbar = tqdm.tqdm(range(args.nev))
		while not input_hepmc.failed():
			if input_hepmc.NextEvent():
				jets_hepmc = find_jets_hepmc(jet_def, jet_selector, input_hepmc, final=True)
				all_jets.extend(jets_hepmc)
				pbar.update()
			if pbar.n >= args.nev:
				pbar.close()
				break				

		lunds = [lund_gen.result(j) for j in all_jets]
		lunds_pickle = [lundjet.LundJet(j, lund_gen.result(j)) for j in all_jets]

		all_jets_sd = [sd.result(j) for j in all_jets]
		lunds_sd = [lund_gen.result(j) for j in all_jets_sd]
		lunds_sd_pickle = [lundjet.LundJet(j, lund_gen.result(j)) for j in all_jets_sd]

		joblib_file = 'lund_{}.joblib'.format(ifile)
		joblib.dump(lunds_pickle, joblib_file)
		joblib_file_sd = 'lund_sd_{}.joblib'.format(ifile)
		joblib.dump(lunds_sd_pickle, joblib_file_sd)


if __name__ == '__main__':
	main()
