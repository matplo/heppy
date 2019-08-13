#ifndef __HEPPY_HEPMCUTIL_READFILE__hh
#define __HEPPY_HEPMCUTIL_READFILE__hh

#include <HepMC/IO_GenEvent.h>
#include <HepMC/GenEvent.h>

#include <vector>
#include <list>

namespace GenUtil
{
	class ReadHepMCFile
	{
	public:
		ReadHepMCFile(const char *fname);
		virtual ~ReadHepMCFile();

		bool 								NextEvent();

		HepMC::GenCrossSection* 			GetCrossSecion();
		double 								GetCrossSecionValue();
		double 								GetCrossSecionValueError();

		HepMC::PdfInfo* 					GetPDFinfo();
		HepMC::WeightContainer*  			GetWeightContainer();
		std::list<HepMC::GenVertex*> 		Vertices();
		std::vector<HepMC::GenParticle*> 	HepMCParticles(bool only_final = true);

		long int 							CurrentEventNumber() { return fCurrentEvent;}

		HepMC::GenEvent* 					GetEvent() {return fEvent;}

		bool 								failed();

	private:
		HepMC::IO_GenEvent fIn;
		HepMC::GenEvent* fEvent;
		std::list<HepMC::GenVertex*> fVertices;
		std::vector<HepMC::GenParticle*> fParticles;
		long int fCurrentEvent;
	};
}

#endif
