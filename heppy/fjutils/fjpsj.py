import fastjet as fj
import copy


class PSJVector(object):

	def __init__(self, px=0, py=0, pz=0, e=0):
		self.p = [0, 0, 0, 0]
		self.p[0] = px
		self.p[1] = py
		self.p[2] = pz
		self.p[3] = e
		self.constituents = []
		self.user_index = -1
		self.unique_id = -1

	def __getitem__(self, i):
		return self.p[i]

	def __str__(self):
		return self.__repr__()

	def __repr__(self):
		_s = [' - jet with user_index={0:4d} unique_id={0:5d}'.format(self.user_index, self.unique_id)]
		_s.append('   px={0:7.2f} py={1:7.2f} pz={2:7.2f} e={3:7.2f}'.format(self.p[0], self.p[1], self.p[2], self.p[3]))
		_s.append('   n constituents={0:4d}'.format(len(self.constituents)))
		return '\n'.join(_s)

	def fjPseudoJet(self):
		jet_def = fj.JetDefinition(fj.antikt_algorithm, 1.0)
		jet_selector = fj.SelectorPtMin(0.0)
		self.constituents_psj = []
		for c in self.constituents:
			self.constituents_psj.append()
		pyfj_from_psj(constituents)
		jets = jet_selector(jet_def(self.constituents_psj))
		if len(jets) < 1 or len(jets) > 1:
			print ('[error] reclustering resulted in more that 1 jets')
		psj = jets[0]
		return psj

class Container(object):
	def __init__(self):
		pass

	@classmethod
	def __getattr__(self, name):
		self.__setattr__(name, 0)

	@classmethod
	def __setattr__(self, name, val):
		setattr(self, name, val)

	@classmethod
	def from_kwargs(cls, **kwargs):
		obj = cls()
		for (field, value) in kwargs.items():
			setattr(obj, field, value)
		return obj


def pyfj_from_psj(fjpsj, unique_id = -1):
	j = PSJVector(px=fjpsj.px(), py=fjpsj.py(), pz=fjpsj.pz(), e=fjpsj.e())
	j.user_index = fjpsj.user_index()
	j.unique_id = unique_id
	if fjpsj.has_constituents() and len(fjpsj.constituents()) > 1:
		for c in fjpsj.constituents():
			_c = pyfj_from_psj(c)
			_c.user_index = c.user_index()
			j.constituents.append(copy.deepcopy(_c))
	return j


def joblib_dump_pseudojets(jets, foutname):
	print("[i] joblib dump jets to {}".format(foutname))
	to_pickle_jets.extend([pyfj_from_psj(j) for j in jets])
	joblib.dump(to_pickle_jets, foutname)

def joblib_load_pseudojets(foutname):
	print("[i] joblib load jets to {}".format(foutname))
	jets = joblib.load(foutname)
	return psjjets

def pyfj_list(l):
	retv = []
	for vx in l:
		nvx = pyfj_from_psj(vx)
		retv.append(nvx)
	return retv
