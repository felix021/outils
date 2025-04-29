#!/bin/bash

cd `dirname $0`

begin=$1
end=$2
file=${3:-query_log}

if [ -z "$begin" -o -z "$end" ]; then
	echo "Usage: $0 <BEGIN_TIME> <END_TIME> [FILE]"
	exit 1
fi

if [ -z "$CK_HOST" -o -z "$CK_USER" -o -z "$CK_PASS" ]; then
        echo "Please set env var CK_HOST, CK_USER, CK_PASS first."
        exit 1
fi

echo "导出 $begin ~ $end 的查询..."

set -x

clickhouse client --host "$CK_HOST" --user "$CK_USER" --password "$CK_PASS" --query "
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
  from system.query_log
  where query_start_time between '$begin' and '$end'
    and type = 'QueryFinish'
    and arrayExists(x -> x LIKE '\''system.%'\'', tables) != 1
  order by query_start_time

  FORMAT TabSeparatedWithNames;
" > $file