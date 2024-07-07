### ---------------------------------------: BASE
FROM --platform=linux/amd64  ubuntu:jammy AS base

### ---------------------------------------: SYSTEM
FROM base AS system
RUN apt update
RUN apt -y install curl jq wget zip openjdk-17-jre-headless libsm6 xvfb openssl libwebkit2gtk-4.0-37 libusb-1.0-0
RUN apt clean


### ---------------------------------------: BUILDER
FROM system AS builder

# Set SDK VERSION
ARG SDK_VERSION
ENV SDK_VERSION=${SDK_VERSION:-7.1.1}
RUN echo "Using Connect IQ SDK version: $SDK_VERSION"

# Make the ConnectIQ home folder and download the SDK
RUN mkdir /connectiq
COPY downloader.sh /tmp/downloader.sh
RUN /tmp/downloader.sh /connectiq $SDK_VERSION

# manage device files
COPY devices.tar.gz /tmp/devices.tar.gz
RUN mkdir -p /root/.Garmin/ConnectIQ/Devices
RUN tar -xf /tmp/devices.tar.gz -C /root/.Garmin/ConnectIQ/Devices
RUN rm /tmp/devices.tar.gz

# Copy custom scripts
COPY scripts/ /scripts


### ---------------------------------------: RUNNER
FROM builder AS runner
ENV PATH ${PATH}:/connectiq/bin
CMD ["/scripts/info.sh"]
