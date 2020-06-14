#ifndef __FASTJET_CONTRIB_GROOMERSHOP_HH__
#define __FASTJET_CONTRIB_GROOMERSHOP_HH__

#include <sstream>
#include "LundGenerator.hh"

FASTJET_BEGIN_NAMESPACE

namespace contrib
{
  class GroomerShop
  {
  public:

  	GroomerShop(JetAlgorithm jet_alg = cambridge_algorithm)
  	: _lund_gen(JetDefinition(jet_alg, JetDefinition::max_allowable_R))
    , _lund_splits()
    , _result()
  	{;}

    GroomerShop(const PseudoJet &jet, JetAlgorithm jet_alg = cambridge_algorithm)
    : _lund_gen(JetDefinition(jet_alg, JetDefinition::max_allowable_R))
    , _lund_splits()
    , _result()
    {
      recluster(jet);
    }

    GroomerShop(const PseudoJet &jet, const double& R0, JetAlgorithm jet_alg = cambridge_algorithm)
    : _lund_gen(JetDefinition(jet_alg, R0))
    , _lund_splits()
    , _result()
    {
      recluster(jet);
    }

  	GroomerShop(const JetDefinition & jet_def) 
  	: _lund_gen(jet_def)
    , _lund_splits()
    , _result()
  	{;}

    /// destructor
    virtual ~GroomerShop() 
    {;}

    /// description of the class
    virtual std::string description() const;

    /// a convenienve - once you have the split - get it's index in the vector of primary lund
    int index(const LundDeclustering &l);

    /// recluster and set the vector of primary lund plane splittings
    bool recluster(const PseudoJet& jet);

    /// obtain the declusterings of the primary plane of the jet
    virtual std::vector<LundDeclustering> lund_splits() const;

    /// set the declusterings of the primary plane of the jet
    virtual void set_lund_splits(const std::vector<LundDeclustering>& lunds);

    /// obtain the splitting after dynamical grooming of the primary plane of the jet
    // https://arxiv.org/abs/1911.00375
    virtual LundDeclustering* dynamical(const double& alpha);

    /// obtain the splitting of max{pT's of softer prongs}
    virtual LundDeclustering* max_pt_softer();

    /// obtain the splitting of max{z_i}
    virtual LundDeclustering* max_z();

    /// obtain the splitting of max{kt_i}
    virtual LundDeclustering* max_kt();

    /// obtain the splitting of max{kappa_i}
    virtual LundDeclustering* max_kappa();

    /// obtain the splitting of max{tf_i} : tf = z\theta^2
    virtual LundDeclustering* max_tf();

    /// obtain the splitting of min{tf_i} : tf = z\theta^2
    virtual LundDeclustering* min_tf();

    /// soft drop - returns zero_split in case no substructure found
    virtual LundDeclustering* soft_drop(double beta, double zcut, double R0 = JetDefinition::max_allowable_R);

  private:
  	LundGenerator _lund_gen;
    std::vector<LundDeclustering> _lund_splits;
    LundDeclustering _result;
  };

} // namespace contrib

FASTJET_END_NAMESPACE

#endif // __FASTJET_CONTRIB_DYGROOMER_HH__