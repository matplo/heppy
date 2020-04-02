# heppy

- some work on HEP things in python (with quite a bit of help on c++ side)
- this uses CMake, SWIG
- usage of ROOT (Pythia8 bindings; also HEPMC3) is up to the user

# example python script

 - heppy/examples/pythia_gen_fastjet_lund_test.py
 
# recommended build/setup

- simply type and get a short (long if building with root) coffee
```
./scripts/setup.sh --buildext --root --all
```

- ... load module to use ...

```
pipenv shell
./scripts/setup.sh --buildext --root --all
module use $PWD/modules
module load heppy/main_python
examples/pythia_gen_fastjet_lund_test.py
```

- to wipe out and rebuild everything
```
./scripts/cleanup.sh
./scripts/setup.sh --buildext --rebuild
```

- to rebuild the swigified fjcontrib and the few tools only
```
./scripts/setup.sh --rebuild
```

- to change the external builds you can use scripts...
```
external/setup_pythia8.sh --version=8.XYZ
external/setup_fastjet.sh
external/setup_hepmc3.sh           
external/setup_hepmc2_cmake.sh     
external/setup_root.sh
external/setup_lhapdf6.sh
```
... but the best is to edit the `external/setup.sh`

- useful debuging option `--configure-only` (no build just configure and exit)

- to rebuild cpptools only
```
./scripts/setup.sh
```
- useful debuging option `--configure-only`

- one can also use ./cpptools/scripts/build_cpptools.sh directly with [--rebuild] [--install] [--clean] [--cleanall]

# modules

- ./modules/heppy contains modules - use the one with 'main' to load everything


## Notes: 

- this will download and install PYTHIA, HepMC2, HepMC3, LHAPDF6, FASTJET, ROOT into the `external` subdirectory. User can control what version packages to use by building those libs yourself...
- for some options `./scripts/build_cpptools.sh --help`

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
