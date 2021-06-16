FROM ubuntu:16.04

# Install common dependencies
RUN apt-get -y update && \
    apt-get -y install sudo \ 
    apt-utils \
    build-essential \
    openssl \
    clang \
    graphviz-dev \
    git \
    libgnutls-dev \
    python-pip \
    nano \
    net-tools \
    vim \
    wget \
    zip \
    unzip \    
    dnsutils

# Add a new user ubuntu, pass: ubuntu
RUN groupadd ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1000 ubuntu -p "$(openssl passwd -1 ubuntu)"

WORKDIR /home/ubuntu

# Download and compile AFLNet
ENV LLVM_CONFIG="llvm-config-3.8"

# Set up fuzzers
# Set up fuzzers
RUN git clone https://github.com/profuzzbench/aflnet.git && \
    cd aflnet && \
    make clean all && \
    cd llvm_mode && make

ADD https://api.github.com/repos/setsal/LN-fuzz/git/refs/heads/master version.json                                                
RUN git clone https://github.com/setsal/LN-fuzz.git lnfuzz && \                                                                   
    cd lnfuzz/src && \                                                                                                            
    make clean all && \                                                                                                       
    cd llvm_mode && make     

RUN git clone https://github.com/setsal/aflnwe.git && \
    cd aflnwe && \
    make clean all && \
    cd llvm_mode && make

# Set up environment variables for AFLNet
ENV WORKDIR="/home/ubuntu/experiments"
ENV LNFUZZ="/home/ubuntu/lnfuzz/src"    
ENV AFLNET="/home/ubuntu/aflnet"                                                                                          
ENV PATH="${PATH}:${AFLNET}:{LNFUZZ}:/home/ubuntu/.local/bin:${WORKDIR}"
ENV AFL_PATH="${AFLNET}"
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
    AFL_SKIP_CPUFREQ=1 \
    AFL_NO_AFFINITY=1

RUN mkdir $WORKDIR && \
    pip install gcovr

COPY --chown=ubuntu:ubuntu in-dns ${WORKDIR}/in-dns
COPY --chown=ubuntu:ubuntu dns.dict ${WORKDIR}/dns.dict
COPY --chown=ubuntu:ubuntu cov_script.sh ${WORKDIR}/cov_script
COPY --chown=ubuntu:ubuntu cov_script_showmap_dnsmasq ${WORKDIR}/cov_script_showmap_dnsmasq
COPY --chown=ubuntu:ubuntu run.sh ${WORKDIR}/run
COPY --chown=ubuntu:ubuntu run_showmap.sh ${WORKDIR}/run_showmap
COPY --chown=ubuntu:ubuntu dnsmasq.conf ${WORKDIR}/dnsmasq.conf

# Download and compile Dnsmasq for fuzzing
RUN cd $WORKDIR && \
    git clone git://thekelleys.org.uk/dnsmasq.git && \
    cd dnsmasq && \
    git checkout v2.73rc6 && \
    CC=afl-clang-fast make && \
    cp ${WORKDIR}/dnsmasq.conf /etc/ && \
    echo address=/test.com/5.5.5.5 | sudo tee -a /etc/dnsmasq.conf

# Download and compile Dnsmasq for coverage analysis
RUN cd $WORKDIR && \
    git clone git://thekelleys.org.uk/dnsmasq.git dnsmasq-gcov && \
    cd dnsmasq-gcov && \
    git checkout v2.73rc6 && \
    make CFLAGS="-fprofile-arcs -ftest-coverage" LDFLAGS="-fprofile-arcs -ftest-coverage"
