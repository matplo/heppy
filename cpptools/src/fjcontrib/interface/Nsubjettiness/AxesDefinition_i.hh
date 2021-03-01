#include "MeasureDefinition.hh"
#include "ExtraRecombiners.hh"

#include "fastjet/PseudoJet.hh"
#include <fastjet/LimitedWarning.hh>

#include <iomanip>
#include <cmath>
#include <vector>
#include <list>

class AxesDefinition {   
public:
   virtual std::vector<fastjet::PseudoJet> get_starting_axes(int n_jets,
                                                             const std::vector<fastjet::PseudoJet>& inputs,
                                                             const MeasureDefinition * measure);
   virtual std::string short_description();
   virtual std::string description();
   virtual AxesDefinition* create();

   std::vector<fastjet::PseudoJet> get_refined_axes(int n_jets,
                                                    const std::vector<fastjet::PseudoJet>& inputs,
                                                    const std::vector<fastjet::PseudoJet>& seedAxes,
                                                    const MeasureDefinition * measure = NULL) const;
   std::vector<fastjet::PseudoJet> get_axes(int n_jets,
                                            const std::vector<fastjet::PseudoJet>& inputs,
                                            const MeasureDefinition * measure = NULL) const;
   inline std::vector<fastjet::PseudoJet> operator() (int n_jets,
                                               const std::vector<fastjet::PseudoJet>& inputs,
                                               const MeasureDefinition * measure = NULL) const;

   enum AxesRefiningEnum {
      UNDEFINED_REFINE = -1, // added to create a default value
      NO_REFINING = 0,
      ONE_PASS = 1,
      MULTI_PASS = 100,
   };
   
   int nPass() const;
   bool givesRandomizedResults() const;
   bool needsManualAxes() const;
   void setNPass(int nPass,
                 int nAttempts = 1000,
                 double accuracy  = 0.0001,
                 double noise_range = 1.0 // only needed for MultiPass minimization
                 );
   virtual ~AxesDefinition();
};
  
class ExclusiveJetAxes : public AxesDefinition {   
public:
   ExclusiveJetAxes(fastjet::JetDefinition def);
   virtual std::vector<fastjet::PseudoJet> get_starting_axes(int n_jets,
                                                             const std::vector <fastjet::PseudoJet> & inputs,
                                                             const MeasureDefinition * ) const;
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual ExclusiveJetAxes* create() const;
};

class ExclusiveCombinatorialJetAxes : public AxesDefinition {   
public:
    ExclusiveCombinatorialJetAxes(fastjet::JetDefinition def, int nExtra = 0);
    virtual std::vector<fastjet::PseudoJet> get_starting_axes(int n_jets, 
                                                           const std::vector<fastjet::PseudoJet> & inputs,
                                                           const MeasureDefinition *measure) const;
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual ExclusiveCombinatorialJetAxes* create() const;
};
   
class HardestJetAxes : public AxesDefinition {
public:
   HardestJetAxes(fastjet::JetDefinition def);
   virtual std::vector<fastjet::PseudoJet> get_starting_axes(int n_jets,
                                                             const std::vector <fastjet::PseudoJet> & inputs,
                                                             const MeasureDefinition * ) const;
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual HardestJetAxes* create() const;
// private:
//    fastjet::JetDefinition _def;  ///< Jet Definition to use.   
//    static LimitedWarning _too_few_axes_warning;
};
   
class KT_Axes : public ExclusiveJetAxes {
public:
   /// Constructor
   KT_Axes()
   : ExclusiveJetAxes(fastjet::JetDefinition(fastjet::kt_algorithm,
                                             fastjet::JetDefinition::max_allowable_R, //maximum jet radius constant
                                             fastjet::E_scheme,
                                             fastjet::Best)
                      );
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual KT_Axes* create() const;
};

class CA_Axes : public ExclusiveJetAxes {
public:
   CA_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual CA_Axes* create() const;
};

   
class AntiKT_Axes : public HardestJetAxes {
public:
   AntiKT_Axes(double R0);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual AntiKT_Axes* create() const;   
// protected:
//    double _R0;  ///<  AKT jet radius
};

class JetDefinitionWrapper {
public:
   JetDefinitionWrapper(JetAlgorithm jet_algorithm_in, double R_in, double xtra_param_in, const JetDefinition::Recombiner *recombiner);
   JetDefinitionWrapper(JetAlgorithm jet_algorithm_in, double R_in, const JetDefinition::Recombiner *recombiner, fastjet::Strategy strategy_in);
   JetDefinition getJetDef();
// private:
//    JetDefinition jet_def;  ///< my jet definition
};

class WTA_KT_Axes : public ExclusiveJetAxes {
public:
   WTA_KT_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual WTA_KT_Axes* create() const;
};
   
class WTA_CA_Axes : public ExclusiveJetAxes {
public:
   WTA_CA_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual WTA_CA_Axes* create() const;
};

class GenKT_Axes : public ExclusiveJetAxes {   
public:
   GenKT_Axes(double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual GenKT_Axes* create() const;
// protected:
//    double _p;   ///< genkT power
//    double _R0;  ///< jet radius
};
   
class WTA_GenKT_Axes : public ExclusiveJetAxes {
public:
   WTA_GenKT_Axes(double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual WTA_GenKT_Axes* create() const;
// protected:
//    double _p;   ///< genkT power
//    double _R0;  ///< jet radius
};
   
class GenET_GenKT_Axes : public ExclusiveJetAxes {
public:
   GenET_GenKT_Axes(double delta, double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual GenET_GenKT_Axes* create() const;   
// protected:
//    double _delta; ///< Recombination pT weighting
//    double _p;     ///< GenkT power
//    double _R0;    ///< jet radius
};

class OnePass_KT_Axes : public KT_Axes {
public:
   OnePass_KT_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_KT_Axes* create() const;
};

class OnePass_CA_Axes : public CA_Axes {
public:
   OnePass_CA_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_CA_Axes* create() const;
};
   
class OnePass_AntiKT_Axes : public AntiKT_Axes {
public:
   OnePass_AntiKT_Axes(double R0);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_AntiKT_Axes* create() const;

};

class OnePass_WTA_KT_Axes : public WTA_KT_Axes {
public:
   OnePass_WTA_KT_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_WTA_KT_Axes* create() const;
};

class OnePass_WTA_CA_Axes : public WTA_CA_Axes {   
public:
   OnePass_WTA_CA_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_WTA_CA_Axes* create() const;   
};

class OnePass_GenKT_Axes : public GenKT_Axes {   
public:
   OnePass_GenKT_Axes(double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_GenKT_Axes* create() const;
};
   
class OnePass_WTA_GenKT_Axes : public WTA_GenKT_Axes {   
public:
   OnePass_WTA_GenKT_Axes(double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_WTA_GenKT_Axes* create() const;
};

class OnePass_GenET_GenKT_Axes : public GenET_GenKT_Axes {   
public:
   OnePass_GenET_GenKT_Axes(double delta, double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_GenET_GenKT_Axes* create() const;
};

class Manual_Axes : public AxesDefinition {
public:
   Manual_Axes();
   virtual std::vector<fastjet::PseudoJet> get_starting_axes(int,
                                                             const std::vector<fastjet::PseudoJet>&,
                                                             const MeasureDefinition *) const;
  virtual std::string short_description() const;
   virtual std::string description() const;
   virtual Manual_Axes* create() const;
};

class OnePass_Manual_Axes : public Manual_Axes {
public:
   OnePass_Manual_Axes();
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual OnePass_Manual_Axes* create() const;
};

class MultiPass_Axes : public KT_Axes {
public:
   MultiPass_Axes(unsigned int Npass);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual MultiPass_Axes* create() const;
};

class MultiPass_Manual_Axes : public Manual_Axes {
public:
   MultiPass_Manual_Axes(unsigned int Npass);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual MultiPass_Manual_Axes* create() const;   
};

class Comb_GenKT_Axes : public ExclusiveCombinatorialJetAxes {
public:
   Comb_GenKT_Axes(int nExtra, double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual Comb_GenKT_Axes* create() const;
// private:
//    double _nExtra;   ///< Number of extra axes
//    double _p;        ///< GenkT power
//    double _R0;       ///< jet radius
};

class Comb_WTA_GenKT_Axes : public ExclusiveCombinatorialJetAxes {
public:
   Comb_WTA_GenKT_Axes(int nExtra, double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual Comb_WTA_GenKT_Axes* create() const;
// private:
//    double _nExtra;   ///< Number of extra axes
//    double _p;        ///< GenkT power
//    double _R0;       ///< jet radius
};

class Comb_GenET_GenKT_Axes : public ExclusiveCombinatorialJetAxes {
public:
   Comb_GenET_GenKT_Axes(int nExtra, double delta, double p, double R0 = fastjet::JetDefinition::max_allowable_R);
   virtual std::string short_description() const;
   virtual std::string description() const;
   virtual Comb_GenET_GenKT_Axes* create() const;
// private:
//    double _nExtra;   ///< Number of extra axes
//    double _delta;    ///< Recombination pT weighting exponent
//    double _p;        ///< GenkT power
//    double _R0;       ///< jet radius
};
   