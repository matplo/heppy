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

set(PROJECT_NAME heppy_external_roounfold)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../cmake/Modules")
include(common_heppy)
# include(common_heppy_finds)
include(heppy_find_python)
find_package(ROOT4HEPPY REQUIRED RooFit)
if (ROOT_FOUND)
	message(STATUS "${Green}Will use ROOT at ${ROOT_HEPPY_PREFIX}${ColourReset}")
else(ROOT_FOUND)
    message(FATAL_ERROR "${Red}ROOT not found while it is the key package to build RooUnfold${ColourReset}")
endif(ROOT_FOUND)

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

set (CMAKE_CXX_STANDARD 11)

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
	execute_process(COMMAND ${Python3_EXECUTABLE} -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))"
					/tmp OUTPUT_VARIABLE HEPPY_PYTHON_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
	message(STATUS "Some python libs info: ${Python3_EXECUTABLE} ${Python3_INCLUDE_DIRS} ${Python3_STDLIB} ${Python3_LIBRARIES} ${HEPPY_PYTHON_LIBS}")
	#add_definitions(-DPYTHON_EXECUTABLE=${Python3_EXECUTABLE} -DPYTHON_INCLUDE_DIR=${Python3_INCLUDE_DIRS} -DPYTHON_LIBRARY=${Python3_STDLIB})
  else(Python3_FOUND)
    message(FATAL_ERROR "${Red}Python not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)

include(ProcessorCount)
ProcessorCount(NCPU)

include(ExternalProject)

if (NOT ROOUNFOLD_VERSION)
	set(ROOUNFOLD_VERSION master)
endif(NOT ROOUNFOLD_VERSION)

message(STATUS "ROOUNFOLD_VERSION ${ROOUNFOLD_VERSION}")

if (NOT ROOUNFOLD_HEPPY_PREFIX)
	set(ROOUNFOLD_HEPPY_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/roounfold-${ROOUNFOLD_VERSION}")
endif(NOT ROOUNFOLD_HEPPY_PREFIX)

message(STATUS "ROOUNFOLD_HEPPY_PREFIX ${ROOUNFOLD_HEPPY_PREFIX}")

# add_definitions(-Dbuiltin_xroounfoldd=ON -Dmathmore=ON -Dxml=ON -Dvmc=ON)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/RooUnfoldCMakePatch-${ROOUNFOLD_VERSION})
	set(THIS_PATCH_COMMAND patch ${ROOUNFOLD_HEPPY_PREFIX}/src/ROOUNFOLD/CMakeLists.txt < ${CMAKE_CURRENT_SOURCE_DIR}/RooUnfoldCMakePatch-${ROOUNFOLD_VERSION})
    message(STATUS "${Green}Will patch CMakeFiles.txt with ${CMAKE_CURRENT_SOURCE_DIR}/RooUnfoldCMakePatch-${ROOUNFOLD_VERSION} ${ColourReset}")
endif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/RooUnfoldCMakePatch-${ROOUNFOLD_VERSION})

ExternalProject_Add(ROOUNFOLD
	PREFIX        		${ROOUNFOLD_HEPPY_PREFIX}
	GIT_REPOSITORY    	https://gitlab.cern.ch/elesser/RooUnfold.git
	GIT_TAG 		  	${ROOUNFOLD_VERSION}
	GIT_PROGRESS 		TRUE
	PATCH_COMMAND       ${THIS_PATCH_COMMAND}
	CMAKE_ARGS 			${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${ROOUNFOLD_HEPPY_PREFIX} -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=${Python3_EXECUTABLE} -DPYTHON_INCLUDE_DIR=${Python3_INCLUDE_DIRS} -DPYTHON_LIBRARY=${Python3_LIBRARIES} -DCMAKE_PREFIX_PATH=${ROOT_HEPPY_PREFIX}
	BUILD_COMMAND       ${CMAKE_COMMAND} --build . -- -j ${NCPU}
	INSTALL_COMMAND     ${CMAKE_COMMAND} --build . --target install
	LOG_DOWNLOAD 		TRUE
	LOG_UPDATE 			TRUE
	LOG_CONFIGURE 		TRUE
	LOG_BUILD 			TRUE
	LOG_TEST 			TRUE
	LOG_INSTALL 		TRUE)
