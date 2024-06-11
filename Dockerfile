### ---------------------------------------: BASE
FROM --platform=linux/amd64  ubuntu:jammy AS base

LABEL maintainer="adam@jakab.pro"
LABEL version="0.0.2"
LABEL description="ConnectIQ Builder"

### ---------------------------------------: SYSTEM
FROM base AS system
RUN apt update
RUN apt -y install curl jq wget zip openjdk-17-jre-headless libsm6 xvfb openssl libwebkit2gtk-4.0-37 libusb-1.0-0
RUN apt clean

### ---------------------------------------: BUILDER
FROM system AS builder

# ConnectIQ home folder
RUN mkdir /connectiq

# ConnectIQ version
ENV CONNECTIQ_VERSION 7.1.1

# download the SDK
COPY downloader.sh /tmp/downloader.sh
RUN /tmp/downloader.sh /connectiq $CONNECTIQ_VERSION

# manage device files
COPY devices.tar.gz /tmp/devices.tar.gz
RUN mkdir -p /root/.Garmin/ConnectIQ/Devices
RUN tar -xf /tmp/devices.tar.gz -C /root/.Garmin/ConnectIQ/Devices
RUN rm /tmp/devices.tar.gz

# Copy custom scripts
COPY tester.sh /connectiq/bin/


### ---------------------------------------: RUNNER
FROM builder AS runner
ENV PATH ${PATH}:/connectiq/bin


