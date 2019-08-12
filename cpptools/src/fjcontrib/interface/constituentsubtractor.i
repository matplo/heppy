%module constituentsubtractor
%{
  #include <fastjet/PseudoJet.hh>
  #include <fastjet/FunctionOfPseudoJet.hh>

	#include <fastjet/internal/base.hh>
	#include <fastjet/ClusterSequenceAreaBase.hh>
	#include <fastjet/tools/JetMedianBackgroundEstimator.hh>
	#include <fastjet/tools/GridMedianBackgroundEstimator.hh>
	#include <fastjet/PseudoJet.hh>
	#include <fastjet/Selector.hh>
	#include <fastjet/tools/BackgroundEstimatorBase.hh>
	#include "fastjet/tools/Transformer.hh" // to derive Subtractor from Transformer
	#include "fastjet/LimitedWarning.hh"

  #include <ConstituentSubtractor/ConstituentSubtractor.hh>
  #include <ConstituentSubtractor/IterativeConstituentSubtractor.hh>
  #include <ConstituentSubtractor/RescalingClasses.hh>
  #include <ConstituentSubtractor/functions.hh>
%}
%include "std_string.i"
%include "std_vector.i"

namespace fastjet{
  namespace contrib{

// %include "ConstituentSubtractor/ConstituentSubtractor.hh"
  class ConstituentSubtractor : public fastjet::Transformer{
  public:
    enum Distance {
      deltaR,     /// deltaR=sqrt((y_i-y_j)^2+(phi_i-phi_j)^2)), longitudinal Lorentz invariant
      angle   ///  angle between two momenta in Euclidean space                                          
    };
    ConstituentSubtractor();
    ConstituentSubtractor(fastjet::BackgroundEstimatorBase *bge_rho, fastjet::BackgroundEstimatorBase *bge_rhom=0, double alpha=0, double max_distance=-1, Distance distance=deltaR);
    ConstituentSubtractor(double rho, double rhom=0, double alpha=0, double max_distance=-1, Distance distance=deltaR);
    virtual ~ConstituentSubtractor(){}
    virtual void initialize();
    void description_common(std::ostringstream &descr) const;
    virtual std::string description() const;
    virtual fastjet::PseudoJet result(const fastjet::PseudoJet &jet) const;
    std::vector<fastjet::PseudoJet> do_subtraction(std::vector<fastjet::PseudoJet> const &particles, std::vector<fastjet::PseudoJet> const &backgroundProxies,std::vector<fastjet::PseudoJet> *remaining_backgroundProxies=0) const;
    virtual std::vector<fastjet::PseudoJet> subtract_event(std::vector<fastjet::PseudoJet> const &particles, double max_eta);
    virtual std::vector<fastjet::PseudoJet> subtract_event(std::vector<fastjet::PseudoJet> const &particles, std::vector<fastjet::PseudoJet> const *hard_proxies=0);
    std::vector<fastjet::PseudoJet> subtract_event_using_charged_info(std::vector<fastjet::PseudoJet> const &particles, double charged_background_scale, std::vector<fastjet::PseudoJet> const &charged_background, double charged_signal_scale, std::vector<fastjet::PseudoJet> const &charged_signal, double max_eta);
    void set_rescaling(fastjet::FunctionOfPseudoJet<double> *rescaling);
    void set_grid_size_background_estimator(double const &grid_size_background_estimator);
    void set_background_estimator(fastjet::BackgroundEstimatorBase *bge_rho, fastjet::BackgroundEstimatorBase *bge_rhom=0);
    void set_scalar_background_density(double rho, double rhom=0);
    void set_common_bge_for_rho_and_rhom();
    void set_common_bge_for_rho_and_rhom(bool value);
    void set_keep_original_masses();
    ///  void set_use_bge_rhom_rhom(bool value=true);
    void set_do_mass_subtraction();
    void set_remove_particles_with_zero_pt_and_mass(bool value=true);
    void set_remove_all_zero_pt_particles(bool value=true);
    void set_alpha(double alpha);
    void set_polarAngleExp(double polarAngleExp);
    void set_ghost_area(double ghost_area);
    void set_distance_type(Distance distance);
    void set_max_distance(double max_distance);
    void set_max_standardDeltaR(double max_distance);
    double get_max_distance();
    static bool _function_used_for_sorting(std::pair<double,std::pair<int,int> >  const &i,std::pair<double,std::pair<int,int> >  const &j);
    static bool _rapidity_sorting(fastjet::PseudoJet const &i,fastjet::PseudoJet const &j);
    void construct_ghosts_uniformly(double max_eta);
    std::vector<fastjet::PseudoJet>  get_ghosts();
    void set_max_eta(double max_eta);
    std::vector<double>  get_ghosts_area();
    void set_ghost_selector(fastjet::Selector* selector);
    void set_particle_selector(fastjet::Selector* selector);
    void set_use_nearby_hard(double const &nearby_hard_radius, double const &nearby_hard_factor);
    void set_fix_pseudorapidity();
    void set_scale_fourmomentum();
};

// force recompile
// %include "ConstituentSubtractor/IterativeConstituentSubtractor.hh"
  class IterativeConstituentSubtractor : public fastjet::contrib::ConstituentSubtractor{
  public:
    IterativeConstituentSubtractor();
    virtual void initialize();
    virtual ~IterativeConstituentSubtractor(){}
    virtual std::string description() const;
    virtual std::vector<fastjet::PseudoJet> subtract_event(std::vector<fastjet::PseudoJet> const &particles, std::vector<fastjet::PseudoJet> const *hard_proxies=0);
    virtual std::vector<fastjet::PseudoJet> subtract_event(std::vector<fastjet::PseudoJet> const &particles, double max_eta);
    void set_ghost_removal(bool ghost_removal);
    void set_parameters(std::vector<double> const &max_distances, std::vector<double> const &alphas);
    void set_nearby_hard_parameters(std::vector<double> const &nearby_hard_radii, std::vector<double> const &nearby_hard_factors);
};

// %include "ConstituentSubtractor/RescalingClasses.hh"
// %include "ConstituentSubtractor/functions.hh"

  } // namespace contrib
} // namespace fastjet
