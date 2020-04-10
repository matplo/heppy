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

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules")
include(colors)
set(PROJECT_NAME heppy_external_pythia8)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

set (CMAKE_CXX_STANDARD 11)

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")


include(ProcessorCount)
ProcessorCount(NCPU)

include(ExternalProject)

if (NOT PYTHIA8_VERSION)
	set(PYTHIA8_VERSION 8244)
endif(NOT PYTHIA8_VERSION)

message(STATUS "PYTHIA8_VERSION ${PYTHIA8_VERSION}")

if (NOT PYTHIA8_HEPPY_PREFIX)
	set(PYTHIA8_HEPPY_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/pythia8-${PYTHIA8_VERSION}")
endif(NOT PYTHIA8_HEPPY_PREFIX)

message(STATUS "PYTHIA8_HEPPY_PREFIX ${PYTHIA8_HEPPY_PREFIX}")

set(PYTHIA8_CONFIGURE_COMMAND ./configure)
list(APPEND PYTHIA8_CONFIGURE_COMMAND --prefix=${PYTHIA8_HEPPY_PREFIX})

find_package(HepMC QUIET COMPONENTS HepMC)
if (HepMC_FOUND)
	list(APPEND PYTHIA8_CONFIGURE_COMMAND --with-hepmc2=${HEPMC_DIR} --with-hepmc2-include=${HEPMC_INCLUDE_DIR} --with-hepmc2-lib=${HEPMC_LIB_DIR})
endif(HepMC_FOUND)

find_package(LHAPDF QUIET)
if (LHAPDF6_FOUND)
	message(status "no ver ${LHAPDF_DIR}")
	message(status "6 ${LHAPDF6_DIR}")
	message(status "${LHAPDF6_INCLUDE_DIR}")
	list(APPEND PYTHIA8_CONFIGURE_COMMAND --with-lhapdf6=${LHAPDF6_DIR})
endif(LHAPDF6_FOUND)

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
	list(APPEND PYTHIA8_CONFIGURE_COMMAND --with-python-include=${Python3_INCLUDE_DIRS})
	get_filename_component(Python3_EXE_NAME ${Python3_EXECUTABLE} NAME)
	if (Python3_EXE_NAME STREQUAL "python")
		get_filename_component(Python3_BINDIR ${Python3_EXECUTABLE} DIRECTORY)
		list(APPEND PYTHIA8_CONFIGURE_COMMAND --with-python-bin=${Python3_BINDIR})
	else(Python3_EXE_NAME STREQUAL "python")
		# work around pythia build that relies on presence of python (not python3 executable)
		message(STATUS ${CMAKE_CURRENT_BINARY_DIR})
		execute_process(COMMAND ln -sf ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/python )
		list(APPEND PYTHIA8_CONFIGURE_COMMAND --with-python-bin=${CMAKE_CURRENT_SOURCE_DIR}/)
	endif(Python3_EXE_NAME STREQUAL "python")
endif(Python3_FOUND)

find_package(HepMC3 QUIET COMPONENTS HepMC)
find_package(ROOT 6.18 QUIET COMPONENTS RIO EG PyROOT)

message(STATUS "configure command: ${PYTHIA8_CONFIGURE_COMMAND}")

ExternalProject_Add(PYTHIA8
	PREFIX            ${PYTHIA8_BUILD}
	URL               http://home.thep.lu.se/~torbjorn/pythia8/pythia${PYTHIA8_VERSION}.tgz
	DOWNLOAD_DIR      ${CMAKE_CURRENT_SOURCE_DIR}/downloads
	# DOWNLOAD_NAME     fastjet-${PYTHIA8_VERSION}.tar.gz
	# SOURCE_DIR        ${CMAKE_CURRENT_SOURCE_DIR}/build/fastjet-${PYTHIA8_VERSION}
	BUILD_IN_SOURCE 	1
	INSTALL_DIR       ${PYTHIA8_BUILD}
	CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${PYTHIA8_CONFIGURE_COMMAND}
	BUILD_COMMAND     ${CMAKE_COMMAND} -E env ${MAKE_EXE} -j ${NCPU}
	INSTALL_COMMAND   ${CMAKE_COMMAND} -E env ${MAKE_EXE} install
	#TEST_COMMAND      ${PYTHIA8_CONFIGURE_COMMAND}/fastjet-config
	#TEST_BEFORE_INSTALL 1
	LOG_DOWNLOAD 1
	LOG_UPDATE 1
	LOG_CONFIGURE 1
	LOG_BUILD 1
	LOG_TEST 1
	LOG_INSTALL 1)
