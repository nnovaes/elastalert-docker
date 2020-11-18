
FROM phusion/baseimage:bionic-1.0.0
WORKDIR /opt
# Update image
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options:="--force-confold"

#Install required ubuntu packages
RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    libffi-dev \
    libssl-dev \
    git

# Install required python packages
COPY ./requirements.txt ./
RUN pip3 install -r /opt/requirements.txt && git clone https://github.com/Yelp/elastalert.git

# Install elastalert

WORKDIR /opt/elastalert
COPY ./requirements.txt ./requirements.txt
RUN pip3 install "setuptools>=11.3"
RUN python3 setup.py install

COPY ./config/  ./opt/config    
COPY ./rules    ./opt/rules


#RUN pip3 install -U jira

# cleanup

RUN apt-get remove -y \
    python3-dev \
    python3-pip  \
    libssl-dev \
    libffi-dev

RUN mkdir -p /opt/elastalert && \
    echo "#!/bin/sh" >> /opt/elastalert/run.sh && \
    echo "set -e" >> /opt/elastalert/run.sh && \
    echo "elastalert-create-index --config /opt/config/elastalert_config.yaml" >> /opt/elastalert/run.sh && \
    echo "exec elastalert --config /opt/config/elastalert_config.yaml \"\$@\"" >> /opt/elastalert/run.sh && \
    chmod +x /opt/elastalert/run.sh

ENV TZ "UTC"

ENTRYPOINT ["/opt/elastalert/run.sh"]
