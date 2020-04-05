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

find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")

set (CMAKE_CXX_STANDARD 11)

include(colors)
set(PROJECT_NAME heppy_external)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

set(cmake_external_install_prefix ${CMAKE_CURRENT_SOURCE_DIR}/packages)
#/usr/local/include
#/usr/local/lib

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
  else(Python3_FOUND)
    message(ERROR "${Red}Python not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)

find_package(FASTJET 3.0 REQUIRED)

find_package(LHAPDF QUIET)

find_package(HepMC QUIET COMPONENTS HepMC)
if (HEPMC_FOUND)
  add_definitions(-DUSE_HEPMC)
  # message( STATUS "HEPMC_LIBRARIES: ${HEPMC_LIBRARIES}")
  # message( STATUS "HEPMC_LIBRARY_DIRS: ${HEPMC_LIBRARY_DIRS}")
  # message( STATUS "HEPMC_LINK_LIBRARIES: ${HEPMC_LINK_LIBRARIES}")
else()
  message(STATUS "${Yellow}Some of Pythia tools require HEPMC ver. >= 2 ${ColourReset}")
endif()

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

# https://root.cern.ch/how/integrate-root-my-project-cmake
# list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
# list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTDIR})
# # find_program( ROOTCONFIG root-config)
# # if (EXISTS ${ROOTCONFIG})
#   # message(STATUS "Using root-config at ${ROOTCONFIG}")
#   # indep. if root built with cmake assume the root-cint is in the path
#   # execute_process ( COMMAND root-config --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_DIR OUTPUT_STRIP_TRAILING_WHITESPACE )
#   # #message ("[info] ROOT_DIR: ${ROOT_DIR}")
#   # execute_process ( COMMAND root-config --etcdir WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_ETCDIR OUTPUT_STRIP_TRAILING_WHITESPACE )
#   # set( CMAKE_MODULE_PATH "${ROOT_ETCDIR}/cmake" )
#   # execute_process ( COMMAND root-config --libs WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE )
#   # message ("[info] CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
#   # if(DEFINED ROOT_USE_FILE) 
#   #   include(${ROOT_USE_FILE}) 
#   # else() 
#   #   include_directories(${ROOT_INCLUDE_DIRS}) 
#   # endif() 
# #endif()

find_package(ROOT 6.18 QUIET COMPONENTS RIO EG PyROOT)
if (ROOT_FOUND)
    include(${ROOT_USE_FILE}) 
    execute_process ( COMMAND root-config --version WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
    message(STATUS "${Green}ROOT ver. ${ROOT_VERSION} found.${ColourReset}")
  else(ROOT_FOUND)
    message(STATUS "${Yellow}ROOT not found - some of the tools in pyjetty will require ROOT.${ColourReset}")
endif(ROOT_FOUND)

find_package(PYTHIA)
