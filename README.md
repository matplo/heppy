# heppy

- some work on HEP things in python (with quite a bit of help on c++ side)
- dependencies:
  - CMake, SWIG, Python ver. >= 3.8 (>=3.6 allowed if ROOT version is set to 6.18 rather than 6.22)
  - FastJet ver. >= 3.
    - expects fastjet-config in $PATH or in $FASTJET_DIR/bin
    - note: during installation it will download and patch fjcontrib v. 1.042
  - usage of ROOT (Pythia8 bindings; also HEPMC2, HEPMC3, LHAPDF6) is up to the user
    - for Pythia8 pythia8-config should be in $PATH or in $PYTHIA8_DIR/bin
    - for ROOT (compiled with the same python - ROOT.py etc should be built) root-config in $PATH or in $ROOTSYS/bin
 
# recommended build/setup

 - a pre-build note: **because of the interaction of python2 and python3 on some systems and the particularities of fastjet build (also pythia8 to some extent) we recommend building in virtual environment** - for example:
 ```
./scripts/pipenv_heppy.sh install numpy
./scripts/pipenv_heppy.sh shell

# now build commands for the external packages follow...

# note: fastjet compilation relies on python-config (or python3.X-config to be precise)
./external/fastjet/build.sh
# note: use --clean to start with a clean configuration step
# ./external/fastjet/build.sh --clean

./external/lhapdf6/build.sh

./external/hepmc2/build.sh

./external/hepmc3/build.sh

./external/root/build.sh

./external/pythia8/build.sh

./cpptools/build.sh
 ```
  
 - to build the main interface
```
./cpptools/build.sh
```
 - note this will also create `./modules/heppy/1.0` - a handy environmental module
   - apart from setting up the paths it also adds a couple of aliases `heppython` for python executable in particular (and `heppy_cd` to cd to heppy directory...)
 - notable environment variables:
 -- $CGAL_DIR; $FASTJET_DIR; $HEPMC_DIR; $HEPMC2_DIR; $HEPMC3_DIR; $LHAPDF6_DIR; $PYTHIA8_DIR; $ROOTSYS

 - for full functionality (compiled with the *same* python3):
 -- FASTJET 3 (the builtin build will attempt to find CGAL on the system - guess is $CGAL_DIR})
 -- PYTHIA 8
 -- HEPMC2 and HEPMC3
 -- LHAPDF6
 -- ROOT 6

 - some prerequisites expected in path (compiled with the same python3):
 ```
 root-config
 pythia8-config
 ```
 - otherwise the system depends on CMake's `findPackage` (provided) see https://github.com/matplo/heppy/tree/newbuild/cmake/Modules

## setting up external packages... 

 - provided scripts can build external libraries (see below) and install them in heppy/external/...
 - to check if you have all what you need execute

```
	./external/build.sh
```

- to build individual (missing) packages:

```
	./external/fastjet/build.sh
	./external/lhapdf6/build.sh
	./external/hepmc/build.sh
	./external/hepmc3/build.sh
	./external/root/build.sh
	./external/pythia8/build.sh
	./external/roounfold/build.sh

```

  - these will download and install PYTHIA, HepMC2, HepMC3, LHAPDF6, FASTJET, ROOT into the `external` subdirectory. User can control what version packages to use by building those libs yourself...

# example python script

 - heppy/examples/pythia_gen_fastjet_lund_test.py

# running

- example 'workflow'

```
module use <where heppy>/modules
module load heppy/1.0
heppython $HEPPY_DIR/cpptools/tests/pythia_gen_fj_lund_test.py
...
# or for eIC
$HEPPYDIR/heppy/examples/pythia_gen_fastjet_lund_test.py --eic --eic-dis --ignore-mycfg
```

## alternative

- build PYTHIA [HepMC2, HepMC3, LHAPDF6], FASTJET and set appropriate environment variables (LHAPDF6 is completely optional; HEPMC2 also but pythiaext module will not be built);
- for PYTHIA and/or FASTJET `pythia8-config` and/or `fastjet-config` are expected to be accessible (in PATH)
- export $HEPPY_SETUP_EXTERNAL to point to a shell script setting up the environment or set it to a value - for example: `export ${HEPPY_SETUP_EXTERNAL}=mysetup.sh`

# add/extend c++ (swig) to python

- in the `cpptools/src` directory create your code/directory - should be easy to follow from one of the other
- edit `cpptools/src/CMakeLists.txt` as needed
- run `./scripts/setup.sh --rebuild` or `./cpptools/scripts/build_cpptools.sh`

# contributing

Please fork and make a pull request.
Please let us know if you are using this code - we are very much open for collaboration - email us at heppy@lbl.gov
