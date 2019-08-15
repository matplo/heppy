#ifndef HEPPY_HEPMC3_HYBRID_READ_HH
#define HEPPY_HEPMC3_HYBRID_READ_HH

#include <string>
#include <vector>
#include <fstream>

#include <HepMC3/GenParticle.h>

class HybridRead
{
public:
	HybridRead();
	HybridRead(const char *fname);
	virtual ~HybridRead();
	virtual bool nextEvent();
	bool openFile(const char *fname);
	bool failed();
	int  getNevent();
	// std::vector<std::vector<double>> getParticles();
	std::vector<double> getEventInfo();
	std::vector<double> getParticle(int i);
	unsigned int getNparticles();
	std::vector<double> getVertex(int i);
	unsigned int getNvertices();
	virtual std::vector<HepMC3::GenParticle> HepMCParticles();
protected:
	std::string 		fFileName;
	std::ifstream 		fStream;
	int 				fNevent;
	std::vector<std::vector<double>> fParticles;
	std::vector<std::vector<double>> fVertices;
	std::vector<double> fEventInfo;
	std::streampos      fCurrentPositionInFile;
};

class YuukaRead : public HybridRead
{
public:
	YuukaRead();
	YuukaRead(const char *fname);
	virtual ~YuukaRead();
	virtual bool nextEvent();
	virtual std::vector<HepMC3::GenParticle> HepMCParticles();
};

#endif
