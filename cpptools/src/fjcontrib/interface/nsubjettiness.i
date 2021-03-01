%module nsubjettiness

%{
  #include <fastjet/PseudoJet.hh>
  #include <fastjet/FunctionOfPseudoJet.hh>
  #include "fastjet/ClusterSequence.hh"
  #include "fastjet/WrappedStructure.hh"

  #include <Nsubjettiness/TauComponents.hh>
  #include <Nsubjettiness/MeasureDefinition.hh>
  #include <Nsubjettiness/ExtraRecombiners.hh>
  #include <Nsubjettiness/AxesDefinition.hh>

  // #include <Nsubjettiness/Njettiness.hh>
  // #include <Nsubjettiness/NjettinessPlugin.hh>
  // #include <Nsubjettiness/Nsubjettiness.hh>
  // #include <Nsubjettiness/XConePlugin.hh>
%}

%include "std_string.i"
%include "std_vector.i"

namespace fastjet{
  namespace contrib{

  %include "Nsubjettiness/TauComponents_i.hh"
  %include "Nsubjettiness/MeasureDefinition_i.hh"
  %include "Nsubjettiness/ExtraRecombiners_i.hh"
  %include "Nsubjettiness/AxesDefinition_i.hh"

  // %include "Nsubjettiness/Njettiness.hh"
  // %include "Nsubjettiness/NjettinessPlugin.hh"
  // %include "Nsubjettiness/Nsubjettiness.hh"
  // %include "Nsubjettiness/XConePlugin.hh"
  } // namespace contrib
} // namespace fastjet
