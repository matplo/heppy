# This file is just an orchestration
cmake_minimum_required(VERSION 3.13.5)
# SWIG: use SWIG_MODULE_NAME property.
if(POLICY CMP0086)
  cmake_policy(SET CMP0086 NEW)
endif()
# target_sources: use absolute path for INTERFACE_SOURCES.
if(POLICY CMP0076)
  cmake_policy(SET CMP0076 NEW)
endif()
# SWIG: use standard target name.
if(POLICY CMP0078)
  cmake_policy(SET CMP0078 NEW)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
include(colors)
set(PROJECT_NAME heppy_external)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

set (CMAKE_CXX_STANDARD 11)
set(cmake_external_install_prefix ${CMAKE_CURRENT_SOURCE_DIR}/packages)

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

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
include(ExternalProject)

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
