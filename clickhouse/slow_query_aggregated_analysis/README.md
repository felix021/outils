# ClickHouse 慢查询聚合分析

有些查询单次耗时不长，但是查询量大，可能占用了资源大头，可以用这个工具导出所有查询，聚合分析。

# 使用

1. 修改 export.sh 中的配置(host/user/pass)

2. 导出一段时间的查询：

```bash
./export.sh '2025-04-21 19:15:00' '2025-04-21 19:20:00'
```

3. 聚合分析，结果输出到 query_log.tsv

```bash
./analyze.py query_log
```