#ifndef PYTHIA_FASTJET_TOOLS_HH
#define PYTHIA_FASTJET_TOOLS_HH

#include <fastjet/PseudoJet.hh>
#include <Pythia8/Pythia.h>

namespace pythiafjtools{
	std::vector<fastjet::PseudoJet> vectorize(const Pythia8::Pythia &p,
	                                          bool only_final,
	                                          double eta_min, double eta_max,
	                                          bool add_particle_info = false);

	enum Py8Part
	{
		kAny     = 0,
		kFinal   = 1,
		kCharged = 2,
		kNeutral = 3,
		kVisible = 4,
		kParton  = 5,
		kGluon   = 6,
		kQuark   = 7,
		kDiquark = 8,
		kLepton  = 9,
		kPhoton  = 10,
		kHadron  = 11,
		kResonance = 12
	};

	std::vector<fastjet::PseudoJet> vectorize_select(	const Pythia8::Pythia &p, 
														int *selection, int nsel, 
														int user_index_offset = 0,
														bool add_particle_info = false);

	// implemented in fjtools
	// double angularity(const fastjet::PseudoJet &j, double alpha, double scaleR0 = 1.);

	Pythia8::Particle *getPythia8Particle(const fastjet::PseudoJet *psj);

	class PythiaParticleInfo : public fastjet::PseudoJet::UserInfoBase
	{
	public:
		PythiaParticleInfo();
		PythiaParticleInfo(const Pythia8::Particle &p);
		~PythiaParticleInfo();
		Pythia8::Particle* getParticle() const ;
	private:
		Pythia8::Particle* fParticle;
	};
};

#endif
