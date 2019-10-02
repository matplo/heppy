#include "pyfjtools.hh"
#include <cmath>
#include <iostream>

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
													 int *selection, 
													 int nsel,
													 int user_index_offset,
													 bool add_particle_info)
	{
		std::vector<fastjet::PseudoJet> v;
		std::bitset<kMaxSetting> mask(0); // no particle accepted
		for (unsigned int i = 0; i < nsel; i++)
		{
			if (selection[i] > 0)
			{
				mask[selection[i]] = true;
			}
			else
			{
				mask[abs(selection[i])] = false;
			}
		}
		for (int ip = 0; ip < pythia.event.size(); ip++)
		{
			std::bitset<kMaxSetting> pmask(0);
			for (unsigned int i = 0; i < nsel; i++)
			{
				if (selection[i] > 0)
				{
					switch(selection[i])
					{
						case kAny: 			pmask[selection[i]] = true; 							break;
						case kFinal: 		pmask[selection[i]] = pythia.event[ip].isFinal(); 		break;
						case kCharged: 		pmask[selection[i]] = pythia.event[ip].isCharged(); 	break;
						case kNeutral: 		pmask[selection[i]] = pythia.event[ip].isNeutral(); 	break;
						case kVisible: 		pmask[selection[i]] = pythia.event[ip].isVisible(); 	break;
						case kParton: 		pmask[selection[i]] = pythia.event[ip].isParton(); 		break;
						case kGluon: 		pmask[selection[i]] = pythia.event[ip].isGluon(); 		break;
						case kQuark: 		pmask[selection[i]] = pythia.event[ip].isQuark(); 		break;
						case kDiquark: 		pmask[selection[i]] = pythia.event[ip].isDiquark(); 	break;
						case kLepton: 		pmask[selection[i]] = pythia.event[ip].isLepton(); 		break;
						case kPhoton:       pmask[selection[i]] = (pythia.event[ip].id() == 22); 	break;
						case kHadron: 		pmask[selection[i]] = pythia.event[ip].isHadron(); 		break;
						case kResonance: 	pmask[selection[i]] = pythia.event[ip].isResonance(); 	break;
					}
				}
				else
				{
					switch(abs(selection[i]))
					{
						case kAny: 			pmask[abs(selection[i])] = false; 							break;
						case kFinal: 		pmask[abs(selection[i])] = !pythia.event[ip].isFinal(); 	break;
						case kCharged: 		pmask[abs(selection[i])] = !pythia.event[ip].isCharged(); 	break;
						case kNeutral: 		pmask[abs(selection[i])] = !pythia.event[ip].isNeutral(); 	break;
						case kVisible: 		pmask[abs(selection[i])] = !pythia.event[ip].isVisible(); 	break;
						case kParton: 		pmask[abs(selection[i])] = !pythia.event[ip].isParton(); 	break;
						case kGluon: 		pmask[abs(selection[i])] = !pythia.event[ip].isGluon(); 	break;
						case kQuark: 		pmask[abs(selection[i])] = !pythia.event[ip].isQuark(); 	break;
						case kDiquark: 		pmask[abs(selection[i])] = !pythia.event[ip].isDiquark(); 	break;
						case kLepton: 		pmask[abs(selection[i])] = !pythia.event[ip].isLepton(); 	break;
						case kPhoton:       pmask[abs(selection[i])] = !(pythia.event[ip].id() == 22); 	break;
						case kHadron: 		pmask[abs(selection[i])] = !pythia.event[ip].isHadron(); 	break;
						case kResonance: 	pmask[abs(selection[i])] = !pythia.event[ip].isResonance(); break;
					}
				}				
			}
			std::cout 
					<< mask << " " << pmask << " " << " accept = " << ((mask & pmask) == mask) << " " << "(mask & pmask) " << (mask & pmask) << " "
					<< "isFinal = " << pythia.event[ip].isFinal() << " "
					<< pythia.event[ip].name() 
					<< std::endl;
			if ((mask & pmask) == mask)
			{
				fastjet::PseudoJet psj(pythia.event[ip].px(), pythia.event[ip].py(), pythia.event[ip].pz(), pythia.event[ip].e());
				psj.set_user_index(ip + user_index_offset);
				if (add_particle_info)
				{
					PythiaParticleInfo * _pinfo = new PythiaParticleInfo(pythia.event[ip]);
					psj.set_user_info(_pinfo);
				}
				v.push_back(psj);
			}
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
