#include "fjtools.hh"
#include <iostream>
#include <fastjet/PseudoJet.hh>

namespace FJTools
{
	double angularity(const fastjet::PseudoJet &j, double alpha, double scaleR0)
	{
		double _ang = 0;
		const std::vector<fastjet::PseudoJet> &_cs = j.constituents();
		for (unsigned int i = 0; i < _cs.size(); i++)
		{
			const fastjet::PseudoJet &_p = _cs[i];
			_ang += _p.perp() * pow(_p.delta_R(j) / scaleR0 , 2. - alpha);
		}
		_ang /= j.perp();
		return _ang;
	}

	// Angularity definition as it is given in arXiv:1408.3122
	double lambda_beta_kappa(const fastjet::PseudoJet &j, double beta, double kappa,
		double scaleR0, bool check_user_index/*=false*/)
	{
		// If there are no constituents (empty jet), return an underflow value
		if (!j.has_constituents()) { return -1; }

		double _l = 0;  // init lambda
		const std::vector<fastjet::PseudoJet> &_cs = j.constituents();
		for (unsigned int i = 0; i < _cs.size(); i++)
		{
			const fastjet::PseudoJet &_p = _cs[i];
			// If particle is a thermal, subtract instead of adding
			if (check_user_index && _p.user_index() < 0) {
				_l -= std::pow(_p.perp(), kappa) *
					std::pow(_p.delta_R(j) / scaleR0, beta);
			} else {
				_l += std::pow(_p.perp(), kappa) *
					std::pow(_p.delta_R(j) / scaleR0, beta);
			}
		}
		_l /= std::pow(j.perp(), kappa);
		return _l;
	}

	// Use this overloaded definition for groomed jets
	double lambda_beta_kappa(const fastjet::PseudoJet &j, const fastjet::PseudoJet &j_groomed,
		double beta, double kappa, double scaleR0, bool check_user_index/*=false*/)
	{
		// If there are no constituents (empty jet), return an underflow value
		if (!j.has_constituents() || !j_groomed.has_constituents()) { return -1; }

		double _l = 0;  // init lambda
		const std::vector<fastjet::PseudoJet> &_cs = j_groomed.constituents();
		for (unsigned int i = 0; i < _cs.size(); i++)
		{
			const fastjet::PseudoJet &_p = _cs[i];
			// If particle is a thermal, subtract instead of adding
			if (check_user_index && _p.user_index() < 0) {
				_l -= std::pow(_p.perp(), kappa) *
					std::pow(_p.delta_R(j) / scaleR0, beta);
			} else {
				_l += std::pow(_p.perp(), kappa) *
					std::pow(_p.delta_R(j) / scaleR0, beta);
			}
		}
		_l /= std::pow(j.perp(), kappa);
		return _l;
	}

	std::vector<fastjet::PseudoJet> vectorize_pt_eta_phi(double *pt, int npt, double *eta, int neta, double *phi, int nphi, int user_index_offset)
	{
		std::vector<fastjet::PseudoJet> v;
		if (npt != neta || npt != nphi)
		{
			std::cerr << "[error] vectorize_pt_eta_phi : incompatible array sizes" << std::endl;
			return v;
		}
		for (unsigned int i = 0; i < npt; i++)
		{
			double px = pt[i] * cos(phi[i]);
			double py = pt[i] * sin(phi[i]);
			double pz = pt[i] * sinh(eta[i]);
			double e  = sqrt(px*px + py*py + pz*pz);
			fastjet::PseudoJet psj(px, py, pz, e);
			psj.set_user_index(i + user_index_offset);
			v.push_back(psj);
		}
		return v;
	}

	std::vector<fastjet::PseudoJet> vectorize_pt_eta_phi_m(double *pt, int npt, double *eta, int neta, double *phi, int nphi, double *m, int nm, int user_index_offset)
	{
		std::vector<fastjet::PseudoJet> v;
		if (npt != neta || npt != nphi || npt != nm)
		{
			std::cerr << "[error] vectorize_pt_eta_phi : incompatible array sizes" << std::endl;
			return v;
		}
		for (unsigned int i = 0; i < npt; i++)
		{
			double px = pt[i] * cos(phi[i]);
			double py = pt[i] * sin(phi[i]);
			double pz = pt[i] * sinh(eta[i]);
			double e  = sqrt(px*px + py*py + pz*pz + m[i]*m[i]);
			fastjet::PseudoJet psj(px, py, pz, e);
			psj.set_user_index(i + user_index_offset);
			v.push_back(psj);
		}
		return v;
	}

	std::vector<fastjet::PseudoJet> vectorize_px_py_pz(double *px, int npx, double *py, int npy, double *pz, int npz, int user_index_offset)
	{
		std::vector<fastjet::PseudoJet> v;
		if (npx != npy || npx != npz) 
		{
			std::cerr << "[error] vectorize_px_py_pz : incompatible array sizes" << std::endl;
			return v;
		}
		for (unsigned int i = 0; i < npx; i++)
		{
			double e  = sqrt(px[i]*px[i] + py[i]*py[i] + pz[i]*pz[i]);
			fastjet::PseudoJet psj(px[i], py[i], pz[i], e);
			psj.set_user_index(i + user_index_offset);
			v.push_back(psj);
		}
		return v;
	}

	std::vector<fastjet::PseudoJet> vectorize_px_py_pz_e(double *px, int npx, double *py, int npy, double *pz, int npz, double *e, int ne, int user_index_offset)
	{
		std::vector<fastjet::PseudoJet> v;
		if (npx != npy || npx != npz || npx != ne) 
		{
			std::cerr << "[error] vectorize_px_py_pz_e : incompatible array sizes" << std::endl;
			return v;
		}
		for (unsigned int i = 0; i < npx; i++)
		{
			fastjet::PseudoJet psj(px[i], py[i], pz[i], e[i]);
			psj.set_user_index(i + user_index_offset);
			v.push_back(psj);
		}
		return v;
	}

	std::vector<fastjet::PseudoJet> vectorize_px_py_pz_m(double *px, int npx, double *py, int npy, double *pz, int npz, double *m, int nm, int user_index_offset)
	{
		std::vector<fastjet::PseudoJet> v;
		if (npx != npy || npx != npz || npx != nm) 
		{
			std::cerr << "[error] vectorize_px_py_pz_m : incompatible array sizes" << std::endl;
			return v;
		}
		for (unsigned int i = 0; i < npx; i++)
		{
		    double e  = sqrt(px[i]*px[i] + py[i]*py[i] + pz[i]*pz[i] + m[i]*m[i]);
			fastjet::PseudoJet psj(px[i], py[i], pz[i], e);
			psj.set_user_index(i + user_index_offset);
			v.push_back(psj);
		}
		return v;
	}


	//-----------------------------------------------------------------------------------
	/// Custom recombiner class
	/// Allows to recombine negative user_index particles by subtracting rather than adding their four-vectors
	/// Code adapted from: Yasuki Tachibana
	NegativeEnergyRecombiner::NegativeEnergyRecombiner():
		_ui(0)
	{;}
	NegativeEnergyRecombiner::NegativeEnergyRecombiner(const int ui):
		_ui(ui)
	{;}

	void NegativeEnergyRecombiner::recombine(
		const fastjet::PseudoJet & particle1, const fastjet::PseudoJet & particle2,
		fastjet::PseudoJet & combined_particle) const {

		// Define coefficients with which to combine particles
		// If particle has positive user_index: +1 (i.e. add its four-vector)
		// If particle has negative user_index: -1 (i.e. subtract its four-vector)
		int c1 = 1, c2 = 1;
		if (particle1.user_index() < 0) {
			c1 = -1;
		}
		if (particle2.user_index() < 0) {
			c2 = -1;
		}

		// Recombine particles
		combined_particle = c1*particle1 + c2*particle2;

		// If the combined particle has negative energy, flip the four-vector
		// and assign it a new user index
		if(combined_particle.E() < 0) {
			combined_particle.set_user_index(_ui);
			combined_particle.reset_momentum(
				-combined_particle.px(), -combined_particle.py(),
				-combined_particle.pz(), -combined_particle.E());
		} else {
			combined_particle.set_user_index(0);
		}
	}

	//-----------------------------------------------------------------------------------

};
