#include <fastjet/internal/base.hh>

#include "Njettiness.hh"

#include "fastjet/FunctionOfPseudoJet.hh"
#include <string>
#include <climits>

class Nsubjettiness;
class NsubjettinessRatio;
   
class Nsubjettiness : public FunctionOfPseudoJet<double> {
public:
   Nsubjettiness(int N,
                 const AxesDefinition& axes_def,
                 const MeasureDefinition& measure_def);
   double result(const fastjet::PseudoJet& jet) const;
   TauComponents component_result(const fastjet::PseudoJet& jet) const;
   void setAxes(const std::vector<fastjet::PseudoJet> & myAxes);
   std::vector<fastjet::PseudoJet> seedAxes() const;
   std::vector<fastjet::PseudoJet> currentAxes() const;
   std::vector<fastjet::PseudoJet> currentSubjets() const;
   TauComponents currentTauComponents() const;
   TauPartition currentPartition() const;

// private:   
//    /// Core Njettiness code that is called
//    Njettiness _njettinessFinder; // TODO:  should muck with this so result can be const without this mutable
//    /// Number of subjets to find
//    int _N;   
//    /// Warning if the user tries to use v1.0.3 constructor.
//    static LimitedWarning _old_constructor_warning;

public:
   Nsubjettiness(int N,
                 Njettiness::AxesMode axes_mode,
                 Njettiness::MeasureMode measure_mode);
   Nsubjettiness(int N,
                 Njettiness::AxesMode axes_mode,
                 Njettiness::MeasureMode measure_mode,
                 double para1);
   Nsubjettiness(int N,
                 Njettiness::AxesMode axes_mode,
                 Njettiness::MeasureMode measure_mode,
                 double para1,
                 double para2);
   Nsubjettiness(int N,
                 Njettiness::AxesMode axes_mode,
                 Njettiness::MeasureMode measure_mode,
                 double para1,
                 double para2,
                 double para3);
   Nsubjettiness(int N,
                 Njettiness::AxesMode axes_mode,
                 double beta,
                 double R0,
                 double Rcutoff=std::numeric_limits<double>::max());
};


class NsubjettinessRatio : public FunctionOfPseudoJet<double> {
public:
   NsubjettinessRatio(int N,
                      int M,
                      const AxesDefinition & axes_def,
                      const MeasureDefinition & measure_def);
   double result(const PseudoJet& jet) const;

// private: 
//    Nsubjettiness _nsub_numerator;   ///< Function for numerator
//    Nsubjettiness _nsub_denominator; ///< Function for denominator

public:
   NsubjettinessRatio(int N,
                      int M,
                      Njettiness::AxesMode axes_mode,
                      Njettiness::MeasureMode measure_mode);
   NsubjettinessRatio(int N,
                      int M,
                      Njettiness::AxesMode axes_mode,
                      Njettiness::MeasureMode measure_mode,
                      double para1);
   NsubjettinessRatio(int N,
                      int M,
                      Njettiness::AxesMode axes_mode,
                      Njettiness::MeasureMode measure_mode,
                      double para1,
                      double para2);
   NsubjettinessRatio(int N,
                      int M,
                      Njettiness::AxesMode axes_mode,
                      Njettiness::MeasureMode measure_mode,
                      double para1,
                      double para2,
                      double para3);
};
