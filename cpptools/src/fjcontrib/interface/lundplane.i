%module lundplane
%{
  #include <fastjet/PseudoJet.hh>
  #include <fastjet/FunctionOfPseudoJet.hh>
  #include <LundPlane/LundGenerator.hh>
  #include <LundPlane/DynamicalGroomer.hh>
  #include <LundPlane/GroomerShop.hh>
  #include <LundPlane/LundJSON.hh>
  #include <LundPlane/LundWithSecondary.hh>
  #include <LundPlane/SecondaryLund.hh>
%}
%include "std_string.i"
%include "std_vector.i"

// Process symbols in header
// %nodefaultctor Recluster;

namespace fastjet{
  namespace contrib{

// %include "LundPlane/LundGenerator.hh"
//----------------------------------------------------------------------

// class LundGenerator;

//----------------------------------------------------------------------
// %nodefaultdtor LundDeclustering;
class LundDeclustering {
public:
  LundDeclustering();
  virtual void reset();
  const fastjet::PseudoJet & pair()  const;
  const fastjet::PseudoJet & harder() const;
  const fastjet::PseudoJet & softer() const;
  double m()         const;
  double Delta()     const;
  double z()         const;
  double kt()        const;
  double kappa()     const;
  double psi()       const;
  std::pair<double,double> const lund_coordinates() const;
  virtual ~LundDeclustering();
  LundDeclustering(const fastjet::PseudoJet& pair,
       const fastjet::PseudoJet& j1, const fastjet::PseudoJet& j2);
  // friend class fastjet::contrib::LundGenerator;
};

// const str * seem to be gone once passed to a print
// use as_string()
// %extend LundDeclustering {
//   const char *__str__() {
//     std::ostringstream oss(std::ostringstream::out);
//     oss << "z=" << (self->z()) << " "
//     << "Delta=" << (self->Delta()) << " "
//     << "kt=" << (self->kt()) << " "
//     << "kappa=" << (self->kappa()) << " "
//     << "m=" << (self->m()) << " "
//     << "psi=" << (self->psi());
//     return oss.str().c_str();
//   };
// };

// needs work
//%extend LundDeclustering {
//  operator ==(const LundDeclustering &l) {
//    return *self == l;
//  };
//};


%feature("python:slot", "tp_str", functype="reprfunc") LundDeclustering::as_string;
%extend LundDeclustering {
  std::string as_string() {
    std::ostringstream oss(std::ostringstream::out);
    oss << "z=" << (self->z()) << " "
    << "Delta=" << (self->Delta()) << " "
    << "kt=" << (self->kt()) << " "
    << "kappa=" << (self->kappa()) << " "
    << "m=" << (self->m()) << " "
    << "psi=" << (self->psi());
    return oss.str();
  };
};

//----------------------------------------------------------------------
class LundGenerator : public fastjet::FunctionOfPseudoJet< std::vector<fastjet::contrib::LundDeclustering> > {
public:
  LundGenerator(fastjet::JetAlgorithm jet_alg = fastjet::Algorithm::cambridge_algorithm);
  LundGenerator(const fastjet::JetDefinition & jet_def);
  virtual ~LundGenerator();
  std::vector<fastjet::contrib::LundDeclustering> result(const fastjet::PseudoJet& jet) const;
  virtual std::string description() const;
};

// %include "LundPlane/DynamicalGroomer.hh"
class DynamicalGroomer
{
public:
  DynamicalGroomer(fastjet::JetAlgorithm jet_alg = fastjet::Algorithm::cambridge_algorithm);
  DynamicalGroomer(const fastjet::JetDefinition & jet_def);
  virtual ~DynamicalGroomer();
  virtual std::string description() const;

  int result_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds, const double& alpha);
  virtual LundDeclustering result(const fastjet::PseudoJet& jet, const double& alpha);
  virtual std::vector<fastjet::contrib::LundDeclustering> lund_splits() const;
  static fastjet::contrib::LundDeclustering& result_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds, const double& alpha);

  /// obtain the splitting of max{pT's of softer prongs}
  virtual LundDeclustering max_pt_softer(const fastjet::PseudoJet& jet);
  /// obtain the index of the max{pT's of softer prongs} the primary plane of the jet
  int max_pt_softer_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
  static fastjet::contrib::LundDeclustering& max_pt_softer_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds);

  /// obtain the splitting of max{z_i}
  virtual LundDeclustering max_z(const fastjet::PseudoJet& jet);
  /// obtain the index of the max{z_i} the primary plane of the jet
  int max_z_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
  static fastjet::contrib::LundDeclustering& max_z_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds);

  /// obtain the splitting of max{kt_i}
  virtual LundDeclustering max_kt(const fastjet::PseudoJet& jet);
  /// obtain the index of the max{kt_i} the primary plane of the jet
  int max_kt_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
  static fastjet::contrib::LundDeclustering& max_kt_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds);

  /// obtain the splitting of max{kappa_i}
  virtual LundDeclustering max_kappa(const fastjet::PseudoJet& jet);
  /// obtain the index of the max{kappa_i} the primary plane of the jet
  int max_kappa_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
  static fastjet::contrib::LundDeclustering& max_kappa_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds);

  /// obtain the splitting of max{tf_i}
  virtual LundDeclustering max_tf(const fastjet::PseudoJet& jet);
  /// obtain the index of the max{tf_i} the primary plane of the jet
  int max_tf_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
  static fastjet::contrib::LundDeclustering& max_tf_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds);

  /// obtain the splitting of min{tf_i}
  virtual LundDeclustering min_tf(const fastjet::PseudoJet& jet);
  /// obtain the index of the min{tf_i} the primary plane of the jet
  int min_tf_split_index(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
  static fastjet::contrib::LundDeclustering& min_tf_split(const std::vector<fastjet::contrib::LundDeclustering>& lunds);
};

// %include "LundPlane/GroomerShop.hh"
class GroomerShop
{
public:
  GroomerShop(fastjet::JetAlgorithm jet_alg = fastjet::Algorithm::cambridge_algorithm);
  GroomerShop(const fastjet::PseudoJet & jet, fastjet::JetAlgorithm jet_alg = fastjet::Algorithm::cambridge_algorithm);
  GroomerShop(const fastjet::JetDefinition & jet_def);

  virtual ~GroomerShop();
  virtual std::string description() const;

  /// a convenienve - once you have the split - get it's index in the vector of primary lund
  int index(const LundDeclustering &l);

  /// recluster and set the vector of primary lund plane splittings
  bool recluster(const fastjet::PseudoJet& jet);

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
  virtual LundDeclustering* soft_drop(double zcut, double beta, double R0 = JetDefinition::max_allowable_R);

};

// %include "LundPlane/LundJSON.hh"
//----------------------------------------------------------------------
// declaration of helper function
void lund_elements_to_json(std::ostream & ostr, const fastjet::contrib::LundDeclustering & d);

/// writes json to ostr for an individual declustering
std::ostream & lund_to_json(std::ostream & ostr, const fastjet::contrib::LundDeclustering & d);

/// writes json to ostr for a vector of declusterings
std::ostream & lund_to_json(std::ostream & ostr, const std::vector<fastjet::contrib::LundDeclustering> & d);

// helper function to write individual elements to json
void lund_elements_to_json(std::ostream & ostr, const fastjet::contrib::LundDeclustering & d);

// %include "LundPlane/LundWithSecondary.hh"
//----------------------------------------------------------------------
class LundWithSecondary {
public:
  /// LundWithSecondary constructor
  LundWithSecondary(fastjet::contrib::SecondaryLund * secondary_def = 0);
  /// LundWithSecondary constructor with jet alg
  LundWithSecondary(fastjet::JetAlgorithm jet_alg,
        fastjet::contrib::SecondaryLund * secondary_def = 0);
  /// LundWithSecondary constructor with jet def
  LundWithSecondary(const fastjet::JetDefinition & jet_def,
        fastjet::contrib::SecondaryLund * secondary_def = 0);
  /// destructor
  virtual ~LundWithSecondary();
  /// primary Lund declustering
  std::vector<fastjet::contrib::LundDeclustering> primary(const fastjet::PseudoJet& jet) const;
  /// secondary Lund declustering (slow)
  std::vector<fastjet::contrib::LundDeclustering> secondary(const fastjet::PseudoJet& jet) const;
  /// secondary Lund declustering with primary sequence as input
  std::vector<fastjet::contrib::LundDeclustering> secondary(
       const std::vector<fastjet::contrib::LundDeclustering> & declusts) const;
  /// return the index associated of the primary declustering that is to be
  /// used for the secondary plane.
  int secondary_index(const std::vector<fastjet::contrib::LundDeclustering> & declusts) const;
  /// description of the class
  std::string description() const;
};

// %include "LundPlane/SecondaryLund.hh"
//----------------------------------------------------------------------
class SecondaryLund {
public:
  /// SecondaryLund constructor
  SecondaryLund();
  /// destructor
  virtual ~SecondaryLund();
  /// returns the index of branch corresponding to the root of the secondary plane
  virtual int result(const std::vector<fastjet::contrib::LundDeclustering> & declusts);
  int operator()(const std::vector<fastjet::contrib::LundDeclustering> & declusts) const;
  /// description of the class
  virtual std::string description() const;
};

//----------------------------------------------------------------------
/// \class SecondaryLund_mMDT
/// Contains a definition for the leading emission using mMDTZ
class SecondaryLund_mMDT : public SecondaryLund {
public:
  /// SecondaryLund_mMDT constructor
  SecondaryLund_mMDT(double zcut = 0.025);
  /// destructor
  virtual ~SecondaryLund_mMDT();
  /// returns the index of branch corresponding to the root of the secondary plane
  virtual int result(const std::vector<fastjet::contrib::LundDeclustering> & declusts) const;
  /// description of the class
  virtual std::string description() const;
};

//----------------------------------------------------------------------
/// \class SecondaryLund_dotmMDT
/// Contains a definition for the leading emission using dotmMDT
class SecondaryLund_dotmMDT : public fastjet::contrib::SecondaryLund {
public:
  /// SecondaryLund_dotmMDT constructor
  SecondaryLund_dotmMDT(double zcut = 0.025);
  /// destructor
  virtual ~SecondaryLund_dotmMDT();
  /// returns the index of branch corresponding to the root of the secondary plane
  virtual int result(const std::vector<fastjet::contrib::LundDeclustering> & declusts) const;
  /// description of the class
  virtual std::string description() const;
private:
  /// zcut parameter
  double zcut_;
};

//----------------------------------------------------------------------
/// \class SecondaryLund_Mass
/// Contains a definition for the leading emission using mass
class SecondaryLund_Mass : public fastjet::contrib::SecondaryLund {
public:
  /// SecondaryLund_Mass constructor (default mass reference is W mass)
  SecondaryLund_Mass(double ref_mass = 80.4) : mref2_(ref_mass*ref_mass);
  /// destructor
  virtual ~SecondaryLund_Mass();
  /// returns the index of branch corresponding to the root of the secondary plane
  virtual int result(const std::vector<fastjet::contrib::LundDeclustering> & declusts);
  /// description of the class
  virtual std::string description() const;
};

  } // namespace contrib
} // namespace fastjet

namespace std
{
  %template(FastJetVLundDeclustering) std::vector<fastjet::contrib::LundDeclustering>;
}
