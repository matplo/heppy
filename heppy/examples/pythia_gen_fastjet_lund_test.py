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
	if args.nev < 100:
		args.nev = 100
	for i in tqdm.tqdm(range(args.nev)):
		if not pythia.next():
			continue
		parts = pythiafjext.vectorize(pythia, True, -1, 1, False)
		jets = jet_selector(jet_def(parts))
		all_jets.extend(jets)

	pythia.stat()

	jet_def_lund = fj.JetDefinition(fj.cambridge_algorithm, 1.0)
	lund_gen = fjcontrib.LundGenerator(jet_def_lund)

	print('making lund diagram for all jets...', lund_gen.description())
	lunds = [lund_gen.result(j) for j in all_jets]

	print('listing lund plane points... Delta, kt - for {} selected jets'.format(len(all_jets)))
	for l in lunds:
		print ('- jet pT={0:5.2f} eta={1:5.2f}'.format(l[0].pair().perp(), l[0].pair().eta()))
		print ('  Deltas={}'.format([s.Delta() for s in l]))
		print ('  kts={}'.format([s.kt() for s in l]))
		print ( )

	dy_groomer = fjcontrib.DynamicalGroomer(jet_def_lund)
	print (dy_groomer.description())
	dy_groomed = [dy_groomer.result(j, 2) for j in all_jets]
	print('listing results from dynamical grooming...')
	for l in dy_groomed:
		print (l, '  kt={}'.format(l.kt()))

	for j in all_jets:
		rdyng2 = dy_groomer.result(j, 2)
		rdyng1 = dy_groomer.result(j, 1)
		print('jet', j)
		print('- all splits kts:', sorted([s.kt() for s in dy_groomer.lund_splits()], reverse=True))
		print('- dynG kt a=1:', rdyng1.kt(), 'a=2:', rdyng2.kt())
		print()

	return
	print('[i] reclustering and using soft drop...')
	jet_def_rc = fj.JetDefinition(fj.cambridge_algorithm, 0.1)
	print('Reclustering:', jet_def_rc)

	rc = fjcontrib.Recluster(jet_def_rc, True)
	sd = fjcontrib.SoftDrop(0, 0.1, 1.0)
	for i,j in enumerate(all_jets):
		j_rc = rc.result(j)
		print()
		print('- [{0:3d}] orig pT={1:10.3f} reclustered pT={2:10.3f}'.format(i, j.perp(), j_rc.perp()))
		j_sd = sd.result(j)
		print('  |-> after soft drop pT={0:10.3f} delta={1:10.3f}'.format(j_sd.perp(), j_sd.perp() - j.perp()))
		sd_info = fjcontrib.get_SD_jet_info(j_sd)
		print("  |-> SD jet params z={0:10.3f} dR={1:10.3f} mu={2:10.3f}".format(sd_info.z, sd_info.dR, sd_info.mu))

if __name__ == '__main__':
	main()
