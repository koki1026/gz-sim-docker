# ARG ROS_DISTRO
# FROM ros:${ROS_DISTRO}

# ENV COLCON_WS=/root/colcon_ws
# ENV COLCON_WS_SRC=/root/colcon_ws/src
# ENV PYTHONWARNINGS="ignore:setup.py install is deprecated::setuptools.command.install"

# ENV DEBIAN_FRONTEND noninteractive

# # see https://gazebosim.org/docs/harmonic/install_ubuntu
# ARG GZ_VERSION

# RUN apt-get update -qq \
#     && apt-get install -y \
#         wget \
#     && rm -rf /var/lib/apt/lists/*

# RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg\
#     && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# RUN apt-get update -qq \
#     && apt-get install -y \
#         gz-${GZ_VERSION} \
#         build-essential\
#         ros-${ROS_DISTRO}-rcl-interfaces\
#         ros-${ROS_DISTRO}-rclcpp\
#         ros-${ROS_DISTRO}-builtin-interfaces\
#         ros-${ROS_DISTRO}-ros-gz\
#         ros-${ROS_DISTRO}-sdformat-urdf\
#         ros-${ROS_DISTRO}-vision-msgs\
#         ros-${ROS_DISTRO}-actuator-msgs\
#         ros-${ROS_DISTRO}-image-transport\
#     && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p ${COLCON_WS_SRC}\
#     && cd ${COLCON_WS}\
#     && . /opt/ros/${ROS_DISTRO}/setup.sh\
#     && colcon build

# CMD gz sim

# ベースイメージに GUI/ツール込みの full バージョン
FROM osrf/ros:humble-desktop-full

ARG ROS_DISTRO=humble
ARG GZ_VERSION=harmonic

ENV DEBIAN_FRONTEND=noninteractive
ENV COLCON_WS=/root/colcon_ws
ENV COLCON_WS_SRC=${COLCON_WS}/src
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Etc/UTC

# タイムゾーンと基本開発ツール
RUN echo $TZ > /etc/timezone && \
  ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  apt update && \
  apt install -y \
    build-essential \
    wget \
    gnupg2 \
    lsb-release \
    sudo \
    curl \
    git \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-pip \
    x11-xserver-utils \
    libgl1-mesa-glx \
    libxrender1 \
    libxext6 \
    libqt5widgets5 \
    xvfb \
    && apt clean

# Gazebo Harmonic インストール
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list && \
    apt update && \
    apt install -y \
        gz-${GZ_VERSION} \
        ros-${ROS_DISTRO}-ros-gz \
        ros-${ROS_DISTRO}-image-transport \
        ros-${ROS_DISTRO}-vision-msgs \
        ros-${ROS_DISTRO}-xacro \
        ros-${ROS_DISTRO}-rqt-graph \
        ros-${ROS_DISTRO}-rqt-image-view \
        ros-${ROS_DISTRO}-rqt-plot \
        ros-${ROS_DISTRO}-rviz2 \
        && apt clean

# 作業スペース作成
RUN mkdir -p ${COLCON_WS_SRC}

# ワークスペース初期化（VRXをあとでマウントしてもOK）
WORKDIR ${COLCON_WS}

# ビルドは起動後に行う想定（volume mountして src にVRXを入れてから）
CMD ["/bin/bash"]