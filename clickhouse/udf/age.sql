create function getIdCardBirthDate
on cluster default_cluster
as (id_num) ->
    parseDateTime64BestEffort(if(match(id_num, '^[0-9]{17}[0-9Xx]$'), substring(id_num, 7, 8), '19000101'));

create function calcAgeBetween
on cluster default_cluster
as (beginDate, endDate) ->
    dateDiff('year', toDateTime64(beginDate, 3), toDateTime64(endDate, 3))
    - 
    if(formatDateTime(toDateTime64(beginDate, 3), '%m%d') > formatDateTime(toDateTime64(endDate, 3), '%m%d'), 1, 0);

create function calcAge
on cluster default_cluster
as (d) -> calcAgeBetween(d, today());