# Cassandra 3.0.9 Base Image
#
# VERSION               0.1
#
# Installs Cassandra 3.0.9 package.

FROM christobill/oracle-java8:latest

ENV DEBIAN_FRONTEND noninteractive

# Add DataStax sources
ADD datastax_key /tmp/datastax_key
RUN apt-key add /tmp/datastax_key
RUN echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list

# Install Cassandra 3.0.9
RUN apt-get update && \
    apt-get install -y --force-yes cassandra=3.0.9 cassandra-tools=3.0.9 dsc30=3.0.9-1 datastax-agent=5.2.4 && \
    rm -rf /var/lib/apt/lists/*

ENV CASSANDRA_CONFIG /etc/cassandra

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

# Agent config test
RUN echo "stomp_interface: opscenter.marathon.mesos" | sudo tee -a /var/lib/datastax-agent/conf/address.yaml
RUN sudo service datastax-agent start

EXPOSE 7199 7000 7001 9160 9042 22 8012 61621

CMD [""]
