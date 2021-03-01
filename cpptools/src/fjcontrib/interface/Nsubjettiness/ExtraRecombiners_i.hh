#include "fastjet/PseudoJet.hh"
#include "fastjet/JetDefinition.hh"

#include <cmath>
#include <vector>
#include <list>
#include <limits>
#include <stdio.h>
#include <string.h>
#include <errno.h>

class GeneralEtSchemeRecombiner : public fastjet::JetDefinition::Recombiner {
public:
   GeneralEtSchemeRecombiner(double delta);
   virtual std::string description() const;
   virtual void recombine(const fastjet::PseudoJet & pa,
                         const fastjet::PseudoJet & pb, 
                         fastjet::PseudoJet & pab) const;
};

class WinnerTakeAllRecombiner : public fastjet::JetDefinition::Recombiner {
public:
   WinnerTakeAllRecombiner(double alpha = 1.0);
   virtual std::string description() const;
   virtual void recombine(const fastjet::PseudoJet & pa,
                          const fastjet::PseudoJet & pb,
                          fastjet::PseudoJet & pab) const;
};
