## Base Image from intel dlstreamer
ARG OS_VER="2023.0.0-ubuntu22-gpu682-dpcpp-devel"
FROM intel/dlstreamer:${OS_VER}

USER root

########All that need root privilage for installing########

RUN apt-get update; \
    apt-get install -y git \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

# Uninstall the current OpenCV module
RUN pip3 uninstall -y opencv-python

# Build OpenCV 4.7.0
RUN git clone https://github.com/opencv/opencv.git && \
    cd opencv && git checkout 4.7.0 && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_GSTREAMER=ON \
    -D BUILD_opencv_python3=yes \
	-D PYTHON_EXECUTABLE=$(which python3) .. && \
    make -j$(nproc) && \
    make install

USER dlstreamer

##################All that dont need root####################

RUN pip3 install ipywidgets \
    ipywebrtc \
    pillow \
    matplotlib

RUN mkdir models && cd models && omz_downloader --name person-vehicle-bike-detection-2004 --precisions FP32 &&\
    omz_downloader --name person-attributes-recognition-crossroad-0230 --precisions FP32 && \
    omz_downloader --name vehicle-attributes-recognition-barrier-0039 --precisions FP32 \