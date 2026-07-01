FROM rockylinux:9.3.20231119-minimal

ARG TREX_VERSION=v3.08

# trex.tar.gz is pre-downloaded by the CI workflow and placed in the build context
COPY trex.tar.gz /tmp/trex.tar.gz

RUN dnf install -y --nodocs --setopt=install_weak_deps=False \
        procps-ng pciutils iproute && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    tar -zxf /tmp/trex.tar.gz -C /root/ && \
    mv "/root/${TREX_VERSION}" /root/trex && \
    rm /tmp/trex.tar.gz

ENV PATH="/root/trex:${PATH}"
WORKDIR /root/trex
