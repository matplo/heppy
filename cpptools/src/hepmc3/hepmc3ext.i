%module hepmc3ext
%include "std_string.i"
%include "std_vector.i"
namespace std {
   %template(IntVector) vector<int>;
   %template(DoubleVector) vector<double>;
}
%include "typemaps.i"
%{
	#define SWIG_FILE_WITH_INIT
	#include "test_loop.hh"
	#include "HepMC3/GenParticle.h"
	#include "HepMC3/FourVector.h"
    using namespace HepMC3;
	#include "hybridreader.hh"
%}

%include "../numpy.i"
%init %{
	import_array();
%}
%fragment("NumPy_Fragments");

// Suppress SWIG warning about inner classes.
#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS

// Ignore iterators, stream operators, etc.
namespace HepMC3 {
  // In GenParticle
  %ignore GenParticle::particles_in;
  %ignore GenParticle::particles_out;
  %ignore GenParticle::operator=;
  %ignore GenParticle::print;
  %rename(to_vec4) GenParticle::operator HepMC3::FourVector;

  // In IO classes
  %ignore IO_BaseClass::print;
  %ignore IO_GenEvent::print;

  // In vectors
  %ignore FourVector::operator=;
  %ignore ThreeVector::operator=;

  // Stream ops
  %ignore IO_BaseClass::operator<<;
  %ignore operator<<;
}
%ignore operator<<;

// Declare STL mappings
%include "std_string.i"
%include "std_vector.i"
%include "std_map.i"
%include "std_pair.i"

%include "HepMC3/GenParticle.h"
%include "HepMC3/FourVector.h"
%template(VectorGenParticle) std::vector<HepMC3::GenParticle>;

%include "test_loop.hh"
%include "hybridreader.hh"

%extend HepMC3::GenParticle {
  std::string __str__() const {
    std::stringstream ss;
    HepMC3::FourVector p = $self->momentum();
    ss << "HepMC3::GenParticle { "
       << $self->pdg_id() << "; p = ("
       << p.x() << ", "
       << p.y() << ", "
       << p.z() << "; "
       << p.t() << ") "
       << "}";
    return ss.str();
  }
  HepMC3::FourVector getMomentum() const {
  	return $self->momentum();
  }
}

%extend HepMC3::FourVector {
  std::string __str__() {
    std::stringstream ss;
    ss //<< "HepMC3::FourVector { "
       << "("
       << $self->x() << ", "
       << $self->y() << ", "
       << $self->z() << "; "
       << $self->t() << ")";
      //<< " }";
    return ss.str();
  }
}
