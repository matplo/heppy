#include <cmath>
#include <vector>
#include <list>
#include <limits>

enum TauMode {
   UNDEFINED_SHAPE = -1, // Added so that constructor would default to some value
   UNNORMALIZED_JET_SHAPE = 0,
   NORMALIZED_JET_SHAPE = 1,
   UNNORMALIZED_EVENT_SHAPE = 2,
   NORMALIZED_EVENT_SHAPE = 3,
};

class TauComponents {   
public:
   TauComponents();
   TauComponents(TauMode tau_mode,
                 const std::vector<double> & jet_pieces_numerator,
                 double beam_piece_numerator,
                 double denominator,
                 const std::vector<fastjet::PseudoJet> & jets,
                 const std::vector<fastjet::PseudoJet> & axes
                 );
   bool has_denominator() const;
   bool has_beam() const;
   double tau() const;
   const std::vector<double>& jet_pieces() const;
   double beam_piece() const;
   std::vector<double> jet_pieces_numerator() const;
   double beam_piece_numerator() const;
   double numerator() const;
   double denominator() const;
   fastjet::PseudoJet total_jet() const;
   const std::vector<PseudoJet>& jets() const;
   const std::vector<PseudoJet>& axes() const;

   class StructureType : public fastjet::WrappedStructure {
   public:
      StructureType(const fastjet::PseudoJet& j) :
         WrappedStructure(j.structure_shared_ptr());
      double tau_piece() const;
      double tau() const;
   };   
};

class TauPartition {
public:
   TauPartition();
   TauPartition(int n_jet);
   void push_back_jet(int jet_num, const fastjet::PseudoJet& part_to_add, int part_index);
   void push_back_beam(const fastjet::PseudoJet& part_to_add, int part_index);
   fastjet::PseudoJet jet(int jet_num) const;
   fastjet::PseudoJet beam() const;
   std::vector<fastjet::PseudoJet> jets() const;
   const std::list<int> & jet_list(int jet_num) const;
   const std::list<int> & beam_list() const;
   const std::vector<std::list<int> > & jets_list() const;   
};

   
class NjettinessExtras : public fastjet::ClusterSequence::Extras, public TauComponents {
   
public:
   /// Constructor
   NjettinessExtras(TauComponents tau_components,
                    std::vector<int> cluster_hist_indices)
   : TauComponents(tau_components), _cluster_hist_indices(cluster_hist_indices);
   double tau(const fastjet::PseudoJet& /*jet*/) const;
   double tau_piece(const fastjet::PseudoJet& jet) const;
   fastjet::PseudoJet axis(const fastjet::PseudoJet& jet) const;
   bool has_njettiness_extras(const fastjet::PseudoJet& jet) const;

   double totalTau() const;
   std::vector<double> subTaus() const;
   double totalTau(const fastjet::PseudoJet& /*jet*/) const;
   double subTau(const fastjet::PseudoJet& jet) const;
   double beamTau() const;
};
   
   
/// Helper function to find out what njettiness_extras are (from jet)
inline const NjettinessExtras * njettiness_extras(const fastjet::PseudoJet& jet);

/// Helper function to find out what njettiness_extras are (from ClusterSequence)
inline const NjettinessExtras * njettiness_extras(const fastjet::ClusterSequence& myCS);
