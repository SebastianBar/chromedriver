FROM ubuntu:20.04

# Install Chromium build dependencies.
RUN apt-get -qq update && apt-get -qq dist-upgrade && apt-get -qq install git build-essential clang curl lsb-release
# Install Chromium's depot_tools.
ENV DEPOT_TOOLS /usr/bin/depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS
# Add Chromium's depot_tools to the PATH.
ENV PATH $PATH:$DEPOT_TOOLS
RUN echo "export PATH=\"\$PATH:$DEPOT_TOOLS\"" >> .bashrc

RUN git config --global https.postBuffer 1048576000

# Download Chromium sources.
RUN fetch --nohooks --no-history chromium

WORKDIR /

RUN gclient runhooks

WORKDIR src

RUN build/install-build-deps.sh --no-prompt

RUN gn gen out/Release --args="is_debug=false target_cpu=\"arm64\""
RUN ninja -C out/Release chromedriver

RUN cp out/Release/chromedriver /usr/bin/chromedriver

WORKDIR /
