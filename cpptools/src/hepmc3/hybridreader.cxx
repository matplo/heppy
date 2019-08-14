#include "hybridreader.hh"

#include <iostream>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>

#include <HepMC3/GenParticle.h>

std::vector<HepMC3::GenParticle> HybridRead::HepMCParticles()
{
  std::vector<HepMC3::GenParticle> retv;
  for (unsigned int i = 0; i < fParticles.size(); i++)
  {
    HepMC3::GenParticle p({fParticles[i][3], fParticles[i][4], fParticles[i][5], fParticles[i][6]}, fParticles[i][2], fParticles[i][8]);
    retv.push_back(p);
  }
  return retv;
}

HybridRead::HybridRead()
  : fFileName("")
  , fStream()
  , fNevent(0)
  , fParticles()
  , fVertices()
  , fEventInfo()
  , fCurrentPositionInFile()
{
  ;
}  

HybridRead::HybridRead(const char *fname)
  : fFileName(fname)
  , fStream()
  , fNevent(0)
  , fParticles()
  , fVertices()
  , fEventInfo()
  , fCurrentPositionInFile()
{
  openFile(fname);
}

bool HybridRead::openFile(const char *fname)
{
  fFileName = fname;
  fNevent = 0;

  fStream.close();
  fStream.open(fFileName);

  fParticles.clear();
  fVertices.clear();
  fEventInfo.clear();

  if ( fStream.rdstate() == std::ios::failbit )
  {
    std::cerr << "HybridRead: Unable to read from: " << fname << std::endl;
  }
  return (fStream.rdstate() != std::ios::failbit);
}

bool HybridRead::failed()
{
  return (!fStream.good());
  // return (fStream.rdstate() == std::ios::failbit);
}

int HybridRead::getNevent()
{
  return fNevent;
}

std::vector<std::string> tokenize(std::string s)
{
  std::istringstream iss(s);
  std::vector<std::string> tokens{std::istream_iterator<std::string>{iss}, std::istream_iterator<std::string>{}};
  return tokens;
}

bool HybridRead::nextEvent()
{
    if (!fStream.good())
    {
      std::cerr << "stream no good..." << std::endl;
      return false;
    }

    fParticles.clear();
    fVertices.clear();
    fEventInfo.clear();

    std::string line;
    while (fStream.good())
    {
        line = "";
        std::getline(fStream, line);
        // std::cout << line << std::endl;
        if (failed())
        {
          return false;
        }
        if (line.find("HepMC::Asciiv3-END_EVENT_LISTING", 0) != std::string::npos)
        {
          if (fNevent > 0 && fEventInfo.size() > 0)
          {
            // std::cout << "End of LISTING!" << std::endl;
            return true;
          }
          return false;
        }
        if (line.find("HepMC::", 0) != std::string::npos)
        {
          continue;
        }
        auto tokens = tokenize(line);
        if (tokens.size() < 2)
        {
          //std::cerr << "strange line with less than 1 token " << line << std::endl;
          continue;
        }
        if (tokens[0] == "E")
        {
          // new event
          if (fNevent > 0 && fEventInfo.size() > 0)
          {
            // std::cout << line << std::endl;
            // fStream.seekg(fCurrentPositionInFile);
            return true;
          }
          fNevent++;    
        }
        std::vector<double> part;
        std::vector<double> vert;
        for (unsigned int i = 1; i < tokens.size(); i++)
        {
          double v = 0;
          try
          {
            v = std::stod(tokens[i]);
          }
          catch (const std::exception& e)
          {
            v = 0;
          }
          if (tokens[0] == "E")
          {
            // new event
            fEventInfo.push_back(v);
          }
          if (tokens[0] == "W")
          {
            // event weight              
            fEventInfo.push_back(v);
          }
          if (tokens[0] == "P")
          {
            // new particle 
            part.push_back(v);
          }
          if (tokens[0] == "V")
          {
            // new particle 
            vert.push_back(v);
          }
          if (tokens[0] == "A")
          {
            // new info
            fEventInfo.push_back(v);
          }              
          if (tokens[0] == "U")
          {
            // new info
          }              
        }
        if (tokens[0] == "P")
        {
          fParticles.push_back(part);
        }
        if (tokens[0] == "V")
        {
          fVertices.push_back(vert);
        }
        // std::streampos fCurrentPositionInFile = fStream.tellg();
    } // while line
  return false;
}

std::vector<double> HybridRead::getEventInfo()
{
  return fEventInfo;
}

std::vector<double> HybridRead::getParticle(int i)
{
  if (i >= fParticles.size())
  {
    std::cerr << "asking for a particle beyond size !" << i << " out of " << fParticles.size() << std::endl;
  }
  return fParticles[i];
}

unsigned int HybridRead::getNparticles()
{
  return fParticles.size();
}

std::vector<double> HybridRead::getVertex(int i)
{
  if (i >= fVertices.size())
  {
    std::cerr << "asking for a vertex beyond size !" << i << " out of " << fVertices.size() << std::endl;
  }
  return fVertices[i];
}

unsigned int HybridRead::getNvertices()
{
  return fVertices.size();
}
