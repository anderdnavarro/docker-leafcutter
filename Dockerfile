FROM ubuntu:focal

LABEL \
    description="Image for use with LeafCutter https://github.com/davidaknowles/leafcutter"

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    build-essential \
    bzip2 \
    cmake \
    gcc \
    gfortran \
    git \
    libcurl4-openssl-dev \
    libbz2-dev \
    libfontconfig1-dev \ 
    libfreetype6-dev \
    libfribidi-dev \
    libgsl-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libjpeg-dev \
    liblzma-dev \
    libpcre2-dev \
    libpng-dev \
    libreadline-dev \
    libssl-dev \
    libtbb-dev \
    libtiff5-dev \
    libv8-dev \
    libxml2-dev \
    make \
    ncurses-dev \
    python2 \
    wget \
    zlib1g-dev

##########
# HTSlib #
##########
ENV HTSLIB_INSTALL_DIR=/opt/htslibA
ENV HTSLIB_VERSION="1.10.2"

WORKDIR /tmp
RUN wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 && \
    tar --bzip2 -xvf htslib-${HTSLIB_VERSION}.tar.bz2

WORKDIR /tmp/htslib-${HTSLIB_VERSION}
RUN ./configure  --enable-plugins --prefix=$HTSLIB_INSTALL_DIR && \
    make && \
    make install && \
    cp $HTSLIB_INSTALL_DIR/lib/libhts.so* /usr/lib/
WORKDIR /tmp
RUN rm -rf /tmp/*

############
# Samtools #
############
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
ENV SAMTOOLS_VERSION="1.10"
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    tar --bzip2 -xf samtools-${SAMTOOLS_VERSION}.tar.bz2

WORKDIR /tmp/samtools-${SAMTOOLS_VERSION}
RUN ./configure --with-htslib=$HTSLIB_INSTALL_DIR --prefix=$SAMTOOLS_INSTALL_DIR && \
    make && \
    make install

WORKDIR /
RUN rm -rf /tmp/*

#########
# Tabix #
#########
RUN ln -s $HTSLIB_INSTALL_DIR/bin/tabix /usr/bin/tabix

############
# Regtools #
############
WORKDIR /tmp
RUN git clone https://github.com/griffithlab/regtools && \
    cd regtools/ && \
    mkdir build && \
    cd build/ && \
    cmake .. && \
    make && \
    mkdir /opt/regtools/ && \
    mv regtools /opt/regtools/

#####
# R #
#####
ENV R_INSTALL_DIR=/usr/local/
ENV R_VERSION="3.6.3"

RUN wget https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz && \
    tar -zxvf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION} && \
    ./configure --prefix=${R_INSTALL_DIR} --with-x=no && \
    make && \
    make install

##############
# R packages #
##############
COPY install_packages.R /tmp/install_packages.R
RUN Rscript /tmp/install_packages.R && \
    rm /tmp/install_packages.R

WORKDIR /git/
RUN git clone https://github.com/davidaknowles/leafcutter.git
RUN git clone https://github.com/jackhump/leafviz.git 
WORKDIR /
