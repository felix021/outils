# Doris 慢查询聚合分析

有些查询单次耗时不长，但是查询量大，可能占用了资源大头，可以用这个工具导出所有查询，聚合分析。

# 使用

0. 开启审计

在 Doris 执行：

```sql
-- 开启审计日志
set global enable_audit_plugin = true;

-- 存储最长 10KB 的 SQL（默认 4096，具体值可按需调整）
set global audit_plugin_max_sql_length = 10240;
```

1. virtualenv

```bash
virtualenv venv
source venv/bin/activate
pip3 install pandas pandarallel sqlparse
```

2. 修改 config.sh 中的配置(host/port/user/pass)

```bash
cp config_example.sh config.sh

vi config.sh
```

3. 导出一段时间的查询：

```bash
./export.sh '2025-04-21 19:15:00' '2025-04-21 19:20:00'
```

4. 聚合分析，结果输出到 query_log.tsv

```bash
./analyze.py query_log
```