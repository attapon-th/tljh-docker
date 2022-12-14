# Systemd inside a Docker container, for CI only
ARG ubuntu_version=20.04
FROM ubuntu:${ubuntu_version}

USER root

ENV \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Bangkok



# DEBIAN_FRONTEND is set to avoid being asked for input and hang during build:
# https://anonoz.github.io/tech/2020/04/24/docker-build-stuck-tzdata.html
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --yes \
    build-essential \
    systemd \
    curl \
    git \
    sudo \
    python3 \
    python3-venv \
    python3-pip \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*



# Kill all the things we don't need
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

RUN mkdir -p /etc/sudoers.d

RUN systemctl set-default multi-user.target

STOPSIGNAL SIGRTMIN+3

# Uncomment these lines for a development install
# ENV TLJH_BOOTSTRAP_DEV=yes \
#     TLJH_BOOTSTRAP_PIP_SPEC=/srv/src \
ENV PATH=/opt/tljh/hub/bin:${PATH} 

EXPOSE 80


CMD ["/bin/bash", "-c", "exec /lib/systemd/systemd --log-target=journal 3>&1"]
