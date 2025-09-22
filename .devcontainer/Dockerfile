FROM ubuntu:24.04

ARG ANDROID_API_LEVEL=33
# https://developer.android.com/studio/releases/build-tools
ARG ANDROID_BUILD_TOOLS_LEVEL=34.0.0
# https://developer.android.com/ndk/downloads
# using the latest LTS version
ARG ANDROID_NDK_VERSION=27.3.13750724
# https://developer.android.com/studio#command-tools (At the bottom)
ARG ANDROID_CMD_LINE_TOOLS=linux-13114758_latest
ARG CMAKE_VERSION=3.30.2
ARG GRADLE_VERSION=8.10
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    vim \
    python3 \ 
    build-essential \
    libssl-dev \
    ninja-build \
    unzip \
    openjdk-17-jdk \
    vim \
    git \
    python3-pip \
    bash-completion \
    wget \
    ccache \
    libgl1-mesa-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libvulkan-dev \
    libxcb-cursor-dev \
    libxcb1-dev \
    libxkbcommon-x11-dev \
    libxcb-keysyms1-dev \
    libxcb-icccm4-dev \
    libwayland-cursor0 \
    libwayland-egl1 \
    dotnet-sdk-8.0 \
    pulseaudio \
    locales \
    clang-format \
    clangd \
    gdb


# install latest cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && chmod +x ./cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && ./cmake-${CMAKE_VERSION}-linux-x86_64.sh --skip-license --prefix=/usr/local 

# Download android commandlinetools
RUN mkdir -p /opt/android
RUN curl -o /tmp/commandlinetools-${ANDROID_CMD_LINE_TOOLS}.zip -L https://dl.google.com/android/repository/commandlinetools-${ANDROID_CMD_LINE_TOOLS}.zip 
RUN unzip -q -d /opt/android/cmdline-tools /tmp/commandlinetools-${ANDROID_CMD_LINE_TOOLS}.zip

# Download gradle, install gradle and gradlew
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp
RUN unzip -q -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip
RUN mkdir /opt/gradlew && touch /opt/gradlew/settings.gradle
RUN /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper --gradle-version ${GRADLE_VERSION} --distribution-type all -p /opt/gradlew
RUN /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper -p /opt/gradlew

# install packages and accept all licenses
# cmdline-tools/cmdline-tools - the second "cmdline-tools" is the folder in the zip file
RUN yes Y | /opt/android/cmdline-tools/cmdline-tools/bin/sdkmanager --install "build-tools;${ANDROID_BUILD_TOOLS_LEVEL}" "platforms;android-${ANDROID_API_LEVEL}" "platform-tools" "ndk;${ANDROID_NDK_VERSION}" \
    && yes Y | /opt/android/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses

# Clean up
RUN rm /tmp/commandlinetools-${ANDROID_CMD_LINE_TOOLS}.zip

ENV GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION
ENV ANDROID_HOME=/opt/android
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}
ENV ANDROID_API_LEVEL=${ANDROID_API_LEVEL}

# overwrite any system installed packages with pip installed packages
RUN pip install --break-system-packages aqtinstall conan cmake-format

RUN aqt install-qt \
    linux android \
    6.6.1 \
    android_armv7 \
    -m qtmultimedia \
    --autodesktop \
    --outputdir /opt/Qt 

RUN aqt install-qt \
    linux android \
    6.6.1 \
    android_arm64_v8a\
    -m qtmultimedia \
    --autodesktop \
    --outputdir /opt/Qt 

RUN aqt install-qt \
    linux android \
    6.6.1 \
    android_x86_64\
    -m qtmultimedia \
    --autodesktop \
    --outputdir /opt/Qt 

# Autodesktop does not install all the modules
# the desktop version needs to be installed explicitly with all modules
RUN aqt install-qt \
    linux desktop \
    6.6.1 \
    gcc_64\
    -m qtmultimedia \
    --outputdir /opt/Qt


# the docker image for ubuntu 24.04 comes with a user "ubuntu", we remove it to not break compatibility with earlier versions
RUN userdel -r ubuntu
# create and user builder:builder
RUN groupadd -r builder && useradd --create-home --gid builder --shell /bin/bash builder && mkdir -p /etc/sudoers.d && echo 'builder ALL=NOPASSWD: ALL' > /etc/sudoers.d/builder
RUN usermod -aG video builder

# Add /opt/Qt/6.6.1/gcc_64/bin/ to the PATH environment variable in the .profile rc
RUN echo 'export PATH="/opt/Qt/6.6.1/gcc_64/bin/:$PATH"' >> /home/builder/.profile

# Install git shell extension
RUN curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > /home/builder/.bash_git && echo "source ~/.bash_git" >> /home/builder/.bashrc
RUN sed -Ei 's/(PS1=.*)(\\\[\\033\[00m\\\]\\\$.*)/\1\\[\\033[01;33m\\]$(__git_ps1)\2/p' /home/builder/.bashrc
RUN chown builder:builder /home/builder/.bash_git /home/builder/.bashrc

USER builder
# Create the profiles for conan for user builder

RUN conan profile new default --detect
COPY ./create_android_profile.sh /home/builder/create_android_profile.sh
RUN chmod +x /home/builder/create_android_profile.sh && /home/builder/create_android_profile.sh

USER root
