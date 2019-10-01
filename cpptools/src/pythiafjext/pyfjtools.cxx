#include "pyfjtools.hh"
#include <cmath>

namespace pythiafjtools{

	std::vector<fastjet::PseudoJet> vectorize(const Pythia8::Pythia &pythia,
	                                          bool only_final,
	                                          double eta_min, double eta_max,
	                                          bool add_particle_info)
	{
		std::vector<fastjet::PseudoJet> v;
		for (int ip = 0; ip < pythia.event.size(); ip++)
		{
			if (pythia.event[ip].isFinal() || only_final == false)
			{
				if (pythia.event[ip].eta() > eta_min && pythia.event[ip].eta() < eta_max)
				{
					fastjet::PseudoJet psj(pythia.event[ip].px(), pythia.event[ip].py(), pythia.event[ip].pz(), pythia.event[ip].e());
					psj.set_user_index(ip);
					if (add_particle_info)
					{
						PythiaParticleInfo * _pinfo = new PythiaParticleInfo(pythia.event[ip]);
						psj.set_user_info(_pinfo);
					}
					v.push_back(psj);
				}
			}
		}
		return v;
	}

	std::vector<fastjet::PseudoJet> vectorize_select(const Pythia8::Pythia &pythia, 
													 int *sel, 
													 int nsel,
													 int user_index_offset,
													 bool add_particle_info)
	{
		std::vector<fastjet::PseudoJet> v;
		for (int ip = 0; ip < pythia.event.size(); ip++)
		{
			bool accept = true;
			for (unsigned int i = 0; i < nsel; i++)
			{
				switch(sel[i])
				{
					case kFinal: 		accept = pythia.event[ip].isFinal(); 		break;
					case kCharged: 		accept = pythia.event[ip].isCharged(); 		break;
					case kNeutral: 		accept = pythia.event[ip].isNeutral(); 		break;
					case kVisible: 		accept = pythia.event[ip].isVisible(); 		break;
					case kParton: 		accept = pythia.event[ip].isParton(); 		break;
					case kGluon: 		accept = pythia.event[ip].isGluon(); 		break;
					case kQuark: 		accept = pythia.event[ip].isQuark(); 		break;
					case kLepton: 		accept = pythia.event[ip].isLepton(); 		break;
					case kPhoton:       accept = pythia.event[ip].id() == 22; 		break;
					case kHadron: 		accept = pythia.event[ip].isHadron(); 		break;
					case kResonance: 	accept = pythia.event[ip].isResonance(); 	break;
					default:
						accept = true;
				}
				if (accept == false) 
					break;
			}
			if (accept == false) 
				continue;
			fastjet::PseudoJet psj(pythia.event[ip].px(), pythia.event[ip].py(), pythia.event[ip].pz(), pythia.event[ip].e());
			psj.set_user_index(ip + user_index_offset);
			if (add_particle_info)
			{
				PythiaParticleInfo * _pinfo = new PythiaParticleInfo(pythia.event[ip]);
				psj.set_user_info(_pinfo);
			}
			v.push_back(psj);
		}		
		return v;
	}


	// implemented in fjtools
	// double angularity(const fastjet::PseudoJet &j, double alpha, double scaleR0)
	// {
	// 	double _ang = 0;
	// 	const std::vector<fastjet::PseudoJet> &_cs = j.constituents();
	// 	for (unsigned int i = 0; i < _cs.size(); i++)
	// 	{
	// 		const fastjet::PseudoJet &_p = _cs[i];
	// 		_ang += _p.perp() * pow(_p.delta_R(j) / scaleR0 , 2. - alpha);
	// 	}
	// 	_ang /= j.perp();
	// 	return _ang;
	// }

	PythiaParticleInfo::PythiaParticleInfo()
	: fastjet::PseudoJet::UserInfoBase::UserInfoBase()
	, fParticle(0)
	{;}

	PythiaParticleInfo::PythiaParticleInfo(const Pythia8::Particle &p)
	: fastjet::PseudoJet::UserInfoBase::UserInfoBase()
	, fParticle(new Pythia8::Particle(p))
	{;}

	PythiaParticleInfo::~PythiaParticleInfo()
	{
		delete fParticle;
	}

	Pythia8::Particle* PythiaParticleInfo::getParticle() const {return fParticle;}

	Pythia8::Particle *getPythia8Particle(const fastjet::PseudoJet *psj)
	{
		if (psj->has_user_info<PythiaParticleInfo>())
			return psj->user_info<PythiaParticleInfo>().getParticle();
		return 0;
	}
}
