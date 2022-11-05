add_compile_options(${PYTHIA8_CXXFLAGS})

set(MODULE_NAME pythiahepmc3)
set(MODULE ${PROJECT_NAME}_${MODULE_NAME})
set(NAME_LIB ${MODULE})

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
file(GLOB SOURCES_LIB ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx)
#if (APPLE)
#	# this is something to be understood - on linux it is NOT needed... additional link needed?
#	list(APPEND SOURCES_LIB ${HEPMC3_INCLUDE_DIRS}/../interfaces/pythia8/src/Pythia8ToHepMC3.cc)
#endif(APPLE)
# list(APPEND SOURCES_LIB ${HEPMC3_INCLUDE_DIRS}/../interfaces/pythia8/src/Pythia8ToHepMC3.cc)
message(STATUS "SOURCES: ${SOURCES_LIB}")
string(REPLACE ".cxx" ".hh" HEADERS_LIB "${SOURCES_LIB}")
string(REPLACE ".cxx" "_wrap.c" SWIG_HEADERS_LIB "${SOURCES_LIB}")

if (CONDA_ENV_ON)
	set(CONDA_INCLUDES $ENV{CONDA_PREFIX}/include)
endif()

find_path(PYTHIA2HEPMC3_DIR Pythia8/Pythia8ToHepMC3.h PATHS ${PYTHIA8_INCLUDE_DIR} ${HEPMC3_INCLUDE_DIRS} ${HEPMC3_INCLUDE_DIRS}/../interfaces/pythia8/include ${CONDA_INCLUDES})

if (PYTHIA2HEPMC3_DIR)
	message(STATUS "Pythia8/Pythia8ToHepMC3.h found ${PYTHIA2HEPMC3_DIR}")
	add_compile_definitions(PYTHIA2HEPMC3LEGACY)
else()
	message(STATUS "Pythia8/Pythia8ToHepMC3.h not found - trying with Pythia8Plugins")
	find_path(PYTHIA2HEPMC3_DIR Pythia8Plugins/HepMC3.h PATHS ${PYTHIA8_INCLUDE_DIR} ${HEPMC3_INCLUDE_DIRS} ${CONDA_INCLUDES})
	if (PYTHIA2HEPMC3_DIR)
		message(STATUS "Pythia8Plugins/HepMC3.h found ${PYTHIA2HEPMC3_DIR}")
		add_compile_definitions(PYTHIA2HEPMC3PLUGIN)
	else()
		message(WARNING "not able to figure out the Pythia8toHEPMC...")
	endif()
endif()

add_library(${NAME_LIB} SHARED ${SOURCES_LIB})
target_include_directories(${NAME_LIB} PUBLIC ${HEPMC3_INCLUDE_DIRS} ${PYTHIA2HEPMC3_DIR})
target_link_libraries(${NAME_LIB} PUBLIC ${PYTHIA8_LDFLAGS} ${HEPMC3_LIBRARIES})

set(SWIG_TARGET_LINK_LIBRARIES ${PYTHIA8_LDFLAGS} ${HEPMC3_LIBRARIES})

swigify()

install_targets_custom()
