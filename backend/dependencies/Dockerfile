FROM ubuntu:hirsute
# system packages installation

ENV DEBIAN_FRONTEND=noninteractive

# Install python
RUN apt-get update && apt-get install --no-install-recommends -y python3-pip python3-dev ffmpeg swig \
	libimage-exiftool-perl curl nfs-common cifs-utils libopenblas-dev libheif-dev libmagic1 \
	libraw-dev libboost-all-dev libxrender-dev liblapack-dev git bzip2 cmake build-essential libsm6 \
	libglib2.0-dev libgl1-mesa-glx libpq-dev libexpat-dev librsvg2-dev libpng-dev libgif-dev \
	libjpeg-dev libexif-dev liblcms2-dev liborc-dev pkg-config libexpat1-dev libtiff5-dev \
	libgsf-1-dev libopenexr-dev libcfitsio-dev libimagequant-dev libtool libtool-bin unzip \
	libwebp-dev cmake wget \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

#Build and install libraw
RUN git clone --depth 1 https://github.com/LibRaw/LibRaw
WORKDIR /LibRaw
RUN autoreconf --install
RUN ./configure
RUN make -j4
RUN make install -j4

#Build and install imagemagick
WORKDIR /
ADD https://www.imagemagick.org/download/ImageMagick.tar.gz /imagemagick
WORKDIR /imagemagick/ImageMagick-7.1.0-5
RUN ./configure --with-modules \
	&& make install -j4 \
  && ldconfig /usr/local/lib

# Build and install libvips
ARG VIPSVERSION=8.11.0
ARG VIPSURL=https://github.com/libvips/libvips/releases/download
WORKDIR /usr/local/src
ADD ${VIPSURL}/v${VIPSVERSION}/vips-${VIPSVERSION}.tar.gz vips-${VIPSVERSION}
RUN ./configure \
	&& make V=0 -j4 \
	&& make install -j4 \
	&& ldconfig

# pre trained models download
# Moved this to entrypoint
# ADD https://github.com/LibrePhotos/librephotos-docker/releases/download/0.1/places365.tar.gz /data_models/
# ADD https://github.com/LibrePhotos/librephotos-docker/releases/download/0.1/im2txt.tar.gz /data_models/
# ADD https://github.com/LibrePhotos/librephotos-docker/releases/download/0.1/clip-embeddings.tar.gz /data_models/
# ADD https://download.pytorch.org/models/resnet152-b121ed2d.pth /root/.cache/torch/hub/checkpoints/resnet152-b121ed2d.pth

RUN pip install torch torchvision \
  && pip3 install pyvips

# Build and install dlib
WORKDIR /
RUN git clone --depth 1 https://github.com/davisking/dlib.git && \
    mkdir /dlib/build && \
    cd /dlib/build && \
    cmake .. -DDLIB_USE_CUDA=0 -DUSE_AVX_INSTRUCTIONS=0 -DLIB_NO_GUI_SUPPORT=0 && \
    cmake --build . && \
    cd /dlib && \
    python setup.py install --no USE_AVX_INSTRUCTIONS --no DLIB_USE_CUDA --no USE_SSE4_INSTRUCTIONS

#Build and install faiss. Needs to be build for ARM
WORKDIR /faiss
RUN git clone --depth 1 https://github.com/facebookresearch/faiss.git /faiss
RUN cmake -B build . -DCMAKE_BUILD_TYPE=Release -DFAISS_ENABLE_GPU=OFF -DFAISS_ENABLE_PYTHON=ON -DFAISS_OPT_LEVEL=generic
RUN make -C build -j4 faiss
RUN make -C build -j4 swigfaiss
RUN (cd build/faiss/python && python setup.py install)
# install unzip
RUN apt install -y unzip
# unzip faiss to actually installed it...
RUN unzip /usr/local/lib/python3.9/dist-packages/faiss*.egg -d /usr/local/lib/python3.9/dist-packages/
