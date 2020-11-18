
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
    libssl-dev

# Install required python packages
COPY ./requirements.txt ./
RUN pip3 install -r /opt/requirements.txt

# Install elastalert
RUN pip3 install elastalert 