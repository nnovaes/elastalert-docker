
FROM phusion/baseimage:bionic-1.0.0
# Set this environment variable to True to set timezone on container start.
ENV SET_CONTAINER_TIMEZONE False
# Default container timezone as found under the directory /usr/share/zoneinfo/.
ENV CONTAINER_TIMEZONE Europe/Stockholm
# URL from which to download Elastalert.
ENV ELASTALERT_URL https://github.com/nnovaes/elastalert/archive/master.zip
# Directory holding configuration for Elastalert and Supervisor.
ENV CONFIG_DIR /opt/config
# Elastalert rules directory.
ENV RULES_DIRECTORY /opt/rules
# Elastalert configuration file path in configuration directory.
ENV ELASTALERT_CONFIG ${CONFIG_DIR}/elastalert_config.yaml
# Directory to which Elastalert and Supervisor logs are written.
ENV LOG_DIR /opt/logs
# Elastalert home directory full path.
ENV ELASTALERT_HOME /opt/elastalert
# Supervisor configuration file for Elastalert.
ENV ELASTALERT_SUPERVISOR_CONF ${CONFIG_DIR}/elastalert_supervisord.conf
# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST elasticsearchhost
# Port on above Elasticsearch host. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_PORT 9200
# Use TLS to connect to Elasticsearch (True or False)
ENV ELASTICSEARCH_TLS False
# Verify TLS
ENV ELASTICSEARCH_TLS_VERIFY True
# ElastAlert writeback index
ENV ELASTALERT_INDEX log_elastalert

WORKDIR /opt

# Install software required for Elastalert and NTP for time synchronization.
 
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"


RUN apt-get install -y \
    ca-certificates \
#Build dependencies
    libssl-dev \
#   libmagic ?
    openssl \
    libffi-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-yaml \
    gcc \
    musl-dev \
    tzdata \
  #  openntpd \
    wget  \
    libxml2 \
    libcurl4-openssl-dev \
    curl \
    unzip

RUN pip3 install -U pip && \
    pip3 install "setuptools>=11.3" 


# Download and unpack Elastalert.
RUN wget -O elastalert.zip "${ELASTALERT_URL}" && \
    unzip elastalert.zip && \
    rm elastalert.zip && \
    mv e* "${ELASTALERT_HOME}" 

WORKDIR "${ELASTALERT_HOME}"
    
RUN python3 setup.py install && \
    pip3 install -e . && \
    pip3 uninstall twilio --yes && \
    pip3 install twilio==6.0.0  && \
    # Install Supervisor.
    easy_install supervisor 


#remove unecessary stuff
# apk del gcc libffi-dev musl-dev python3-dev openssl-dev

# Create directories. The /var/empty directory is used by openntpd.
RUN mkdir -p "${CONFIG_DIR}" && \
    mkdir -p "${RULES_DIRECTORY}" && \
    mkdir -p "${LOG_DIR}" && \
    mkdir -p /var/empty 


# Clean up.
RUN apt-get remove -y \
    python3-dev \
    musl-dev \
    gcc \
    libssl-dev \
    libffi-dev 



# Copy the script used to launch the Elastalert when a container is started.
COPY ./start-elastalert.sh /opt/
# Make the start-script executable.
RUN chmod +x /opt/start-elastalert.sh

#RUN apk del py3-pip 


# instead of Define mount points.
#VOLUME [ "${CONFIG_DIR}", "${RULES_DIRECTORY}", "${LOG_DIR}"]
# we're copying the files directly, so it's immutable
COPY ./config ${CONFIG_DIR}
COPY ./rules ${RULES_DIRECTORY}

# Launch Elastalert when a container is started.
CMD ["/opt/start-elastalert.sh"]

