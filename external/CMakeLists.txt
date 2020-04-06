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
#/usr/local/include
#/usr/local/lib

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

if (BUILD_FASTJET)
  message(STATUS "${Magenta}We will try to build FastJet...${ColourReset}")
  #set(FASTJET_HEPPY_BUILD $ENV{HOME}/devel/heppy/external/packages/fastjet-3.3.3-python)
  set(FASTJET_VERSION 3.3.3)
  set(FASTJET_HEPPY_BUILD "${CMAKE_CURRENT_SOURCE_DIR}/packages/fastjet-${FASTJET_VERSION}")
  find_package(CGAL)
  message(STATUS ${CGAL_DIR})
  set(FASTJET_CONFIGURE_COMMAND ./configure)
  if (CGAL_FOUND)
    list(APPEND FASTJET_CONFIGURE_COMMAND "--prefix=/Users/ploskon/tmp/fj" "--enable-allcxxplugins" "--enable-pyext" "--with-cgaldir=${CGAL_DIR}")
  else(CGAL_FOUND)
    list(APPEND FASTJET_CONFIGURE_COMMAND "--prefix=/Users/ploskon/tmp/fj" "--enable-allcxxplugins" "--enable-pyext")
  endif(CGAL_FOUND)    
  set(FASTJET fastjet-heppy-build)
  ExternalProject_Add(FASTJET
    PREFIX            ${CMAKE_CURRENT_SOURCE_DIR}/build/fastjet
    URL               http://fastjet.fr/repo/fastjet-${FASTJET_VERSION}.tar.gz
    DOWNLOAD_DIR      ${CMAKE_CURRENT_SOURCE_DIR}/build/downloads
    # DOWNLOAD_NAME     fastjet-${FASTJET_VERSION}.tar.gz
    # SOURCE_DIR        ${CMAKE_CURRENT_SOURCE_DIR}/build/fastjet-${FASTJET_VERSION}
    BUILD_IN_SOURCE 1
    INSTALL_DIR       ${FASTJET_HEPPY_BUILD}
    # CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${FASTJET_CONFIGURE_COMMAND}
    # BUILD_COMMAND     ${CMAKE_COMMAND} -E env ${MAKE_EXE} -j
    # INSTALL_COMMAND   ${CMAKE_COMMAND} -E env ${MAKE_EXE} install
    CONFIGURE_COMMAND ${FASTJET_CONFIGURE_COMMAND}
    BUILD_COMMAND     ${MAKE_EXE} -j ${NCPU}
    INSTALL_COMMAND   ${MAKE_EXE} install
    #TEST_COMMAND      ${FASTJET_CONFIGURE_COMMAND}/fastjet-config
    #TEST_BEFORE_INSTALL 1
    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1)
  message(STATUS "${Magenta}Build done...${ColourReset}")
else(BUILD_FASTJET)
  find_package(FASTJET 3.0 REQUIRED)
  if (NOT FASTJET_FOUND)
    message(STATUS "${Red}FASTJET not found.${ColourReset}")
    if (NOT BUILD_FASTJET)
      message(STATUS "${Yellow}Hint: Set -DBUILD_FASTJET=1 to try to setup fastjet...${ColourReset}")
    endif(NOT BUILD_FASTJET)
  endif(NOT FASTJET_FOUND)
endif(BUILD_FASTJET)

# if (NOT FASTJET_FOUND)
#   message(SEND_ERROR " ${Red}This will not work without fastjet...${ColourReset}")
# endif(NOT FASTJET_FOUND)

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
    execute_process ( COMMAND find ${ROOT_LIBRARY_DIR} -name "ROOT.py" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
    if (ROOT_PYTHON)
      message(STATUS "${Green}ROOT python module: ${ROOT_PYTHON}${ColourReset}")
      string(REPLACE "${ROOT_LIBRARY_DIR}/" "" FJPYSUBDIR_TMP "${ROOT_PYTHON}")
      string(REPLACE "/ROOT.py" "" ROOT_PYTHON_SUBDIR ${ROOT_PYTHON})
      message(STATUS "${Green}ROOT python module subdir: ${ROOT_PYTHON_SUBDIR}${ColourReset}")
      execute_process( COMMAND python -c "import sys; sys.path.append('${ROOT_PYTHON_SUBDIR}'); import ROOT; ROOT.gROOT.SetBatch(True); print('# ROOT version from within python:',ROOT.gROOT.GetVersion());" 
                        WORKING_DIRECTORY /tmp 
                        RESULT_VARIABLE LOAD_ROOT_PYTHON_RESULT 
                        OUTPUT_VARIABLE LOAD_ROOT_PYTHON 
                        ERROR_VARIABLE LOAD_ROOT_PYTHON_ERROR 
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (LOAD_ROOT_PYTHON_ERROR)
        message(STATUS "${Red}Loading ROOT python module - result:[${LOAD_ROOT_PYTHON_RESULT}] - failure!${ColourReset}")
        message(SEND_ERROR " ${Red}Loading ROOT python module FAILED:\n ${LOAD_ROOT_PYTHON_ERROR}${ColourReset}")
      else(LOAD_ROOT_PYTHON_ERROR)
        message(STATUS "${Green}Loading ROOT python module - result:[${LOAD_ROOT_PYTHON_RESULT}] - success!${ColourReset}")
        message("${LOAD_ROOT_PYTHON}")
        message(STATUS "${Green}ROOT ver. ${ROOT_VERSION}${ColourReset}")
      endif(LOAD_ROOT_PYTHON_ERROR)      
    else(ROOT_PYTHON)
      message(SEND_ERROR " ${Red}ROOT python module missing or not functional. This will create trouble.${ColourReset}")
    endif(ROOT_PYTHON)  
  else(ROOT_FOUND)
    message(STATUS "${Yellow}ROOT not found - root-config not in the path? - some of the tools in pyjetty will require ROOT.${ColourReset}")
endif(ROOT_FOUND)

find_package(PYTHIA)
