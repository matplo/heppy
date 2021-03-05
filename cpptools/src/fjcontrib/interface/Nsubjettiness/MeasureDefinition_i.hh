#include <cmath>
#include <vector>
#include <list>
#include <limits>

#include "TauComponents.hh"

class MeasureDefinition {   
public:
   virtual std::string description() const;
   virtual MeasureDefinition* create() const;
   virtual double jet_distance_squared(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_distance_squared(const fastjet::PseudoJet& particle) const;
   virtual double jet_numerator(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_numerator(const fastjet::PseudoJet& particle) const;
   virtual double denominator(const fastjet::PseudoJet& particle) const;
   virtual std::vector<fastjet::PseudoJet> get_one_pass_axes(int n_jets,
                                                             const std::vector<fastjet::PseudoJet>& inputs,
                                                             const std::vector<fastjet::PseudoJet>& seedAxes,
                                                             int nAttempts = 1000,         // cap number of iterations
                                                             double accuracy = 0.0001      // cap distance of closest approach
   ) const;
   double result(const std::vector<fastjet::PseudoJet>& particles, const std::vector<fastjet::PseudoJet>& axes) const;
   inline double operator() (const std::vector<fastjet::PseudoJet>& particles, const std::vector<fastjet::PseudoJet>& axes) const;
   TauComponents component_result(const std::vector<fastjet::PseudoJet>& particles, const std::vector<fastjet::PseudoJet>& axes) const;
   TauPartition get_partition(const std::vector<fastjet::PseudoJet>& particles, const std::vector<fastjet::PseudoJet>& axes) const;
   TauComponents component_result_from_partition(const TauPartition& partition, const std::vector<fastjet::PseudoJet>& axes) const;
   virtual ~MeasureDefinition();
   TauMode _tau_mode;
   bool _useAxisScaling;
   MeasureDefinition();
   void setTauMode(TauMode tau_mode);
   void setAxisScaling(bool useAxisScaling);
   bool has_denominator() const;
   bool has_beam() const;
   fastjet::PseudoJet lightFrom(const fastjet::PseudoJet& input) const;
   static inline double sq(double x);
};
   

enum DefaultMeasureType {
   pt_R,       ///  use transverse momenta and boost-invariant angles,
   E_theta,    ///  use energies and angles,
   lorentz_dot, ///  use dot product inspired measure
   perp_lorentz_dot /// use conical geometric inspired measures
};

class LightLikeAxis {
public:
   LightLikeAxis();
   LightLikeAxis(double my_rap, double my_phi, double my_weight, double my_mom);
   double rap() const;
   double phi() const;
   double weight() const;
   double mom() const;
   void set_rap(double my_set_rap);
   void set_phi(double my_set_phi);
   void set_weight(double my_set_weight);
   void set_mom(double my_set_mom);
   void reset(double my_rap, double my_phi, double my_weight, double my_mom);
   fastjet::PseudoJet ConvertToPseudoJet();
   double DistanceSq(const fastjet::PseudoJet& input) const;
   double Distance(const fastjet::PseudoJet& input) const;
   double DistanceSq(const LightLikeAxis& input) const;
   double Distance(const LightLikeAxis& input) const;
};

class DefaultMeasure : public MeasureDefinition {
   public:
   virtual std::string description() const;
   virtual DefaultMeasure* create() const;
   virtual double jet_distance_squared(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_distance_squared(const fastjet::PseudoJet& /*particle*/) const;
   virtual double jet_numerator(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_numerator(const fastjet::PseudoJet& particle) const;
   virtual double denominator(const fastjet::PseudoJet& particle) const;
   virtual std::vector<fastjet::PseudoJet> get_one_pass_axes(int n_jets,
                                                             const std::vector<fastjet::PseudoJet>& inputs,
                                                             const std::vector<fastjet::PseudoJet>& seedAxes,
                                                             int nAttempts,   // cap number of iterations
                                                             double accuracy  // cap distance of closest approach
                                                             ) const;
   DefaultMeasure(double beta, double R0, double Rcutoff, DefaultMeasureType measure_type = pt_R);
   void setDefaultMeasureType(DefaultMeasureType measure_type);
   double energy(const PseudoJet& jet) const;
   double angleSquared(const PseudoJet& jet1, const PseudoJet& jet2) const;
   std::string measure_type_name() const;
   template <int N> std::vector<LightLikeAxis> UpdateAxesFast(const std::vector <LightLikeAxis> & old_axes,
                                                              const std::vector <fastjet::PseudoJet> & inputJets,
                                                              double accuracy) const;
   std::vector<LightLikeAxis> UpdateAxes(const std::vector <LightLikeAxis> & old_axes,
                                         const std::vector <fastjet::PseudoJet> & inputJets,
                                         double accuracy) const;
};
   

class NormalizedCutoffMeasure : public DefaultMeasure {
public:
   NormalizedCutoffMeasure(double beta, double R0, double Rcutoff, DefaultMeasureType measure_type = pt_R);
   virtual std::string description() const;
   virtual NormalizedCutoffMeasure* create() const;
};

class NormalizedMeasure : public NormalizedCutoffMeasure {
public:
   NormalizedMeasure(double beta, double R0, DefaultMeasureType measure_type = pt_R);
   virtual std::string description() const;
   virtual NormalizedMeasure* create() const;
};
   
class UnnormalizedCutoffMeasure : public DefaultMeasure {   
public:
   UnnormalizedCutoffMeasure(double beta, double Rcutoff, DefaultMeasureType measure_type = pt_R);
   virtual std::string description() const;
   virtual UnnormalizedCutoffMeasure* create() const;

};

   
class UnnormalizedMeasure : public UnnormalizedCutoffMeasure {   
public:
   UnnormalizedMeasure(double beta, DefaultMeasureType measure_type = pt_R);
   virtual std::string description() const;
   virtual UnnormalizedMeasure* create() const;
};

class ConicalMeasure : public MeasureDefinition {   
public:
   ConicalMeasure(double beta, double Rcutoff);
   virtual std::string description() const;
   virtual ConicalMeasure* create() const;
   virtual double jet_distance_squared(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_distance_squared(const fastjet::PseudoJet&  /*particle*/) const;
   virtual double jet_numerator(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_numerator(const fastjet::PseudoJet& particle) const;
   virtual double denominator(const fastjet::PseudoJet&  /*particle*/) const;
};
   

class OriginalGeometricMeasure : public MeasureDefinition {
public:
   OriginalGeometricMeasure(double Rcutoff);
   virtual std::string description() const;
   virtual OriginalGeometricMeasure* create() const;
   virtual double jet_numerator(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_numerator(const fastjet::PseudoJet& particle) const;
   virtual double denominator(const fastjet::PseudoJet&  /*particle*/) const;
};


class ModifiedGeometricMeasure : public MeasureDefinition {
public:
   ModifiedGeometricMeasure(double Rcutoff);
   virtual std::string description() const;
   virtual ModifiedGeometricMeasure* create() const;
   virtual double jet_numerator(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_numerator(const fastjet::PseudoJet& particle) const;
   virtual double denominator(const fastjet::PseudoJet&  /*particle*/) const;
};

class ConicalGeometricMeasure : public MeasureDefinition {
public:
   ConicalGeometricMeasure(double jet_beta, double beam_gamma, double Rcutoff);
   virtual std::string description() const;
   virtual ConicalGeometricMeasure* create() const;
   virtual double jet_distance_squared(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_distance_squared(const fastjet::PseudoJet&  /*particle*/) const;
   virtual double jet_numerator(const fastjet::PseudoJet& particle, const fastjet::PseudoJet& axis) const;
   virtual double beam_numerator(const fastjet::PseudoJet& particle) const;
   virtual double denominator(const fastjet::PseudoJet&  /*particle*/) const;
};

class XConeMeasure : public ConicalGeometricMeasure {
public:
   XConeMeasure(double jet_beta, double R);
   virtual std::string description() const;
   virtual XConeMeasure* create() const;
};
