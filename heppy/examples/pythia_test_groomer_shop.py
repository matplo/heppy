#!/usr/bin/env python

from __future__ import print_function

import fastjet as fj
import fjcontrib
import fjext

import tqdm
import argparse
import os
import numpy as np

from heppy.pythiautils import configuration as pyconf
import pythia8
import pythiafjext
import pythiaext

def main():
	parser = argparse.ArgumentParser(description='pythia8 fastjet on the fly', prog=os.path.basename(__file__))
	pyconf.add_standard_pythia_args(parser)
	parser.add_argument('--ignore-mycfg', help="ignore some settings hardcoded here", default=False, action='store_true')

	args = parser.parse_args()

	# print the banner first
	fj.ClusterSequence.print_banner()
	print()
	# set up our jet definition and a jet selector
	jet_R0 = 0.4
	jet_def = fj.JetDefinition(fj.antikt_algorithm, jet_R0)
	jet_selector = fj.SelectorPtMin(100.0) & fj.SelectorAbsEtaMax(1)
	print(jet_def)

	all_jets = []

	mycfg = ['PhaseSpace:pThatMin = 100']
	if args.ignore_mycfg:
		mycfg = []
	pythia = pyconf.create_and_init_pythia_from_args(args, mycfg)
	if not pythia:
		print("[e] pythia initialization failed.")
		return
	if args.nev < 10:
		args.nev = 10
	for i in tqdm.tqdm(range(args.nev)):
		if not pythia.next():
			continue
		attach_pythia_particle_info = True
		parts = pythiafjext.vectorize_select(pythia, [pythiafjext.kFinal], attach_pythia_particle_info)
		jets = jet_selector(jet_def(parts))
		for j in jets:
			gshop = fjcontrib.GroomerShop(j)
			# note these LundDeclustering objects can be streamed to a tree using RTreeStreamer
			dg01 = gshop.dynamical(0.1)
			idg01 = gshop.index(dg01)
			dg20 = gshop.dynamical(2.0)
			idg20 = gshop.index(dg20)
			max_kt = gshop.max_kt()
			imax_kt = gshop.index(max_kt)
			max_pt_softer = gshop.max_pt_softer()
			# check if the same split selected:
			# if dg01.pair() == dg20.pair():
			# or use indices
			if idg01 == idg20 and idg01 > 0:
				print('- interesting jet?:')
				print('  dg01         :', dg01.as_string(), 'index dg01:', idg01)
				print('  dg20         :', dg20.as_string(), 'index dg20:', idg20)
				print('  max_kt       :', max_kt.as_string(), 'index max_kt:', imax_kt)
				print('  max_pt_softer:', max_pt_softer.as_string())
				print('  max_kappa    :', gshop.max_kappa().as_string())
				print('  max_tf       :', gshop.max_tf().as_string())
				print('  min_tf       :', gshop.min_tf().as_string())
				print('  max_z        :', gshop.max_z().as_string())

			print('softdrop check for jet:', j)
			sd = fjcontrib.SoftDrop(0, 0.1, 1.0)
			j_sd = sd.result(j)
			#print('  |-> after soft drop pT={0:10.3f} delta={1:10.3f}'.format(j_sd.perp(), j_sd.perp() - j.perp()))
			sd_info = fjcontrib.get_SD_jet_info(j_sd)
			print("  |-> SD jet params          z={} dR={} mu={}".format(sd_info.z, sd_info.dR, sd_info.mu))
			print('  |-> GroomerShop::soft_drop', gshop.soft_drop(0, 0.1, 1.0).as_string())
			# or call with no radius param - will use max allowed
			# print('  |-> GroomerShop::soft_drop', gshop.soft_drop(0, 0.1).as_string())


	pythia.stat()

if __name__ == '__main__':
	main()
