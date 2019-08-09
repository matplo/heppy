%module hepmc2wrap

%{
  #include "HepMC/GenEvent.h"
  #include "HepMC/GenVertex.h"
  #include "HepMC/GenParticle.h"
  #include "HepMC/IO_GenEvent.h"
  #include "HepMC/SimpleVector.h"
  // #ifdef HEPMC_HAS_ITERATOR_RANGES
  // #include "HepMC/GenEventIterators.h"
  // #endif
  #include <sstream>
  using namespace HepMC;
  using namespace std;

  std::vector<HepMC::GenParticle*> _fsParticles(const HepMC::GenEvent& evt) {
    std::vector<HepMC::GenParticle*> fsps;
    for (HepMC::GenEvent::particle_const_iterator p = evt.particles_begin(); p != evt.particles_end(); ++p) {
      if (!(*p)->end_vertex() && (*p)->status() == 1) {
        fsps.push_back(*p);
      }
    }
    return fsps;
  }

//MP add
  #include  "readfile.hh"
  #include  "statfile.hh"
%}


// Suppress SWIG warning about inner classes.
#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS


// Ignore iterators, stream operators, etc.
namespace HepMC {
  // In GenEvent
  %ignore GenEvent::particle_range;
  %ignore GenEvent::vertex_range;
  //
  %ignore GenEvent::particles_begin;
  %ignore GenEvent::particles_end;
  %ignore GenEvent::vertices_begin;
  %ignore GenEvent::vertices_end;
  %ignore GenEvent::operator=;
  %ignore GenEvent::print(std::ostream& ostr) const;
  %rename(as_str) GenEvent::print() const;

  // In GenVertex
  %ignore GenVertex::particles;
  %ignore GenVertex::particles_in;
  %ignore GenVertex::particles_out;
  %ignore GenVertex::particles_in_const_begin;
  %ignore GenVertex::particles_in_const_end;
  %ignore GenVertex::particles_out_const_begin;
  %ignore GenVertex::particles_out_const_end;
  %ignore GenVertex::particles_begin;
  %ignore GenVertex::particles_end;
  %ignore GenVertex::vertices_begin;
  %ignore GenVertex::vertices_end;
  %ignore GenVertex::operator=;
  %ignore GenVertex::print;
  %rename(to_vec3) GenVertex::operator HepMC::ThreeVector;
  %rename(to_vec4) GenVertex::operator HepMC::FourVector;

  // In GenParticle
  %ignore GenParticle::particles_in;
  %ignore GenParticle::particles_out;
  %ignore GenParticle::operator=;
  %ignore GenParticle::print;
  %rename(to_vec4) GenParticle::operator HepMC::FourVector;

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


// Order is important --- no chaining occurs! Import declaration
// headers before importing headers that use those classes.
// Result is that headers should probably be %included in an order
// which sees "contents before containers"
%include "HepMC/HepMCDefs.h"
%include "HepMC/SimpleVector.h"
// #ifdef HEPMC_HAS_ITERATOR_RANGES
// %include "HepMC/GenEventIterators.h"
// #endif
%include "HepMC/GenParticle.h"
%include "HepMC/GenVertex.h"
%include "HepMC/GenEvent.h"
%include "HepMC/IO_BaseClass.h"
%include "HepMC/IO_GenEvent.h"

//MP add
%include  "readfile.hh"
%include  "statfile.hh"

// Templates
%template(GenParticleVector) std::vector<HepMC::GenParticle*>;
%template(cGenParticleVector) std::vector<const HepMC::GenParticle*>;
%template(GenVertexVector) std::vector<HepMC::GenVertex*>;
%template(cGenVertexVector) std::vector<const HepMC::GenVertex*>;
%template(GenParticlePair) std::pair<HepMC::GenParticle*, HepMC::GenParticle*>;
%template(cGenParticlePair) std::pair<const HepMC::GenParticle*, const HepMC::GenParticle*>;


%extend HepMC::IO_GenEvent {
  // Provide Python-style IO_GenEvent constructor
  IO_GenEvent(const std::string& filename, const std::string& mode) {
    if (filename == "-") {
      if (mode == "w") return new IO_GenEvent(std::cout);
      if (mode == "r") return new IO_GenEvent(std::cin);
    } else {
      if (mode == "w") return new IO_GenEvent(filename.c_str(), std::ios::out);
      if (mode == "r") return new IO_GenEvent(filename.c_str(), std::ios::in);
    }
    throw runtime_error("Tried to open an IO_GenEvent with an invalid mode string: " + mode);
    return 0;
  }

  // Provide event reader method with normal return.
  HepMC::GenEvent get_next_event() {
    HepMC::GenEvent rtn;
    $self->fill_next_event(&rtn);
    return rtn;
  }

  // // Provide a way to get an event as a string
  // std::string event_as_string() {
  //   std::ostringstream ss;
  //   $self->print(ss);
  //   return ss.str();
  // }

  // // Check stream state
  // bool is_good() {
  //   if (m_istr) {
  //     return $self->m_istr->good();
  //   } else {
  //     return $self->m_ostr->good();
  //   }
  // }

  // // Check stream EOF state
  // bool is_eof() {
  //   if (m_istr) {
  //     return $self->m_istr->eof();
  //   } else {
  //     return $self->m_ostr->eof();
  //   }
  // }

}


%extend HepMC::GenEvent {
  std::string __str__() {
    std::ostringstream ss;
    $self->print(ss);
    return ss.str();
  }
  std::string summary() {
    std::ostringstream ss;
    ss << "HepMC::GenEvent { "
       << $self->particles_size() << " particles "
       << "(" << _fsParticles(* $self).size() << " in FS), "
       << $self->vertices_size() << " vertices }";
    return ss.str();
  }

  // void dump() {
  // }

  std::vector<HepMC::GenParticle*> particles() {
    return std::vector<HepMC::GenParticle*>($self->particles_begin(), $self->particles_end());
  }
  std::vector<HepMC::GenVertex*> vertices() {
    return std::vector<HepMC::GenVertex*>($self->vertices_begin(), $self->vertices_end());
  }
  std::vector<HepMC::GenParticle*> fsParticles() {
    return _fsParticles(* $self);
  }
}


%extend HepMC::GenParticle {
  std::string __str__() const {
    std::stringstream ss;
    HepMC::FourVector p = $self->momentum();
    ss << "HepMC::GenParticle { "
       << $self->pdg_id() << "; p = ("
       << p.t() << "; "
       << p.x() << ", "
       << p.y() << ", "
       << p.z() << ") "
       << "}";
    return ss.str();
  }
}


%extend HepMC::GenVertex {
  std::string __str__() const {
    std::stringstream ss;
    HepMC::FourVector p = $self->position();
    ss << "HepMC::GenVertex { "
       << "("
       << p.t() << "; "
       << p.x() << ", "
       << p.y() << ", "
       << p.z() << ") "
       << "}";
    return ss.str();
  }

  std::vector<const HepMC::GenParticle*> particles_in() const {
    return vector<const GenParticle*>($self->particles_in_const_begin(), $self->particles_in_const_end());
  }
  std::vector<const HepMC::GenParticle*> particles_out() const {
    return vector<const HepMC::GenParticle*>($self->particles_out_const_begin(), $self->particles_out_const_end());
  }
  std::vector<HepMC::GenParticle*> particles(HepMC::IteratorRange range=relatives) {
    return vector<HepMC::GenParticle*>($self->particles_begin(range), $self->particles_end(range));
  }
  std::vector<HepMC::GenVertex*> vertices(HepMC::IteratorRange range=relatives) {
    return vector<HepMC::GenVertex*>($self->vertices_begin(range), $self->vertices_end(range));
  }
}


%extend HepMC::FourVector {
  std::string __str__() {
    std::stringstream ss;
    ss //<< "HepMC::FourVector { "
       << "("
       << $self->t() << "; "
       << $self->x() << ", "
       << $self->y() << ", "
       << $self->z() << ")";
      //<< " }";
    return ss.str();
  }
}
