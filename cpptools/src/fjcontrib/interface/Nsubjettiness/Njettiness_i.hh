#include "MeasureDefinition.hh"
#include "AxesDefinition.hh"
#include "TauComponents.hh"

#include "fastjet/PseudoJet.hh"
#include "fastjet/SharedPtr.hh"
#include <fastjet/LimitedWarning.hh>

#include <cmath>
#include <vector>
#include <list>

class Njettiness {
public:
   Njettiness(const AxesDefinition & axes_def, const MeasureDefinition & measure_def);
   ~Njettiness();
   void setAxes(const std::vector<fastjet::PseudoJet> & myAxes);
   TauComponents getTauComponents(unsigned n_jets, const std::vector<fastjet::PseudoJet> & inputJets) const;
   double getTau(unsigned n_jets, const std::vector<fastjet::PseudoJet> & inputJets) const;
   TauComponents currentTauComponents() const;
   std::vector<fastjet::PseudoJet> currentAxes() const;
   std::vector<fastjet::PseudoJet> seedAxes() const;
   std::vector<fastjet::PseudoJet> currentJets() const;
   fastjet::PseudoJet currentBeam() const;
   TauPartition currentPartition() const;

// private:   
//    /// AxesDefinition to use.  Implemented as SharedPtrs to avoid memory management headaches
//    SharedPtr<const AxesDefinition> _axes_def;
//    /// MeasureDefinition to use.  Implemented as SharedPtrs to avoid memory management headaches
//    SharedPtr<const MeasureDefinition> _measure_def;
//    // Information about the current information
//    // Defined as mutables, so user should be aware that these change when getTau is called.
//    // TODO:  These are not thread safe and should be fixed somehow
//    mutable TauComponents _current_tau_components; //automatically set to have components of 0; these values will be set by the getTau function call
//    mutable std::vector<fastjet::PseudoJet> _currentAxes; //axes found after minimization
//    mutable std::vector<fastjet::PseudoJet> _seedAxes; // axes used prior to minimization (if applicable)
//    mutable TauPartition _currentPartition; //partitioning information
//    /// Warning if the user tries to use v1.0.3 measure style.
//    static LimitedWarning _old_measure_warning;
//    /// Warning if the user tries to use v1.0.3 axes style.
//    static LimitedWarning _old_axes_warning;
   
public:
   
   enum AxesMode {
      kt_axes,             // exclusive kt axes
      ca_axes,             // exclusive ca axes
      antikt_0p2_axes,     // inclusive hardest axes with antikt-0.2
      wta_kt_axes,         // Winner Take All axes with kt
      wta_ca_axes,         // Winner Take All axes with CA
      onepass_kt_axes,     // one-pass minimization from kt starting point
      onepass_ca_axes,     // one-pass minimization from ca starting point
      onepass_antikt_0p2_axes,  // one-pass minimization from antikt-0.2 starting point
      onepass_wta_kt_axes, //one-pass minimization of WTA axes with kt
      onepass_wta_ca_axes, //one-pass minimization of WTA axes with ca
      min_axes,            // axes that minimize N-subjettiness (100 passes by default)
      manual_axes,         // set your own axes with setAxes()
      onepass_manual_axes  // one-pass minimization from manual starting point
   };
   
   enum MeasureMode {
      normalized_measure,           //default normalized measure
      unnormalized_measure,         //default unnormalized measure
      geometric_measure,            //geometric measure
      normalized_cutoff_measure,    //default normalized measure with explicit Rcutoff
      unnormalized_cutoff_measure,  //default unnormalized measure with explicit Rcutoff
      geometric_cutoff_measure      //geometric measure with explicit Rcutoff
   };
   
   Njettiness(AxesMode axes_mode, const MeasureDefinition & measure_def);
   Njettiness(AxesMode axes_mode,
              MeasureMode measure_mode,
              int num_para,
              double para1 = std::numeric_limits<double>::quiet_NaN(),
              double para2 = std::numeric_limits<double>::quiet_NaN(),
              double para3 = std::numeric_limits<double>::quiet_NaN());
   AxesDefinition* createAxesDef(AxesMode axes_mode) const;   
   MeasureDefinition* createMeasureDef(MeasureMode measure_mode, int num_para, double para1, double para2, double para3) const;
};
