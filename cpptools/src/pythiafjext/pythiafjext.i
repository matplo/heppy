%module pythiafjext
%include "std_vector.i"
%{
	#define SWIG_FILE_WITH_INIT
	#include <Pythia8/Pythia.h>
	#define SWIG
	#include <fastjet/PseudoJet.hh>
	#include "pyfjtools.hh"
%}

%include "std_string.i"
%include "std_vector.i"
%include "typemaps.i"
%include "../numpy.i"
%init %{
	import_array();
%}
%fragment("NumPy_Fragments");

%apply (int* IN_ARRAY1, int DIM1) {(int* selection, int nsel)};
%include "pyfjtools.hh"
%clear (int* selection, int nsel);
