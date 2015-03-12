# Cassandra single node
#
# VERSION               0.1
#
# Starts a Cassandra instance constituting a one node cluster. 

FROM christobill/cassandra:base

USER root

# Place single-node startup-config script
ADD scripts/cassandra-singlenode.sh /usr/local/bin/cassandra-singlenode

# Start Cassandra
ENTRYPOINT ["cassandra-singlenode"]

