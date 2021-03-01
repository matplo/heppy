#include <fastjet/config.h>

#include "NjettinessPlugin.hh"

#include "fastjet/ClusterSequence.hh"
#include "fastjet/JetDefinition.hh"

#include <string>
#include <climits>

class XConePlugin : public NjettinessPlugin {
public:
   XConePlugin(int N, double R0, double beta = 2.0);
   virtual std::string description () const;
   virtual double R() const;
   virtual ~XConePlugin();

// private:
//    static double calc_delta(double beta);
//    static double calc_power(double beta);
//    double _N;    ///< Number of desired jets
//    double _R0;   ///< Jet radius
//    double _beta; ///< Angular exponent (beta = 2.0 is dafault, beta = 1.0 is recoil-free)

// public:

};

class PseudoXConePlugin : public NjettinessPlugin {
public:
   PseudoXConePlugin(int N, double R0, double beta = 2.0);
   virtual std::string description () const;
   virtual double R() const;   
   // run_clustering is done by NjettinessPlugin
   virtual ~PseudoXConePlugin();
  
// private:   
//    static double calc_delta(double beta);   
//    /// Static call used within the constructor to set the recommended p value
//    static double calc_power(double beta);
//    double _N;    ///< Number of desired jets
//    double _R0;   ///< Jet radius
//    double _beta; ///< Angular exponent (beta = 2.0 is dafault, beta = 1.0 is recoil-free)
   
// public:
   
};
