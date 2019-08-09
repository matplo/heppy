#!/usr/bin/env python

from __future__ import print_function

import fastjet as fj
import fjcontrib
import fjext

import tqdm
import argparse
import os
import numpy as np

import pyhepmc_ng
import ROOT

# Prevent ROOT from stealing focus when plotting
ROOT.gROOT.SetBatch(True)

#--------------------------------------------------------------
def main():
  parser = argparse.ArgumentParser(description='jetscape in python', \
                                   prog=os.path.basename(__file__))
  parser.add_argument('-i', '--input', help='input file', \
                      default='low', type=str, required=True)
  parser.add_argument('--nev', help='number of events', \
                      default=1000, type=int)
  args = parser.parse_args()	

  # Use pyhepmc_ng to parse the HepMC file
  input_hepmc = pyhepmc_ng.ReaderAscii(args.input)
  if input_hepmc.failed():
    print ("[error] unable to read from {}".format(args.input))
    sys.exit(1)

  # Create a histogram with ROOT
  hJetPt04 = ROOT.TH1D("hJetPt04", "hJetPt04", 500, 0, 500)

  # jet finder
  fj.ClusterSequence.print_banner()
  print()
  jet_R0 = 0.4
  jet_def = fj.JetDefinition(fj.antikt_algorithm, jet_R0)
  jet_selector = fj.SelectorPtMin(50.0) & fj.SelectorPtMax(200.0) & fj.SelectorAbsEtaMax(3)

  # Loop through events
  all_jets = []
  event_hepmc = pyhepmc_ng.GenEvent()
  pbar = tqdm.tqdm(range(args.nev))
  while not input_hepmc.failed():
    ev = input_hepmc.read_event(event_hepmc)
    if input_hepmc.failed():
      print('End of HepMC file.')
      break
    jets_hepmc = find_jets_hepmc(jet_def, jet_selector, event_hepmc)
    all_jets.extend(jets_hepmc)
    pbar.update()

    # Fill histogram
    [fill_jet_histogram(hJetPt04, jet) for jet in all_jets]
    
    if pbar.n >= args.nev:
      print('{} event limit reached'.format(args.nev))
      break

  # Plot and save histogram
  print('Creating ROOT file...')
  c = ROOT.TCanvas('c', 'c', 600, 450)
  c.cd()
  c.SetLogy()
  hJetPt04.SetMarkerStyle(21)
  hJetPt04.Draw('E P')
  output_filename = './AnalysisResult.root'
  c.SaveAs(output_filename)
    
#--------------------------------------------------------------
def find_jets_hepmc(jet_def, jet_selector, hepmc_event):

  fjparts = []
  hadrons = []
  for vertex in hepmc_event.vertices:
    vertex_time = vertex.position.t
    if abs(vertex_time - 100) < 1e-3:
      hadrons = vertex.particles_out

  for hadron in hadrons:
    psj = fj.PseudoJet(hadron.momentum.px, hadron.momentum.py, hadron.momentum.pz, hadron.momentum.e)
    fjparts.append(psj)

  jets = jet_selector(jet_def(fjparts))
  return jets

#--------------------------------------------------------------
def fill_jet_histogram(hist, jet):
        hist.Fill(jet.perp())

#--------------------------------------------------------------
if __name__ == '__main__':
	main()
