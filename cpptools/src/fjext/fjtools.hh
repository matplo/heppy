#ifndef HEPPY_HEPPY_HH
#define HEPPY_HEPPY_HH

#include <fastjet/PseudoJet.hh>
#include <fastjet/JetDefinition.hh>
#include <vector>

namespace FJTools
{
	double angularity(const fastjet::PseudoJet &j, double alpha, double scaleR0);
	double lambda_beta_kappa(const fastjet::PseudoJet &j, double beta, double kappa, double scaleR0, bool check_user_index = false);
	double lambda_beta_kappa(const fastjet::PseudoJet &j, const fastjet::PseudoJet &j_groomed,
		double beta, double kappa, double scaleR0, bool check_user_index = false);

	std::vector<fastjet::PseudoJet> vectorize_pt_eta_phi(double *pt, int npt, double *eta, int neta, double *phi, int nphi, int user_index_offset = 0);
	std::vector<fastjet::PseudoJet> vectorize_pt_eta_phi_m(double *pt, int npt, double *eta, int neta, double *phi, int nphi, double *m, int nm, int user_index_offset = 0);
	std::vector<fastjet::PseudoJet> vectorize_px_py_pz  (double *px, int npx, double *py, int npy, double *pz, int npz, int user_index_offset = 0);
	std::vector<fastjet::PseudoJet> vectorize_px_py_pz_e(double *px, int npx, double *py, int npy, double *pz, int npz, double *e, int ne, int user_index_offset = 0);
	std::vector<fastjet::PseudoJet> vectorize_px_py_pz_m(double *px, int npx, double *py, int npy, double *pz, int npz, double *m, int nm, int user_index_offset = 0);	

	//-----------------------------------------------------------------------------------
	/// Custom recombiner class 
	/// Allows to recombine negative user_index particles by subtracting rather than adding their four-vectors
	/// Code adapted from: Yasuki Tachibana
	class NegativeEnergyRecombiner : public fastjet::JetDefinition::Recombiner {
	public:
		NegativeEnergyRecombiner();
		NegativeEnergyRecombiner(const int ui);
		virtual std::string description() const {return "E-scheme Recombiner that checks a flag for a 'negative momentum' particle, and subtracts the 4-momentum in recombinations.";}
		virtual void recombine(const fastjet::PseudoJet & particle1,
							   const fastjet::PseudoJet & particle2,
							   fastjet::PseudoJet & combined_particle) const;
	private:
		const int _ui;
	};
	//-----------------------------------------------------------------------------------

	// Swig seems to have trouble recognizing that NegativeEnergyRecombiner inherits from Recombiner, so we can set it explicitly
	void set_recombiner(fastjet::JetDefinition *jdef, fastjet::JetDefinition::Recombiner *r) {
		jdef->set_recombiner(r);
	}

}

#endif
