#!/bin/bash

cd `dirname $0`
source ../../shell/color.sh
source ../../shell/confirm.sh

if [ -z "$CK_TEST_HOST" -o -z "$CK_TEST_USER" -o -z "$CK_TEST_PASS" ]; then
        echo "Please set env var CK_TEST_HOST, CK_TEST_USER, CK_TEST_PASS first."
        exit 1
fi

table=${1}
tsv_file=${2}
skip_check=${3}

if [ -z "$table" -o -z "$tsv_file" ]; then
        echo Usage: "$0 <table> <tsv_file> [no_check]"
        exit 1
fi

if [ "$skip_check" != "no_check" ]; then
        confirm "将 ${tsv_file} 导入到 wizard.${table} ?"
fi

set -x

clickhouse client --host "$CK_TEST_HOST" --user "$CK_TEST_USER" --password "$CK_TEST_PASS" --query "
    INSERT INTO wizard.${table}
    FORMAT TabSeparatedWithNames
" < ${tsv_file}