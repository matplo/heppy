find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
  else(Python3_FOUND)
    message(FATAL_ERROR "${Red}Python not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)

find_package(SWIG REQUIRED)
if (SWIG_FOUND)
    message(STATUS "${Green}SWIG ver. ${SWIG_VERSION} found.${ColourReset}")
  else(SWIG_FOUND)
    message(FATAL_ERROR "${Red}SWIG not found while it is the key package here...${ColourReset}")
endif(SWIG_FOUND)

include(ProcessorCount)
ProcessorCount(NCPU)

find_package(FastJet 3.0 REQUIRED)
if (NOT FASTJET_FOUND)
  message(STATUS "${Yellow}Hint: build FJ with ${CMAKE_CURRENT_SOURCE_DIR}/fastjet/build.sh ${ColourReset}")
  message(SEND_ERROR "${Red}FASTJET not found.${ColourReset}")
endif(NOT FASTJET_FOUND)

find_package(LHAPDF QUIET)

find_package(HepMC QUIET COMPONENTS HepMC)

find_package(HepMC3 QUIET COMPONENTS HepMC)
if (HEPMC3_FOUND)
  if (${HEPMC3_VERSION_MINOR} GREATER "0")
    # message( STATUS "HEPMC3 minor version ${HEPMC3_VERSION_MINOR} > 0 - adding HEPMC3 definition")
    add_definitions(-DHEPMC31)
  endif()
  if (${HEPMC3_VERSION} VERSION_GREATER "3.0")
    # message( STATUS "HEPMC3 version ${HEPMC3_VERSION} > 3.0 - adding HEPMC3 definition")
    add_definitions(-DHEPMC31)
  endif()
endif(HEPMC3_FOUND)

find_package(ROOT4HEPPY)

find_package(Pythia8)
