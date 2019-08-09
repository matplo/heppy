#include "readfile.hh"

#include <HepMC/IO_GenEvent.h>
#include <HepMC/GenEvent.h>
#include <HepMC/GenCrossSection.h>
#include <HepMC/PdfInfo.h>
#include <HepMC/WeightContainer.h>

#include <algorithm>
#include <list>

#include <iostream>
using namespace std;

namespace GenUtil
{
	//useful code from
	// $HEPMCDIR/share/HepMC/examples/example_UsingIterators.cc
	// and
	// $HEPMCDIR/share/HepMC/examples/example_EventSelection.cc

	/// \class  IsStateFinal
	/// this predicate returns true if the input has no decay vertex
	class IsStateFinal
	{
	public:
		/// returns true if the GenParticle does not decay
		bool operator()( const HepMC::GenParticle* p )
		{
			if ( !p->end_vertex() && p->status()==1 )
				return 1;
			return 0;
		}
	};

	ReadHepMCFile::ReadHepMCFile(const char *fname)
		: fIn(fname, std::ios::in)
		, fEvent(0x0)
		, fCurrentEvent(0)
	{
		if ( fIn.rdstate() == std::ios::failbit )
		{
			cerr << "Unable to read from: " << fname << endl;
		}
	}

	bool ReadHepMCFile::failed()
	{
		return ( fIn.rdstate() == std::ios::failbit );
	}

	ReadHepMCFile::~ReadHepMCFile()
	{

	}

	HepMC::GenCrossSection* ReadHepMCFile::GetCrossSecion()
	{
		if (fEvent) return fEvent->cross_section();
		cerr << "No event - unable to read cross section" << endl;
		return 0x0;
	}

	HepMC::PdfInfo* ReadHepMCFile::GetPDFinfo()
	{
		if (fEvent) return fEvent->pdf_info();
		cerr << "No event - unable to read PDF info" << endl;
		return 0x0;
	}

	HepMC::WeightContainer* ReadHepMCFile::GetWeightContainer()
	{
		if (fEvent) return &(fEvent->weights());
		cerr << "No event - unable to read PDF info" << endl;
		return 0x0;
	}

	bool ReadHepMCFile::ReadHepMCFile::NextEvent()
	{
		fVertices.clear();
		fParticles.clear();

		if (fEvent)
			delete fEvent;

		fEvent = fIn.read_next_event();
		if (!fEvent)
			return false;

		fCurrentEvent++;
		return true;
	}

	std::list<HepMC::GenVertex*> ReadHepMCFile::Vertices()
	{
		fVertices.clear();
		if (!fEvent)
			cerr << "No event - unable to read vertices..." << endl;
		for ( HepMC::GenEvent::vertex_iterator v = fEvent->vertices_begin(); v != fEvent->vertices_end(); ++v )
		{
			fVertices.push_back(*v);
		}
		return fVertices;
	}

	std::vector<HepMC::GenParticle*> ReadHepMCFile::HepMCParticles(bool only_final)
	{
		fParticles.clear();
		if (!fEvent)
			cerr << "No event - unable to read particles..." << endl;
		for ( HepMC::GenEvent::particle_iterator p = fEvent->particles_begin();
			p != fEvent->particles_end(); ++p )
		{
			HepMC::GenParticle* pmc = *p;
			if (only_final)
			{
				if ( !pmc->end_vertex() && pmc->status() == 1 )
				{
					fParticles.push_back(pmc);
				}
			}
			else
			{
				fParticles.push_back(pmc);
			}
		}
		return fParticles;
	}
}
