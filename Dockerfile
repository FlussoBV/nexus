FROM openjdk:8-jdk-alpine

MAINTAINER Joost van der Griendt <j.vandergriendt@flusso.nl>
LABEL authors="Joost van der Griendt <j.vandergriendt@flusso.nl>"
LABEL version="3.5.1-1"
LABEL description="Docker container for Nexus 3 For Docker Swarm"

ENV SONATYPE_DIR="/opt/sonatype"
ENV NEXUS_VERSION="3.5.1-02" \
    NEXUS_HOME="${SONATYPE_DIR}/nexus" \
    NEXUS_DATA="/nexus-data" \
    NEXUS_BLOB_DATA="/blob" \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work \
    JAVA_MIN_MEM="256M" \
    JAVA_MAX_MEM="256M" \
    JKS_STORE="changeit" \
    JKS_PASSWORD_FILE="changeit"\
    JKS_PASSWORD="changeit"
ENV CONTEXT_PATH /nexus
RUN set -x \
    && apk --no-cache add \
        openssl \
        su-exec \
    && mkdir -p "${SONATYPE_DIR}" \
    && wget -qO - "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz" \
    | tar -zxC "${SONATYPE_DIR}" \
    && mv "${SONATYPE_DIR}/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}" \
    && adduser -S -h ${NEXUS_DATA} nexus \
    && find "${NEXUS_HOME}" -exec chown -R nexus {} \; \
    && find "${SONATYPE_WORK}" -exec chown -R nexus {} \; 

EXPOSE 8081 8443

RUN mkdir -p "${NEXUS_BLOB_DATA}" \
    && find "${NEXUS_BLOB_DATA}" -exec chown -R nexus {} \;

USER nexus

RUN mkdir -p "${NEXUS_BLOB_DATA}/maven" \
    && mkdir -p "${NEXUS_BLOB_DATA}/npm" \
    && mkdir -p "${NEXUS_BLOB_DATA}/docker" \
    && mkdir -p "${NEXUS_BLOB_DATA}/bower" \
    && mkdir -p "${NEXUS_BLOB_DATA}/gitlfs" \
    && mkdir -p "${NEXUS_BLOB_DATA}/nuget" \
    && mkdir -p "${NEXUS_BLOB_DATA}/pypi" \
    && mkdir -p "${NEXUS_BLOB_DATA}/raw" \
    && mkdir -p "${NEXUS_BLOB_DATA}/rubygems" \
    && mkdir -p "${NEXUS_BLOB_DATA}/yum"

VOLUME "${NEXUS_DATA}"
VOLUME "${NEXUS_BLOB_DATA}"


COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR "${NEXUS_HOME}"

CMD ["bin/nexus", "run"]
