#!/bin/bash

cd `dirname $0`

if [ -f config.sh ]; then
  source config.sh
fi

if [ -z "$DB_HOST" -o -z "$DB_PORT" -o -z "$DB_USER" -o -z "$DB_PASS" ]; then
    echo "Please set DB_HOST, DB_PORT, DB_USER, DB_PASS in `pwd`/config.sh or environmental variables"
    exit 1
fi

begin=$1
end=$2
file=${3}
cluster=${4}

if [ -z "$begin" -o -z "$end" ]; then
	echo "Usage: $0 <BEGIN_TIME> <END_TIME> [FILE]"
	exit 1
fi

if [ -z "$file" ]; then
    now=`date +'%Y%m%d-%H%M%S'`
    file=query_log_$now
fi

echo "导出 $begin ~ $end 的查询..."

set -e
set -x

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "
  select
    time,
    query_time / 1000 as query_time_second,
    cpu_time_ms / 1000 as cpu_time_second,
    peak_memory_bytes / 1024 / 1024 as peak_memory_mb,
    load_rows,
    load_bytes / 1024 / 1024 as load_mb,
    scan_rows,
    scan_bytes  / 1024 / 1024 as scan_mb,
    scan_bytes_from_remote_storage / 1024 / 1024 as scan_remote_mb,
    replace(stmt, '\r', '') as stmt
  from __internal_schema.audit_log
  where time between '$begin' and '$end'
" > $file

echo "Output to $file."