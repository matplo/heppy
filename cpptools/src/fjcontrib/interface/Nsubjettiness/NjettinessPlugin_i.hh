#include <fastjet/config.h>

#include "Njettiness.hh"
#include "MeasureDefinition.hh"
#include "AxesDefinition.hh"
#include "TauComponents.hh"

#include "fastjet/ClusterSequence.hh"
#include "fastjet/JetDefinition.hh"

#include <string>
#include <climits>

class NjettinessPlugin : public JetDefinition::Plugin {
public:
   /// Constructor with same arguments as Nsubjettiness (N, AxesDefinition, MeasureDefinition)
   NjettinessPlugin(int N,
                    const AxesDefinition & axes_def,
                    const MeasureDefinition & measure_def);
   virtual std::string description () const;
   virtual double R() const;
   virtual void run_clustering(ClusterSequence&) const;
   void setAxes(const std::vector<fastjet::PseudoJet> & myAxes);
   virtual ~NjettinessPlugin();

// private:
//    Njettiness _njettinessFinder;  ///< The core Njettiness that does the heavy lifting
//    int _N;  ///< Number of exclusive jets to find.
//    /// Warning if the user tries to use v1.0.3 constructor.
//    static LimitedWarning _old_constructor_warning;
   
public:
   NjettinessPlugin(int N,
                    Njettiness::AxesMode axes_mode,
                    Njettiness::MeasureMode measure_mode);
      NjettinessPlugin(int N,
                    Njettiness::AxesMode axes_mode,
                    Njettiness::MeasureMode measure_mode,
                    double para1);
   NjettinessPlugin(int N,
                    Njettiness::AxesMode axes_mode,
                    Njettiness::MeasureMode measure_mode,
                    double para1,
                    double para2);
   NjettinessPlugin(int N,
                    Njettiness::AxesMode axes_mode,
                    Njettiness::MeasureMode measure_mode,
                    double para1,
                    double para2,
                    double para3);
   NjettinessPlugin(int N,
                    Njettiness::AxesMode mode,
                    double beta,
                    double R0,
                    double Rcutoff=std::numeric_limits<double>::max());
};
