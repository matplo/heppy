#include "pyfjtools.hh"
#include <cmath>
#include <iostream>
#include <bitset>

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
		std::bitset<kMaxSetting> negmask(0); // no particle accepted
		negmask.flip();
		for (unsigned int i = 0; i < nsel; i++)
		{
			if (selection[i] > 0)
			{
				mask[selection[i]] = true;
			}
			else
			{
				negmask[abs(selection[i])] = false;
			}
		}
		for (int ip = 0; ip < pythia.event.size(); ip++)
		{
			std::bitset<kMaxSetting> pmask(0);
			// for (unsigned int i = 0; i < nsel; i++)
			// {
			// 	switch(abs(selection[i]))
			// 	{
			// 		case kAny: 			pmask[abs(selection[i])] = true; 							break;
			// 		case kFinal: 		pmask[abs(selection[i])] = pythia.event[ip].isFinal(); 		break;
			// 		case kCharged: 		pmask[abs(selection[i])] = pythia.event[ip].isCharged(); 	break;
			// 		case kNeutral: 		pmask[abs(selection[i])] = pythia.event[ip].isNeutral(); 	break;
			// 		case kVisible: 		pmask[abs(selection[i])] = pythia.event[ip].isVisible(); 	break;
			// 		case kParton: 		pmask[abs(selection[i])] = pythia.event[ip].isParton(); 	break;
			// 		case kGluon: 		pmask[abs(selection[i])] = pythia.event[ip].isGluon(); 		break;
			// 		case kQuark: 		pmask[abs(selection[i])] = pythia.event[ip].isQuark(); 		break;
			// 		case kDiquark: 		pmask[abs(selection[i])] = pythia.event[ip].isDiquark(); 	break;
			// 		case kLepton: 		pmask[abs(selection[i])] = pythia.event[ip].isLepton(); 	break;
			// 		case kPhoton:       pmask[abs(selection[i])] = (pythia.event[ip].id() == 22); 	break;
			// 		case kHadron: 		pmask[abs(selection[i])] = pythia.event[ip].isHadron(); 	break;
			// 		case kResonance: 	pmask[abs(selection[i])] = pythia.event[ip].isResonance(); 	break;
			// 	}
			// }
			for (unsigned int i = 0; i < kMaxSetting; i++)
			{
				switch(i)
				{
					case kIgnore:		pmask[i] = true;
					case kAny: 			pmask[i] = true; 							break;
					case kFinal: 		pmask[i] = pythia.event[ip].isFinal(); 		break;
					case kCharged: 		pmask[i] = pythia.event[ip].isCharged(); 	break;
					case kNeutral: 		pmask[i] = pythia.event[ip].isNeutral(); 	break;
					case kVisible: 		pmask[i] = pythia.event[ip].isVisible(); 	break;
					case kParton: 		pmask[i] = pythia.event[ip].isParton(); 	break;
					case kGluon: 		pmask[i] = pythia.event[ip].isGluon(); 		break;
					case kQuark: 		pmask[i] = pythia.event[ip].isQuark(); 		break;
					case kDiquark: 		pmask[i] = pythia.event[ip].isDiquark(); 	break;
					case kLepton: 		pmask[i] = pythia.event[ip].isLepton(); 	break;
					case kPhoton:       pmask[i] = (pythia.event[ip].id() == 22); 	break;
					case kHadron: 		pmask[i] = pythia.event[ip].isHadron(); 	break;
					case kResonance: 	pmask[i] = pythia.event[ip].isResonance(); 	break;
				}
			}
			bool accept = ((mask & pmask) == mask) && ((negmask & pmask) == pmask);
			// if (accept)
			// 	std::cout << "[+] ";
			// else
			// 	std::cout << "[-] ";
			// std::cout 
			// 		<< ip << " "
			// 		<< mask << " !-" << negmask << " " << pmask << " " << " " << "(mask & pmask) " << (mask & pmask) << " "
			// 		<< "isFinal = " << pythia.event[ip].isFinal() << " "
			// 		<< pythia.event[ip].name() 
			// 		<< std::endl;
			if (accept)
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


	std::vector<fastjet::PseudoJet> vectorize_select_replaceD0(const Pythia8::Pythia &pythia, 
													 		   int *selection, 
													 		   int nsel,
													 		   int user_index_offset,
													 		   bool add_particle_info,
															   bool remove_soft_pion)
	{
		std::vector<fastjet::PseudoJet> v;

		int D0_notKpi_counter = 0;
		std::vector<int> saved_indices; // indices of particles saved to vector v
		std::vector<int> indices_to_check; // indices of kaons/pions that should not be saved to vector v
		bool D0found = false;
		int d0notfound_ctr = 0;
		
		std::bitset<kMaxSetting> mask(0); // no particle accepted
		std::bitset<kMaxSetting> negmask(0); // no particle accepted
		negmask.flip();
		for (unsigned int i = 0; i < nsel; i++)
		{
			if (selection[i] > 0)
			{
				mask[selection[i]] = true;
			}
			else
			{
				negmask[abs(selection[i])] = false;
			}
		}
		for (int ip = 0; ip < pythia.event.size(); ip++)
		{
			std::bitset<kMaxSetting> pmask(0);
			
			for (unsigned int i = 0; i < kMaxSetting; i++)
			{
				switch(i)
				{
					case kIgnore:		pmask[i] = true;							
					case kAny: 			pmask[i] = true; 							break;
					case kFinal: 		pmask[i] = pythia.event[ip].isFinal(); 		break;
					case kCharged: 		pmask[i] = pythia.event[ip].isCharged(); 	break;
					case kNeutral: 		pmask[i] = pythia.event[ip].isNeutral(); 	break;
					case kVisible: 		pmask[i] = pythia.event[ip].isVisible(); 	break;
					case kParton: 		pmask[i] = pythia.event[ip].isParton(); 	break;
					case kGluon: 		pmask[i] = pythia.event[ip].isGluon(); 		break;
					case kQuark: 		pmask[i] = pythia.event[ip].isQuark(); 		break;
					case kDiquark: 		pmask[i] = pythia.event[ip].isDiquark(); 	break;
					case kLepton: 		pmask[i] = pythia.event[ip].isLepton(); 	break;
					case kPhoton:       pmask[i] = (pythia.event[ip].id() == 22); 	break;
					case kHadron: 		pmask[i] = pythia.event[ip].isHadron(); 	break;
					case kResonance: 	pmask[i] = pythia.event[ip].isResonance(); 	break;
					// case kD0:			pmask[i] = (pythia.event[ip].idAbs() == 421); break;
				}
			}
			bool accept = ((mask & pmask) == mask) && ((negmask & pmask) == pmask) || pythia.event[ip].idAbs() == 421;
			// if (accept)
			// 	std::cout << "[+] ";
			// else
			// 	std::cout << "[-] ";
			// std::cout 
			// 		<< ip << " "
			// 		<< mask << " !-" << negmask << " " << pmask << " " << " " << "(mask & pmask) " << (mask & pmask) << " "
			// 		<< "isFinal = " << pythia.event[ip].isFinal() << " "
			// 		<< pythia.event[ip].name() 
			// 		<< std::endl;
			if (accept)
			{
				// see if the particle is a kaon
				// std::cout << "ip!! " << ip << ", " << pythia.event[ip].idAbs() << std::endl;

				if (pythia.event[ip].idAbs() == 421) { //D0
					std::vector<int> daughter_indices = pythia.event[ip].daughterList();
					// std::cout << "pythia.event " << ip << " Found a D0!" << std::endl;

					if ( daughter_indices.size() != 2 ) { // if more than two decay products, move to next event
						continue;
					}

					int idau1 = daughter_indices[0];
					int idau2 = daughter_indices[1];
					// std::cout << "all daughters in list indices: ";
					// for (int j=0; j<daughter_indices.size(); j++){
						// std::cout << daughter_indices[j] << " ";
					// }
					// std::cout << "all daughters in list IDs: ";
					// for (int j=0; j<daughter_indices.size(); j++){
						// std::cout << pythia.event[daughter_indices[j]].id() << " ";
					// }
					// std::cout << std::endl;
					// std::cout << "pythia.event daughter 1 " << pythia.event[idau1].id() << std::endl;
					// std::cout << "pythia.event daughter 2 " << pythia.event[idau2].id() << std::endl;

					// std::cout << "pythia.event daughter 2 not from list " << pythia.event[pythia.event[ip].daughter1()].id() << std::endl;
					// std::cout << "pythia.event daughter 2 not from list " << pythia.event[pythia.event[ip].daughter2()].id() << std::endl;

					if (((pythia.event[idau1].idAbs() == 321 && pythia.event[idau2].idAbs() == 211) || //kaon & pion
						(pythia.event[idau1].idAbs() == 211 && pythia.event[idau2].idAbs() == 321)) && //pion & kaon 
						pythia.event[idau1].charge() != pythia.event[idau2].charge()) //kaon and pion are dif charges
					{
						int ikaon = (pythia.event[idau1].idAbs() == 321) ? idau1 : idau2;
						int ipion = (pythia.event[idau1].idAbs() == 211) ? idau1 : idau2;
						
						std::cout << "pythia.event " << ip << ", " << ikaon << ", " << ipion << " Found a D0->Kpi!" << std::endl;
						D0found = true;

						// add only the D0
						fastjet::PseudoJet kaon(pythia.event[ikaon].px(), pythia.event[ikaon].py(), pythia.event[ikaon].pz(), pythia.event[ikaon].e());
						fastjet::PseudoJet pion(pythia.event[ipion].px(), pythia.event[ipion].py(), pythia.event[ipion].pz(), pythia.event[ipion].e());
						fastjet::PseudoJet pair = kaon + pion;
						//could we just do??:
						fastjet::PseudoJet D0(pythia.event[ip].px(), pythia.event[ip].py(), pythia.event[ip].pz(), pythia.event[ip].e());
						// std::cout << "D0   px, py, pz, E " << D0.px() << " " << D0.py() << " " << D0.pz() << " " << D0.e() << std::endl;
						// std::cout << "pair px, py, pz, E " << pair.px() << " " << pair.py() << " " << pair.pz() << " " << pair.e() << std::endl;

						D0.set_user_index(ip + user_index_offset);
						// std::cout << "D0 set user index is " << ip + user_index_offset << std::endl;
						if (add_particle_info)
						{
							PythiaParticleInfo * _pinfo = new PythiaParticleInfo(pythia.event[ip]);
							D0.set_user_info(_pinfo);
						}			

						// save particle information
						v.push_back(D0); //pair);
						saved_indices.push_back(ip + user_index_offset); //TODO: check whether this is actually what is being saved
						indices_to_check.push_back(ikaon+user_index_offset);
						indices_to_check.push_back(ipion+user_index_offset);


						// check if D0's mother is D*
						if (remove_soft_pion) {
							if (checkD0mother(pythia, ip)) {
								int softpion_index = getSoftPion(pythia, ip);
								//TODO: run this:
								if (softpion_index != -1) {
									indices_to_check.push_back(softpion_index + user_index_offset);

									// remove any soft pions previously saved to v
									int index_to_rm = removeIndexFromv(v, saved_indices, softpion_index+user_index_offset);
									remove(v.begin(), v.end(), v[index_to_rm]); //TODO: see if this is doing what we think it's doing
								}

							}
						}

						// see if any kaons/pions were previously saved to v
						// if (std::count(saved_indices.begin(), saved_indices.end(), ikaon + user_index_offset)) {
						// 	std::vector<int>::iterator it = std::find(saved_indices.begin(), saved_indices.end(), ikaon+user_index_offset);
						// 	int index_to_rm = it - saved_indices.begin();
						// 	remove(v.begin(), v.end(), v[index_to_rm]); //TODO: see if this is doing what we think it's doing
						// }
						// if (std::count(saved_indices.begin(), saved_indices.end(), ipion + user_index_offset)) {
						// 	std::vector<int>::iterator it = std::find(saved_indices.begin(), saved_indices.end(), ipion+user_index_offset);
						// 	int index_to_rm = it - saved_indices.begin();
						// 	remove(v.begin(), v.end(), v[index_to_rm]); //TODO: see if this is doing what we think it's doing
						// }

						// continue;

					} else { //the case that D0 does not go to k+pi- or k-pi+
						D0_notKpi_counter++;
					}

					continue; //don't add any D0's to the vector v after this point

				} // end of if D0 loop


				//don't save kaons or pions that came from D0->Kpi
				if (std::count(indices_to_check.begin(), indices_to_check.end(), ip + user_index_offset)) {
					continue;
				}


				fastjet::PseudoJet psj(pythia.event[ip].px(), pythia.event[ip].py(), pythia.event[ip].pz(), pythia.event[ip].e());
				psj.set_user_index(ip + user_index_offset);
				if (add_particle_info)
				{
					PythiaParticleInfo * _pinfo = new PythiaParticleInfo(pythia.event[ip]);
					psj.set_user_info(_pinfo);
				}
				v.push_back(psj);
				saved_indices.push_back(ip);
			}
		}	

		// remove all particles if no D0->Kpi decay
		if (!D0found) {
			// d0notfound_ctr++;
			v.clear();
		}

		// std::cout << v << std::endl;

		// //print statements to check
		// std::cout << "saved_indices: ";
		// for (int ind=0; ind<saved_indices.size(); ind++ ){
		// 	std::cout << saved_indices[ind] << " ";
		// }
		// std::cout << std::endl;
		// std::cout << "indices_to_check: ";
		// for (int ind=0; ind<indices_to_check.size(); ind++ ){
		// 	std::cout << indices_to_check[ind] << " ";
		// }
		// std::cout << std::endl;

		return v;
	}


	// check if D0's mother is D*
	bool checkD0mother( const Pythia8::Pythia &pythia, int D0particle_index ) {

		bool motherisDstar = false;

		if (pythia.event[D0particle_index].idAbs() == 421) { //D0

			std::vector<int> mother_indices = pythia.event[D0particle_index].motherList();
			if ( mother_indices.size() == 1 ) { // assuming D* is the only mother to D0
				int mo1 = mother_indices[0];
				if (pythia.event[mo1].idAbs() == 413) { //D*
					motherisDstar = true;
				}
			}
		}
		// std::cout << "is mother a Dstar?  " << motherisDstar << std::endl;
		return motherisDstar;
	}

	int getSoftPion( const Pythia8::Pythia &pythia, int D0particle_index ) {
		int softpion_index = -1;
		
		int Dstar_index = pythia.event[D0particle_index].motherList()[0];
		std::vector<int> poss_softpion_indices = pythia.event[Dstar_index].daughterList(); 
		//TODO: check if there are only two daughters??
		for (int daughter_index : poss_softpion_indices ) {
			int poss_softpion_idAbs = pythia.event[daughter_index].idAbs();
			if (poss_softpion_idAbs == 211) 
				softpion_index = daughter_index;
		}
		return softpion_index;

	}

	int removeIndexFromv( std::vector<fastjet::PseudoJet> v, std::vector<int> saved_indices, int index) {
		if (std::count(saved_indices.begin(), saved_indices.end(), index)) {
			std::vector<int>::iterator it = std::find(saved_indices.begin(), saved_indices.end(), index);
			int index_to_rm = it - saved_indices.begin();
			// remove(v.begin(), v.end(), v[index_to_rm]); //TODO: see if this is doing what we think it's doing
			return index_to_rm;
		}
	}

	std::vector<fastjet::PseudoJet> removeByIndex(std::vector<fastjet::PseudoJet> v, int indextoremove)
	{
		// std::cout << "in removeByIndex " << v.size() << " indextoremove " << indextoremove << std::endl; 
		v.erase(v.begin()+indextoremove);
		return v;
	}
	std::vector<fastjet::PseudoJet> removeByIndex(std::vector<fastjet::PseudoJet> v, int *selection, int nsel) //selection must be a reverse-ordered list
	{
		for (int i=0; i<nsel; i++) {
			// std::cout << "in removeByIndex " << v.size() << " indextoremove " << selection[i] << std::endl; 
			v.erase(v.begin() + selection[i]);
		}
		return v;
	}

	std::vector<fastjet::PseudoJet> replaceKPwD0(const Pythia8::Pythia &pythia, std::vector<fastjet::PseudoJet> v, int D0index, int dau1index, int dau2index)
	{
		// std::cout << "checkpoint 1 " << v.size() << std::endl;
		// std::cout << " D0 " << D0index << " dau1 " << dau1index << " dau2 " << dau2index << std::endl;
		std::cout << "Replacing (!) Kpi " << dau1index << " and " << dau2index << " with D0 " << D0index << std::endl;
		fastjet::PseudoJet D0(pythia.event[D0index].px(), pythia.event[D0index].py(), pythia.event[D0index].pz(), pythia.event[D0index].e());

		D0.set_user_index(D0index);
		// std::cout << "D0 set user index is " << ip + user_index_offset << std::endl;
		PythiaParticleInfo * _pinfo = new PythiaParticleInfo(pythia.event[D0index]);
		D0.set_user_info(_pinfo);
		v.push_back(D0); 

		// remove the kaon and pion
		std::vector<int> ind_to_rem;
		int ctr = 0;
		for (int i=0; i<v.size(); i++) {
			if (v[i].user_index() == dau1index || v[i].user_index() == dau2index){
				ind_to_rem.push_back(i);
				ctr++;
			}
			if (ctr == 2) break;
		}

		int maxindex = (ind_to_rem[0] > ind_to_rem[1]) ? ind_to_rem[0] : ind_to_rem[1];
		int minindex = (ind_to_rem[0] > ind_to_rem[1]) ? ind_to_rem[1] : ind_to_rem[0];
		std::vector<fastjet::PseudoJet> temp_v = removeByIndex(v, maxindex);
		std::vector<fastjet::PseudoJet> temp_v2 = removeByIndex(temp_v, minindex);
		// std::cout << "checkpoint 6 " << temp_v2.size() << std::endl;

		return temp_v2;
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
