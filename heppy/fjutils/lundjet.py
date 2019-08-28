import numpy as np
import pandas as pd

class LundJet(object):
	def __init__(self, jet, lunds):
		self.momentum = [jet.px(), jet.py(), jet.pz(), jet.e()]
		self.ptetaphi = [jet.perp(), jet.eta(), jet.phi()]
		if len(lunds) < 1:
			self.delta = []
			self.kt = []
			self.m = []
			self.z = []
			self.kappa = []
			self.psi = []
		else:
			self.delta = [s.Delta() for s in lunds]
			self.kt = [s.kt() for s in lunds]
			self.m = [s.m() for s in lunds]
			self.z = [s.z() for s in lunds]
			self.kappa = [s.kappa() for s in lunds]
			self.psi = [s.psi() for s in lunds]

	def getDataFrame(self, maxsplits=None, number=0):
		nsplits = maxsplits
		if nsplits is None:
			nsplits = len(self.delta)
		nda = np.zeros((nsplits, 14))
		for i in range(0, nsplits):
			nda[i][0] = number
			for j in range(4):
				nda[i][1+j] = self.momentum[j]
				for j in range(3):
					nda[i][1+4+j] = self.ptetaphi[j]
			if i < len(self.delta):
				nda[i][1+4+3] = self.delta[i]
				nda[i][1+4+4] = self.kt[i]
				nda[i][1+4+5] = self.m[i]
				nda[i][1+4+6] = self.z[i]
				nda[i][1+4+7] = self.kappa[i]
				nda[i][1+4+8] = self.psi[i]
		retpd = pd.DataFrame(data=nda, columns=self.getDataFrameDescription())
		return retpd

	def getNumpyArray(self, number=0):
		nsplits = len(self.delta)
		nda = np.zeros((nsplits, 14))
		for i in range(0, len(self.delta)):
			nda[i][0] = number
			for j in range(4):
				nda[i][1+j] = self.momentum[j]
				for j in range(3):
					nda[i][1+4+j] = self.ptetaphi[j]
			if i < len(self.delta):
				nda[i][1+4+3] = self.delta[i]
				nda[i][1+4+4] = self.kt[i]
				nda[i][1+4+5] = self.m[i]
				nda[i][1+4+6] = self.z[i]
				nda[i][1+4+7] = self.kappa[i]
				nda[i][1+4+8] = self.psi[i]
		return nda

	def getDataFrame(self, number=0):
		retpd = pd.DataFrame(data=self.getNumpyArray(number), columns=self.getDataFrameDescription())
		return retpd

	@staticmethod
	def getDataFrameDescription():
		return ['n', 'px', 'py', 'pz', 'e', 'pt', 'eta', 'phi', 'delta', 'kt', 'm', 'z', 'kappa', 'psi']

def get_max_number_of_splits(ljets):
	dlength = np.array([len(j.delta) for j in ljets])
	return np.amax(dlength)

def get_pandas(ljets):
	maxsplits = get_max_number_of_splits(ljets)
	pds = pd.DataFrame(columns=LundJet.getDataFrameDescription())
	for i,j in enumerate(ljets):
		_d = j.getDataFrame(number=i)
		pds = pds.append(_d, ignore_index=True)
	return pds
