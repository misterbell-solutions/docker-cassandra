#!/usr/bin/env bash

# Get running container's IP
IP=`hostname --ip-address`

# 0.0.0.0 Listens on all configured interfaces
# but you must set the broadcast_rpc_address to a value other than 0.0.0.0
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/" $CASSANDRA_CONFIG/cassandra.yaml

# Set broadcast_rpc_address
sed -i -e "s/^# broadcast_rpc_address.*/broadcast_rpc_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# Listen on IP:port of the container
sed -i -e "s/^listen_address.*/listen_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# Broadcast on IP:port of the container
sed -i -e "s/^# broadcast_address.*/broadcast_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# Configure Cassandra seeds
if [ -z "$CASSANDRA_SEEDS" ]; then
	echo "No seeds specified, being my own seed..."
        if [ $# == 1 ]; then
            SEEDS="$1"
        else
            SEEDS="$IP"
        fi
	CASSANDRA_SEEDS=$SEEDS
fi
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$CASSANDRA_SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml

# Most likely not needed
# relates to the folllowing issue (nodetool remote connection issue):
# http://www.datastax.com/documentation/cassandra/2.1/cassandra/troubleshooting/trblshootConnectionsFail_r.html
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

sed -i 's/LOCAL_JMX=yes/LOCAL_JMX=no/g' $CASSANDRA_CONFIG/cassandra-env.sh
sed -i 's/com.sun.management.jmxremote.authenticate=true/com.sun.management.jmxremote.authenticate=false/g' $CASSANDRA_CONFIG/cassandra-env.sh
sed -i 's/  JVM_OPTS=\"$JVM_OPTS -Dcom.sun.management.jmxremote.password.file/#  JVM_OPTS=\"$JVM_OPTS -Dcom.sun.management.jmxremote.password.file/g' $CASSANDRA_CONFIG/cassandra-env.sh
sed -i "s,system_memory_in_mb=\`free \-m.*,system_memory_in_mb=\`cat /sys/fs/cgroup/memory/memory.limit_in_bytes | awk \'{print int(\$1 / (1024 * 1024))}\'\`,g" /etc/cassandra/cassandra-env.sh
sed -i "s,system_cpu_cores=\`egrep \-c .*,system_cpu_cores=\`cat /sys/fs/cgroup/cpu/cpu.shares | awk \'{print \$1 / 1024}\'\`,g" /etc/cassandra/cassandra-env.sh
# Default value if CASSANDRA_DC is not set
if [ -z "$CASSANDRA_BOOTSTRAP" ]; then
        echo -e "\n" >> $CASSANDRA_CONFIG/cassandra.yaml
        echo "# Setting the auto_bootstrap" >> $CASSANDRA_CONFIG/cassandra.yaml
        echo "auto_bootstrap: $CASSANDRA_BOOTSTRAP" >> $CASSANDRA_CONFIG/cassandra.yaml
fi

sed -i "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: GossipingPropertyFileSnitch/g" $CASSANDRA_CONFIG/cassandra.yaml

# Default value if CASSANDRA_DC is not set
if [ -z "$CASSANDRA_DC" ]; then
        CASSANDRA_DC=DC1
fi

# Default value if CASSANDRA_RACK is not set
if [ -z "$CASSANDRA_RACK" ]; then
        CASSANDRA_RACK=RAC1
fi

# Default value if CASSANDRA_RACK is not set
if [ -z "$CASSANDRA_CLUSTER" ]; then
        CASSANDRA_CLUSTER="Test Cluster"
fi

# Default value if CASSANDRA_NUM_TOKENS is not set
if [ -z "$CASSANDRA_NUM_TOKENS" ]; then
        CASSANDRA_NUM_TOKENS=256
fi

# Setting the cluster name
sed -i -e s?cluster_name:"[ \'0-9a-zA-Z]*"?"cluster_name: \'$CASSANDRA_CLUSTER\'"?g $CASSANDRA_CONFIG/cassandra.yaml

# Setting the datacenter and rack
sed -i "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: GossipingPropertyFileSnitch/g" $CASSANDRA_CONFIG/cassandra.yaml
sed -i "s/dc=DC1/dc=$CASSANDRA_DC/g" $CASSANDRA_CONFIG/cassandra-rackdc.properties
sed -i "s/rack=RAC1/rack=$CASSANDRA_RACK/g" $CASSANDRA_CONFIG/cassandra-rackdc.properties

# Setting the num_tokens
sed -i -e s?num_tokens:"[ \'0-9a-zA-Z]*"?"num_tokens: $CASSANDRA_NUM_TOKENS"?g $CASSANDRA_CONFIG/cassandra.yaml

# Security
sed -i "s/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/g" $CASSANDRA_CONFIG/cassandra.yaml
sed -i "s/authorizer: AllowAllAuthorizer/authorizer: CassandraAuthorizer/g" $CASSANDRA_CONFIG/cassandra.yaml

echo "Starting Cassandra on $IP..."



cassandra -f
