
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
COPY ./config/  ./opt/config    
COPY ./rules    ./opt/rules


RUN pip3 install -U jira

# cleanup

#RUN apt-get remove -y \
#    python3-dev \
#    python3-pip  \
#    libssl-dev \
#    libffi-dev

CMD ["/bin/sh"]