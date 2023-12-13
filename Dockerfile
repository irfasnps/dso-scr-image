FROM python:3.11-slim

WORKDIR /scr

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    gcc \
    cloc \
    git \
    curl \
    unzip \
    make && \
    curl -sLo polaris_cli.zip https://sig-cons-ms-sca.polaris.synopsys.com/api/tools/v2/downloads/polaris_cli-linux64-2023.9.0.zip && \
    unzip polaris_cli.zip && \
    rm -f polaris_cli.zip

ENV PATH="$PATH:/scr/polaris_cli-linux64-2023.9.0/bin/"

RUN curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

RUN pip install whispers detect-secrets semgrep
