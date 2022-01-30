# our base image
FROM nobetternick/root:6.24.06-ubuntu20.04

COPY heppy_requirements.txt /usr/local/docker/fromhost
RUN pip install -r /usr/local/docker/fromhost/heppy_requirements.txt
RUN cd /usr/local/docker && git clone https://github.com/matplo/heppy.git
RUN cd /usr/local/docker/heppy && ./external/roounfold/build.sh
RUN cd /usr/local/docker/heppy && ./external/fastjet/build.sh
RUN cd /usr/local/docker/heppy && ./external/lhapdf6/build.sh
RUN cd /usr/local/docker/heppy && ./external/hepmc2/build.sh
RUN cd /usr/local/docker/heppy && ./external/hepmc3/build.sh
RUN cd /usr/local/docker/heppy && ./external/pythia8/build.sh
RUN cd /usr/local/docker/heppy && ./cpptools/build.sh

ENTRYPOINT [ "/usr/local/docker/fromhost/in_docker_exec.sh" ]
