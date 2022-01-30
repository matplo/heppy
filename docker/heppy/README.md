# run heppy in a docker

quick start

```
./run.sh
```

- this will download the precompiled image *and* run it
- by specifying an argument you ask to run it within the docker
- reserved arguments are: `--build` `--tag` `--push` - pretty much selfexplanatory
- if you have `~/.docker_heppy_startup.sh` it will get sourced (`~` refers to home on the host os - not docker)
- few interesting directories within the docker
  - `/hostuserhome/` this is your  `$HOME` on the host os
  - `/` is mounted under `/host`
  - `/usr/local/docker/fromhost/` are files from installation - ignore
  - heppy in the docker is in `/usr/local/docker/heppy/`
- note, your .ssh was copied to home directory within the docker
