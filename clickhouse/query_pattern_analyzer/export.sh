#!/bin/bash

cd `dirname $0`

if [ -f config.sh ]; then
    source config.sh
fi

begin=$1
end=$2
file=${3:-query_log}
cluster=${4}

query_table=system.query_log
if [ ! -z "$cluster" ]; then
    query_table="clusterAllReplicas('$cluster', $query_table)"
fi


if [ -z "$begin" -o -z "$end" ]; then
	echo "Usage: $0 <BEGIN_TIME> <END_TIME> [FILE] [CLUSTER]"
	exit 1
fi

if [ -z "$CK_HOST" -o -z "$CK_PORT" -o -z "$CK_USER" -o -z "$CK_PASS" ]; then
        echo "Please set CK_HOST, CK_PORT, CK_USER, CK_PASS in config.sh or env variables."
        exit 1
fi

exe=`which clickhouse-client`
if [ -z "$exe"]; then
  exe="`which clickhouse`"
  if [ -z "$exe"]; then
    echo "Please install clickhouse client first."
  fi
  exe="$exe client"
fi

echo "Exporting queries between $begin ~ $end ..."

set -x

$exe --host "$CK_HOST" --port "$CK_PORT" --user "$CK_USER" --password "$CK_PASS" --query "
  select
    query_start_time,
    query_duration_ms / 1000 as duration_second,
    memory_usage,
    ProfileEvents.Values[indexOf(ProfileEvents.Names, 'UserTimeMicroseconds')] AS user_cpu,
    read_rows,
    read_bytes,
    written_rows,
    written_bytes,
    query
  from $query_table
  where query_start_time between '$begin' and '$end'
    and type = 'QueryFinish'
        and arrayExists(x -> x LIKE 'system.%', tables) != 1
  order by query_start_time

  FORMAT TabSeparatedWithNames;
" > $file
