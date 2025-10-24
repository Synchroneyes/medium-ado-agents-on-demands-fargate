FROM ubuntu:24.04
RUN apt update
RUN apt upgrade -y

RUN apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    wget \
    unzip \
    gnupg-agent \
    python3 \
    python3-pip \
    python3-venv \
    dos2unix \
    golang-go \
    groff

ENV TARGETARCH=linux-x64
RUN apt-get install -y python3-pip 
RUN pip install awscliv2 --upgrade --break-system-packages

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

RUN useradd agent
RUN chown agent ./
USER agent

USER root
RUN apt-get update && apt-get install -y jq

ARG TARGETARCH=linux-x64

RUN curl -LsS https://download.agent.dev.azure.com/agent/4.261.0/vsts-agent-linux-x64-4.261.0.tar.gz | tar -xz -C /azp


RUN wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb \
        && apt install ./libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb

ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT ["/bin/bash", "./start.sh"]

HEALTHCHECK --interval=1m --timeout=10s --start-period=5s --retries=3 \
  CMD pgrep -F /var/run/azp_agent.pid || exit 1