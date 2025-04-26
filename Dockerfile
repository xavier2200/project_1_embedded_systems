## Base Image from intel dlstreamer
ARG OS_VER="2023.0.0-ubuntu22-gpu682-dpcpp-devel"
FROM intel/dlstreamer:${OS_VER}

USER root

########All that need root privilage for installing########

RUN apt-get update; \
    apt-get install -y git \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
RUN pip3 install ultralytics

# Uninstall the current OpenCV module
RUN pip3 uninstall -y opencv-python

# Install GTK libraries before building OpenCV
RUN apt-get update && apt-get install -y \
    libgtk2.0-dev \
    pkg-config

# Then build OpenCV with GUI support explicitly enabled
RUN git clone https://github.com/opencv/opencv.git && \
    cd opencv && git checkout 4.7.0 && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_GSTREAMER=ON \
    -D WITH_GTK=ON \
    -D BUILD_opencv_python3=yes \
    -D PYTHON_EXECUTABLE=$(which python3) .. && \
    make -j$(nproc) && \
    make install

USER dlstreamer

##################All that dont need root####################

RUN pip3 install \
    pillow \
    matplotlib

RUN mkdir models && cd models && omz_downloader --name person-vehicle-bike-detection-2004 --precisions FP32 &&\
    omz_downloader --name person-attributes-recognition-crossroad-0230 --precisions FP32 && \
    omz_downloader --name vehicle-attributes-recognition-barrier-0039 --precisions FP32 \