FROM rockylinux:9.3.20231119-minimal

ARG TREX_VERSION=v3.08

# trex.tar.gz is pre-downloaded by the CI workflow and placed in the build context
COPY trex.tar.gz /tmp/trex.tar.gz

RUN microdnf install -y --setopt=install_weak_deps=0 --nodocs \
        procps-ng pciutils iproute && \
    \
    # Fetch only the Intel ice DDP firmware from the upstream linux-firmware git
    # repo (uncompressed, no RPM, no unxz). Resolves the current version
    # dynamically from WHENCE — no hardcoded filename.
    LF_BASE="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain" && \
    DDP_REL="$(curl -fsSL "${LF_BASE}/WHENCE" | grep -oE 'intel/ice/ddp/ice-[0-9.]+\.pkg' | head -1)" && \
    echo "Resolved DDP file: ${DDP_REL}" && \
    mkdir -p /lib/firmware/intel/ice/ddp && \
    curl -fsSL -o "/lib/firmware/${DDP_REL}" "${LF_BASE}/${DDP_REL}" && \
    ln -sf "$(basename "${DDP_REL}")" /lib/firmware/intel/ice/ddp/ice.pkg && \
    \
    microdnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum && \
    \
    tar -zxf /tmp/trex.tar.gz -C /root/ && \
    mv "/root/${TREX_VERSION}" /root/trex && \
    rm /tmp/trex.tar.gz

ENV PATH="/root/trex:${PATH}"
WORKDIR /root/trex
