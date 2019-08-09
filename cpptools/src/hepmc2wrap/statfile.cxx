#include "statfile.hh"
#include "readfile.hh"

#include <iostream>

int statfile(const char *fname, bool quiet)
{
	std::cout << "[i] reading from " << fname << std::endl;
	GenUtil::ReadHepMCFile f(fname);
	int nevents = 0;
	while (f.NextEvent())
	{
		if (!quiet) std::cout << " - number of particles:" << f.HepMCParticles(false).size() << std::endl;
		if (!quiet) std::cout << " - number of final particles:" << f.HepMCParticles(true).size() << std::endl;
		nevents++;
	}
	if (!quiet) std::cout << "[i] number of events read: " << nevents << std::endl;
	return nevents;
};

