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

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../cmake/Modules")
include(common_heppy)
set(PROJECT_NAME heppy_external_fastjet)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

set (CMAKE_CXX_STANDARD 11)

message( STATUS "CMAKE_CURRENT_LIST_DIR: ${CMAKE_CURRENT_LIST_DIR}")

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
  else(Python3_FOUND)
    message(FATAL_ERROR "${Red}Python not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)

include(ProcessorCount)
ProcessorCount(NCPU)

include(ExternalProject)

if (NOT FASTJET_VERSION)
	set(FASTJET_VERSION 3.3.3)
endif(NOT FASTJET_VERSION)

message(STATUS "FASTJET_VERSION ${FASTJET_VERSION}")

if (NOT FASTJET_HEPPY_PREFIX)
	set(FASTJET_HEPPY_PREFIX "${CMAKE_CURRENT_LIST_DIR}/fastjet-${FASTJET_VERSION}")
endif(NOT FASTJET_HEPPY_PREFIX)

message(STATUS "FASTJET_HEPPY_PREFIX ${FASTJET_HEPPY_PREFIX}")

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
# set(FASTJET_CONFIGURE_COMMAND "export PYTHON=${Python3_EXECUTABLE} export PYTHON_INCLUDE=${Python3_INCLUDE_DIRS} ./configure")
# set($ENV{PYTHON} ${Python3_EXECUTABLE})
# set($ENV{PYTHON_INCLUDE} -I${Python3_INCLUDE_DIRS})
# set(PYTHON_ENV "PYTHON=${Python3_EXECUTABLE} PYTHON_INCLUDE=-I${Python3_INCLUDE_DIRS}")

#set(PYTHON_ENV "PATH=$ENV{PATH}:${CMAKE_CURRENT_SOURCE_DIR}")
#execute_process(COMMAND ln -sf ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/python )
#find_program(PYTHON3_CONFIG python3-config)
#if (PYTHON3_CONFIG)
#   execute_process(COMMAND ln -sf ${PYTHON3_CONFIG} ${CMAKE_CURRENT_SOURCE_DIR}/python-config )
#   message(STATUS "python3-config at ${PYTHON3_CONFIG}")
#else()
#   message(SEND_ERROR "python3-config not found")
#endif(PYTHON3_CONFIG)

set(FASTJET_CONFIGURE_COMMAND ./configure)
list(APPEND FASTJET_CONFIGURE_COMMAND --prefix=${FASTJET_HEPPY_PREFIX} --enable-allcxxplugins --enable-pyext)
if (ENABLE_CGAL)
	find_package(CGAL REQUIRED COMPONENTS Core)
	if (NOT CGAL_FOUND)
		message(STATUS "STD FindCGAL failed - trying out with custom FindCGAL...")
		find_package(CGALcustom REQUIRED COMPONENTS Core)
	endif()
	if (CGAL_FOUND)
	    message(STATUS "${Green}CGAL found - CGAL_USE_FILE: ${CGAL_USE_FILE} VERSION: ${CGAL_VERSION} ${ColourReset}") 
	    # --enable-cgal --enable-cgal-header-only
		if (EXISTS ${CGAL_USE_FILE})
			message(STATUS "CGAL_USE_FILE: ${CGAL_USE_FILE}")
	    	include(${CGAL_USE_FILE}) 
		    message(STATUS "after include (${CGAL_USE_FILE}: ${CGAL_USE_FILE} ${CGAL_INCLUDE_DIRS} ${CGAL_LIBRARY} ${ColourReset}")
		    get_filename_component(CGAL_GUESS_DIR ${CGAL_INCLUDE_DIRS} DIRECTORY)
			message(STATUS "${Yellow}Workaround: Guessing CGAL dir for FJ ${CGAL_GUESS_DIR}${ColourReset}")
		    if (${CGAL_VERSION} VERSION_GREATER "5.0")
				message(STATUS "${Yellow}CGAL greater than 5 ${CGAL_VERSION} ${ColourReset}")
		    	list(APPEND FASTJET_CONFIGURE_COMMAND --enable-cgal --enable-cgal-header-only --with-cgaldir=${CGAL_GUESS_DIR})
		    else(${CGAL_VERSION} VERSION_GREATER "5.0")
	    		list(APPEND FASTJET_CONFIGURE_COMMAND --enable-cgal --with-cgaldir=${CGAL_GUESS_DIR})
		    endif(${CGAL_VERSION} VERSION_GREATER "5.0")
		else(EXISTS ${CGAL_USE_FILE})
			list(APPEND FASTJET_CONFIGURE_COMMAND --prefix=${FASTJET_HEPPY_PREFIX} --enable-cgal --with-cgaldir=${CGAL_DIR})		
	    endif(EXISTS ${CGAL_USE_FILE})
	endif(CGAL_FOUND)
else(ENABLE_CGAL)
	message(STATUS "note: CGAL not enabled - use -DENABLE_CGAL=TRUE to enable...")
endif(ENABLE_CGAL)

ExternalProject_Add(FASTJET
	PREFIX            ${FASTJET_BUILD}
	URL               http://fastjet.fr/repo/fastjet-${FASTJET_VERSION}.tar.gz
	DOWNLOAD_DIR      ${CMAKE_CURRENT_LIST_DIR}/downloads
	# DOWNLOAD_NAME     fastjet-${FASTJET_VERSION}.tar.gz
	# SOURCE_DIR        ${CMAKE_CURRENT_LIST_DIR}/build/fastjet-${FASTJET_VERSION}
	BUILD_IN_SOURCE 	1
	INSTALL_DIR       ${FASTJET_BUILD}
	CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${PYTHON_ENV} ${FASTJET_CONFIGURE_COMMAND}
	BUILD_COMMAND     ${CMAKE_COMMAND} -E env ${MAKE_EXE} -j ${NCPU}
	INSTALL_COMMAND   ${CMAKE_COMMAND} -E env ${MAKE_EXE} install
	#TEST_COMMAND      ${FASTJET_CONFIGURE_COMMAND}/fastjet-config
	#TEST_BEFORE_INSTALL 1
	LOG_DOWNLOAD 1
	LOG_UPDATE 1
	LOG_CONFIGURE 1
	LOG_BUILD 1
	LOG_TEST 1
	LOG_INSTALL 1)
