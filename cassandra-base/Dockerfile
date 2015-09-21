# Cassandra 2.1 Base Image
#
# VERSION               0.1
#
# Installs Cassandra 2.1 package. 

FROM christobill/oracle-java7:latest

ENV DEBIAN_FRONTEND noninteractive

# Add DataStax sources
ADD datastax_key /tmp/datastax_key
RUN apt-key add /tmp/datastax_key
RUN echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list

# Install Cassandra 2.1.3
RUN apt-get update && \
    apt-get install -y dsc21 cassandra=2.1.9 cassandra-tools=2.1.9 && \
    rm -rf /var/lib/apt/lists/*

ENV CASSANDRA_CONFIG /etc/cassandra

# Run base config script
ADD scripts/config-cassandra-base.sh /usr/local/bin/config-cassandra-base
RUN /usr/local/bin/config-cassandra-base

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

EXPOSE 7199 7000 7001 9160 9042 22 8012 61621

CMD [""]
