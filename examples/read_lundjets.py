#!/usr/bin/env python

from __future__ import print_function

import tqdm
import argparse
import os

import joblib
from fjutils import lundjet as lundjet


def main():
	parser = argparse.ArgumentParser(description='read lund jets from a joblib file', prog=os.path.basename(__file__))
	parser.add_argument('-i', '--input', help='input file', default='', type=str, required=True)
	args = parser.parse_args()	

	if os.path.isfile(args.input):
		jets = joblib.load(args.input)
		print("[i] number of jets:", len(jets))
		print("[i] max number of splits:", lundjet.get_max_number_of_splits(jets))
		pds = lundjet.get_pandas(jets)
		print(pds)
	else:
		print("[e] unable to read from", args.input)

if __name__ == '__main__':
	main()
