function(SWIGIFY)
	if (BUILD_PYTHON)
		if (Python_FOUND)
			include_directories(${SWIG_TARGET_INCLUDE_DIRECTORIES})
			if (SWIG_INTERFACE_FILE)
					message(STATUS "Using swig file ${SWIG_INTERFACE_FILE}")
				else(SWIG_INTERFACE_FILE)
					set(SWIG_INTERFACE_FILE ${MODULE_NAME}.i)
					message(STATUS "Using swig file ${SWIG_INTERFACE_FILE} - from MODULE_NAME := ${MODULE_NAME}")
			endif(SWIG_INTERFACE_FILE)

			set(CMAKE_SWIG_FLAGS "")
			set_source_files_properties(${SWIG_INTERFACE_FILE} PROPERTIES CPLUSPLUS ON)
			set_property(SOURCE ${SWIG_INTERFACE_FILE} PROPERTY SWIG_MODULE_NAME ${MODULE_NAME})

			# Add swig module
			swig_add_library(${MODULE_NAME} TYPE SHARED LANGUAGE python SOURCES ${SWIG_INTERFACE_FILE})
			swig_link_libraries(${MODULE_NAME} ${NAME_LIB} ${Python_LIBRARIES} ${SWIG_MODULE_LINK_LIBRARIES})

			# Files to install with Python
			list(APPEND PYTHON_INSTALL_FILES
			        ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}.py
			        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/_${MODULE_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
			message(STATUS "${Green} ... built: ${PYTHON_INSTALL_FILES} ${ColourReset}")
			set(PYTHON_INSTALL_FILES ${PYTHON_INSTALL_FILES} PARENT_SCOPE)
		else(Python_FOUND)
			message(WARNING "${Yellow} Missing Python *** NO PYTHON INTERFACE WILL BE BUILD *** ${ColourReset}")
		endif(Python_FOUND)
	endif(BUILD_PYTHON)
	message(STATUS "${Yellow} ... swigify done with ${MODULE_NAME} ${ColourReset}")
endfunction(SWIGIFY)
