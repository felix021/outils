#!/bin/bash

cd `dirname $0`
source ../../shell/color.sh
source ../../shell/confirm.sh

if [ -z "$CK_HOST" -o -z "$CK_USER" -o -z "$CK_PASS" ]; then
        echo "Please set env var CK_HOST, CK_USER, CK_PASS first."
        exit 1
fi

tsv_file=${1}
sql=${2}
skip_check=${3}

if [ -z "$sql" -o -z "$tsv_file" ]; then
        echo Usage: "$0 <tsv_file> <sql> [no_check]"
        exit 1
fi

if [ "$skip_check" != "no_check" ]; then
        set -f
        echo "SQL: ${sql}"
        echo "导出到文件: ${tsv_file}"
        confirm "开始执行?"
        set +f
fi

set -x

mkdir -p tsv

clickhouse client --host "$CK_HOST" --user "$CK_USER" --password "$CK_PASS" --query "
  ${sql} FORMAT TabSeparatedWithNames;
" > tsv/${tsv_file} 