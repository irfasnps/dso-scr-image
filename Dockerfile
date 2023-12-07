FROM python:3.11

WORKDIR /scr

COPY . /scr

RUN apt-get update && apt-get upgrade -y && \
    wget https://sig-cons-ms-sca.polaris.synopsys.com/api/tools/v2/downloads/polaris_cli-linux64-2023.9.0.zip && \
    unzip polaris_cli-linux64-2023.9.0.zip && \
    rm -f polaris_cli-linux64-2023.9.0.zip

ENV PATH="$PATH:/scr/polaris_cli-linux64-2023.9.0/bin/"
