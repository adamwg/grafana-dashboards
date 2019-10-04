FROM debian:stretch-slim
MAINTAINER Adam Wolfe Gordon <awg@digitalocean.com>
ARG jsonnet_version=v0.14.0

ADD cleanup.sh /cleanup.sh

ADD https://github.com/google/jsonnet/releases/download/${jsonnet_version}/jsonnet-bin-${jsonnet_version}-linux.tar.gz /jsonnet.tar.gz
ADD https://github.com/grafana/grafonnet-lib/archive/master.tar.gz /grafonnet.tar.gz

RUN apt-get update && apt-get install -y curl jq git && apt-get clean && /cleanup.sh && \
    tar -C /bin -xvf /jsonnet.tar.gz && \
    tar -C / -xvf /grafonnet.tar.gz && \
    mv /grafonnet-lib-master /grafonnet-lib && \
    rm -f /jsonnet.tar.gz /grafonnet.tar.gz
