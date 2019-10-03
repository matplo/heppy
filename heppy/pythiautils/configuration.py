import pythia8


def create_and_init_pythia(config_strings=[]):
	pythia = pythia8.Pythia()
	extra_s = ["Next:numberCount = 0", "Next:numberShowEvent = 0", "Next:numberShowInfo = 0", "Next:numberShowProcess = 0", "Stat:showProcessLevel = on"]
	config_strings.extend(extra_s)
	for s in config_strings:
		pythia.readString(s)
	if pythia.init():
		print ('[i] pythia initialized with', config_strings)
		return pythia
	return None


def add_standard_pythia_args(parser):
	parser.add_argument('--py-ecms', help='low or high sqrt(s) GeV', default='low', type=str)
	parser.add_argument('--py-ecm', help='sqrt(s) GeV', default=13000, type=float)
	parser.add_argument('--py-pthatmin', help='minimum hat{pT}', default=-1, type=float)
	parser.add_argument('--py-biaspow', help='power of the bias (hard)', default=4, type=float)
	parser.add_argument('--py-biasref', help='reference pT for the bias', default='50', type=float)
	parser.add_argument('--py-noue', help="no underlying event - equivalend to no ISR and MPIs set to off", default=False, action='store_true')
	parser.add_argument('--py-noISR', help="ISR set to off", default=False, action='store_true')
	parser.add_argument('--py-noMPI', help="MPIs set to off", default=False, action='store_true')
	parser.add_argument('--py-hardQCD', help="enable hardQCD (ON if no other process selected)", default=False, action='store_true')
	parser.add_argument('--py-hardQCDcharm', help="enable hardccbar", default=False, action='store_true')
	parser.add_argument('--py-hardQCDbeauty', help="enable hardbbbar", default=False, action='store_true')
	parser.add_argument('--py-promptPhoton', help="enable prompt photon production",  default=False, action='store_true')
	parser.add_argument('--py-hardQCDlf', help="enable hardQCD light flavor = uds + glue", default=False, action='store_true')
	parser.add_argument('--py-hardQCDgluons', help="enable hardQCD only glue outgoing", default=False, action='store_true')
	parser.add_argument('--py-hardQCDquarks', help="enable hardQCD only quarks outgoing", default=False, action='store_true')
	parser.add_argument('--py-hardQCDuds', help="enable hardQCD only uds outgoing", default=False, action='store_true')
	parser.add_argument('--py-n', '--py-nevents', '--py-nev', help='number of events', default=1, type=int)
	parser.add_argument('--py-time-seed', help = 'time based seed for pythia', default=False, action='store_true')
	parser.add_argument('--py-eic', help="generic eIC setup - needs one of the --eic-XXX", default=False, action='store_true')
	parser.add_argument('--py-eic-dis', help="DIS at eIC", default=False, action='store_true')
	parser.add_argument('--py-eic-lowQ2', help="lowQ2 at eIC", default=False, action='store_true')
	parser.add_argument('--py-eic-cgamma', help="charm-gamma at eIC", default=False, action='store_true')
	parser.add_argument('--py-eic-bgamma', help="beauty-gamma at eIC", default=False, action='store_true')
	parser.add_argument('--py-eic-qgamma', help="quark-gamma at eIC", default=False, action='store_true')
	parser.add_argument('--py-eic-test', help="a test at eIC", default=False, action='store_true')
	parser.add_argument('--py-hadronization-off', help="turn off all hadronization steps", default=False, action='store_true')
	parser.add_argument('--py-noHadron', help="turn off all hadronization steps", default=False, action='store_true')
	parser.add_argument('--pythiaopts', help='configure pythia with comma separated strings', default='', type=str)
	parser.add_argument('--py-minbias', help="minbias", default=False, action='store_true')
	parser.add_argument('--py-nsd', help="non-single diffractive", default=False, action='store_true')
	parser.add_argument('--py-inel', help="inelastic", default=False, action='store_true')
	parser.add_argument('--py-inel_d', help="inelastic diffractive", default=False, action='store_true')
	parser.add_argument('--py-diff', help="diffractive", default=False, action='store_true')
	parser.add_argument('--py-inel_nsd', help="inelastic non-single diffractive", default=False, action='store_true')
	parser.add_argument('--py-el', help="elastic", default=False, action='store_true')
	parser.add_argument('--py-nd', help="non-diffractive", default=False, action='store_true')
	# legacy support
	parser.add_argument('--nev', help='number of events', default=1, type=int)


def pythia_config_from_args(args):
	sconfig_pythia = []
	soft_phys = False
	procsel = 0
	if args.py_eic:
		_extra = [ 	"Beams:idA=11",
					"Beams:idB=2212",
					"Beams:eA=20",
					"Beams:eB=250",
					"Beams:frameType=2",
					"Init:showChangedSettings=on",
					"Main:timesAllowErrors=10000" ]
		sconfig_pythia.extend(_extra)
		if args.py_eic_dis:
			_extra_eic = [	"WeakBosonExchange:ff2ff(t:gmZ)=on",
							"PhaseSpace:Q2Min=10",
							"SpaceShower:pTmaxMatch=2",
							"PDF:lepton=off",
							"TimeShower:QEDshowerByL=off"]
			sconfig_pythia.extend(_extra_eic)
			procsel += 1
		if args.py_eic_lowQ2:
			_extra_eic = [	"HardQCD:all=on",
							"PDF:lepton2gamma=on",
							"Photon:Q2max=1.",
							"Photon:Wmin=10.",
							"PhaseSpace:pTHatMin=2.",
							"PhotonParton:all=on",
							"Photon:ProcessType=0" ]
			sconfig_pythia.extend(_extra_eic)
			procsel += 1
		if args.py_eic_cgamma:
			_extra_eic = [	"PDF:lepton2gamma=on",
							"PhotonParton:ggm2ccbar=on" ]
			sconfig_pythia.extend(_extra_eic)
			procsel += 1
		if args.py_eic_bgamma:
			_extra_eic = [	"PDF:lepton2gamma=on",
							"PhotonParton:ggm2bbbar=on" ]
			sconfig_pythia.extend(_extra_eic)
			procsel += 1
		if args.py_eic_qgamma:
			_extra_eic = [	"PDF:lepton2gamma=on",
							"PhotonParton:qgm2qgm=on" ]
			sconfig_pythia.extend(_extra_eic)
			procsel += 1
		if args.py_eic_test:
			_extra_eic = [	"WeakBosonExchange:ff2ff(t:gmZ)=on",
							"PhaseSpace:Q2Min=1",
							"SpaceShower:pTmaxMatch=2",
							"PDF:lepton=off",
							"TimeShower:QEDshowerByL=off",

							"HardQCD:all=on",
							"PDF:lepton2gamma=on",
							"Photon:Q2max=1.",
							"Photon:Wmin=10.",
							"PhaseSpace:pTHatMin=1.",
							"PhaseSpace:pTHatMax=18.",
							"PhotonParton:all=on",
							"Photon:ProcessType=0"]
			sconfig_pythia.extend(_extra_eic)
			procsel += 1

	if args.py_time_seed:
		_extra = [ 	"Random:setSeed=on",
					"Random:seed=0"]
		sconfig_pythia.extend(_extra)

	if args.py_minbias:
		sconfig_pythia.append("HardQCD:all=off")
		sconfig_pythia.append("PromptPhoton:all=off")
		sconfig_pythia.append("SoftQCD:all=on")
		procsel += 1
		soft_phys = True

	if args.py_nsd:
		sconfig_pythia.append("SoftQCD:all=off");
		sconfig_pythia.append("SoftQCD:elastic=on")  #               ! Elastic
		sconfig_pythia.append("SoftQCD:singleDiffractive=off")  #     ! Single diffractive
		sconfig_pythia.append("SoftQCD:doubleDiffractive=on")  #     ! Double diffractive
		sconfig_pythia.append("SoftQCD:centralDiffractive=on")  #    ! Central diffractive
		sconfig_pythia.append("SoftQCD:nonDiffractive=on")  #        ! Nondiffractive (inelastic)
		sconfig_pythia.append("SoftQCD:inelastic=on")  #             ! All inelastic
		procsel += 1
		soft_phys = True

	if args.py_inel:
		sconfig_pythia.append("HardQCD:all=off")
		sconfig_pythia.append("PromptPhoton:all=off")
		sconfig_pythia.append("SoftQCD:all=off");
		sconfig_pythia.append("SoftQCD:nonDiffractive=on")  #        ! Nondiffractive (inelastic)
		sconfig_pythia.append("SoftQCD:inelastic=on")  #             ! All inelastic
		procsel += 1
		soft_phys = True

	if args.py_inel_d:
		sconfig_pythia.append("HardQCD:all=off")
		sconfig_pythia.append("PromptPhoton:all=off")
		sconfig_pythia.append("SoftQCD:all=off")
		sconfig_pythia.append("SoftQCD:singleDiffractive=on")  #     ! Single diffractive
		sconfig_pythia.append("SoftQCD:doubleDiffractive=on")  #     ! Double diffractive
		sconfig_pythia.append("SoftQCD:centralDiffractive=on")  #    ! Central diffractive
		sconfig_pythia.append("SoftQCD:nonDiffractive=on")  #        ! Nondiffractive (inelastic)
		sconfig_pythia.append("SoftQCD:inelastic=on")  #             ! All inelastic
		procsel += 1
		soft_phys = True

	if args.py_diff:
		sconfig_pythia.append("HardQCD:all=off")
		sconfig_pythia.append("PromptPhoton:all=off")
		sconfig_pythia.append("SoftQCD:all=off")
		sconfig_pythia.append("SoftQCD:singleDiffractive=on")  #     ! Single diffractive
		sconfig_pythia.append("SoftQCD:doubleDiffractive=on")  #     ! Double diffractive
		sconfig_pythia.append("SoftQCD:centralDiffractive=on")  #    ! Central diffractive
		procsel += 1
		soft_phys = True

	if args.py_inel_nsd:
		sconfig_pythia.append("HardQCD:all=off")
		sconfig_pythia.append("PromptPhoton:all=off")
		sconfig_pythia.append("SoftQCD:all=off")
		sconfig_pythia.append("SoftQCD:nonDiffractive=on")  #        ! Nondiffractive (inelastic)
		sconfig_pythia.append("SoftQCD:inelastic=on")  #             ! All inelastic
		sconfig_pythia.append("SoftQCD:doubleDiffractive=on")  #     ! Double diffractive
		sconfig_pythia.append("SoftQCD:centralDiffractive=on")  #    ! Central diffractive
		procsel += 1
		soft_phys = True

	if args.py_el:
		sconfig_pythia.append("HardQCD:all=off")
		sconfig_pythia.append("PromptPhoton:all=off")
		sconfig_pythia.append("SoftQCD:all=off")
		sconfig_pythia.append("SoftQCD:elastic=on")  #             ! All inelastic
		procsel += 1
		soft_phys = True

	if args.py_nd:
		sconfig_pythia.append("HardQCD:all=off");
		sconfig_pythia.append("PromptPhoton:all=off");
		sconfig_pythia.append("SoftQCD:all=off");
		sconfig_pythia.append("SoftQCD:nonDiffractive=on")  #        ! Nondiffractive (inelastic)
		procsel += 1
		soft_phys = True

	if args.py_hardQCDlf:
		_extra = [ 	"HardQCD:all=off",
					"HardQCD:gg2gg=on",
					"HardQCD:qg2qg=on",
					"HardQCD:qqbar2gg=on",
					"HardQCD:gg2qqbar=on",
					"HardQCD:qq2qq=on",
					"HardQCD:qqbar2qqbarNew=on",
					"HardQCD:hardccbar=off",
					"HardQCD:hardbbbar=off"]
		sconfig_pythia.extend(_extra)
		procsel += 1

	if args.py_hardQCDgluons:
		_extra = [	"HardQCD:all=off",
					"HardQCD:gg2gg=on",
					# "HardQCD:qg2qg=on",
					"HardQCD:qqbar2gg=on"]
		sconfig_pythia.extend(_extra)
		procsel += 1

	if args.py_hardQCDquarks:
		_extra = [	"HardQCD:all=off",
					"HardQCD:gg2qqbar=on",
					"HardQCD:qq2qq=on",
					"HardQCD:qqbar2qqbarNew=on",
					"HardQCD:hardccbar=on",
					"HardQCD:hardbbbar=on"]
		sconfig_pythia.extend(_extra)
		procsel += 1

	if args.py_hardQCDuds:
		_extra = [	"HardQCD:all=off",
					"HardQCD:gg2qqbar=on",
					"HardQCD:qq2qq=on",
					"HardQCD:qqbar2qqbarNew=on"]
		sconfig_pythia.extend(_extra)
		procsel += 1

	if args.py_promptPhoton:
		sconfig_pythia.append("PromptPhoton:all=on")
		procsel += 1

	if args.py_hardQCDcharm:
		sconfig_pythia.append("HardQCD:hardccbar=on")
		procsel += 1

	if args.py_hardQCDbeauty:
		sconfig_pythia.append("HardQCD:hardbbbar=on")
		procsel += 1

	if args.py_hardQCD:
		sconfig_pythia.append("HardQCD:all=on")
		procsel += 1

	if procsel == 0:
		sconfig_pythia.append("HardQCD:all=on")

	if args.py_pthatmin < 0 and soft_phys == False:
		_extra = [	"PhaseSpace:bias2Selection=on",
					"PhaseSpace:bias2SelectionPow={}".format(args.py_biaspow),
					"PhaseSpace:bias2SelectionRef={}".format(args.py_biasref)]
		sconfig_pythia.extend(_extra)
	else:
		sconfig_pythia.append("PhaseSpace:pTHatMin = {}".format(args.py_pthatmin))

	if args.py_noue:
		sconfig_pythia.append("PartonLevel:ISR = off")
		sconfig_pythia.append("PartonLevel:MPI = off")

	if args.py_noISR:
		sconfig_pythia.append("PartonLevel:ISR = off")

	if args.py_noMPI:
		sconfig_pythia.append("PartonLevel:MPI = off")

	if args.py_hadronization_off:
		sconfig_pythia.append("HadronLevel:all=off")

	if args.py_noHadron:
		sconfig_pythia.append("HadronLevel:all=off")

	if args.py_ecm:
		sconfig_pythia.append("Beams:eCM = {}".format(args.py_ecm))

	if args.pythiaopts:
		_extra = [s.replace("_", " ") for s in args.pythiaopts.split(',')]
		sconfig_pythia.extend(_extra)
		procsel += 1

	print(sconfig_pythia)
	return sconfig_pythia

def create_and_init_pythia_from_args(args, user_args=[]):
	_args = []
	from_args = pythia_config_from_args(args)
	_args.extend(from_args)
	_args.extend(user_args)
	pythia = create_and_init_pythia(_args)
	return pythia
