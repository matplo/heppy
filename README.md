# heppy

- some work on HEP things in python (with quite a bit of help on c++ side)
- dependencies:
  - CMake, SWIG, Python ver. >= 3.6
  - FastJet ver. >= 3.
    - expects fastjet-config in $PATH or in $FASTJET_DIR/bin
    - note: during installation it will download and patch fjcontrib v. 1.042
  - usage of ROOT (Pythia8 bindings; also HEPMC2, HEPMC3, LHAPDF6) is up to the user
    - for Pythia8 pythia8-config should be in $PATH or in $PYTHIA8_DIR/bin
    - for ROOT (compiled with the same python) root-config in $PATH or in $ROOTSYS/bin
 
# recommended build/setup

 - to build the main interface
```
./cpptools/build.sh
```
 - notable environment variables:
 -- $CGAL_DIR; $FASTJET_DIR; $HEPMC_DIR; $HEPMC2_DIR; $HEPMC3_DIR; $LHAPDF6_DIR; $PYTHIA8_DIR; $ROOTSYS

 - for full functionality (compiled with the *same* python3 >= 3.6):
 -- FASTJET 3 (the builtin build will attempt to find CGAL on the system - guess is $CGAL_DIR})
 -- PYTHIA 8
 -- HEPMC2 and HEPMC3
 -- LHAPDF6
 -- ROOT 6

 - some prerequisites expected in path (compiled with the same python3 >= 3.6):
 ```
 root-config
 pythia8-config
 ```
 - otherwise the system depends on CMake's `findPackage` (provided) see https://github.com/matplo/heppy/tree/newbuild/cmake/Modules

## build setup 

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

```

  - these will download and install PYTHIA, HepMC2, HepMC3, LHAPDF6, FASTJET, ROOT into the `external` subdirectory. User can control what version packages to use by building those libs yourself...

# example python script

 - heppy/examples/pythia_gen_fastjet_lund_test.py

# running

- example 'workflow'

```
pipenv shell
module use heppy/modules
module load heppy/main_python
./cpptools/tests/pythia_gen_fj_lund_test.py
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
