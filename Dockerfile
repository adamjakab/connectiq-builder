### ---------------------------------------: BASE
FROM --platform=linux/amd64  alpine:latest AS base

LABEL maintainer="adam@jakab.pro"
LABEL version="0.0.1"
LABEL description="ConnectIQ Builder"

### ---------------------------------------: SYSTEM
FROM base AS system
RUN apk upgrade --no-cache
#RUN apk add --no-cache libc6-compat
RUN apk add --no-cache bash


### ---------------------------------------: DEP-BUILDER
FROM system AS dep-builder
RUN apk add --no-cache curl jq wget 

# ConnectIQ home folder
RUN mkdir /connectiq

# ConnectIQ version
ENV CONNECTIQ_VERSION 7.1.1

# download the SDK
COPY downloader.sh /tmp/downloader.sh
RUN /tmp/downloader.sh /connectiq $CONNECTIQ_VERSION

# manage device files
COPY devices.tar.gz /tmp/devices.tar.gz
RUN mkdir /connectiq-devices
RUN tar -xf /tmp/devices.tar.gz -C /connectiq-devices



### ---------------------------------------: RUNNER
FROM system AS runner
RUN apk upgrade --no-cache
# RUN apk add --no-cache bash
RUN apk add --no-cache openjdk17-jre-headless
RUN apk add --no-cache webkit2gtk
RUN apk add --no-cache libusb
RUN apk add --no-cache libsm
RUN apk add --no-cache xvfb
RUN apk add --no-cache openssl

# Device files
RUN mkdir -p /root/.Garmin/ConnectIQ/Devices
COPY --from=dep-builder /connectiq-devices /root/.Garmin/ConnectIQ/Devices

# ConnectIQ home folder
RUN mkdir /connectiq
COPY --from=dep-builder /connectiq /connectiq
ENV PATH ${PATH}:/connectiq/bin

# copy custom tester script
COPY tester.sh "/connectiq/bin/tester.sh"

ENTRYPOINT [ "/bin/bash" ]
# CMD ["sleep", "infinity"]
