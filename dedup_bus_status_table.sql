-- Please enter this line of code into your superset and then save it as a virtual dataset so that you can start building dashboards from this deduplicated data
select * from
(select *, row_number() over (partition by record_id) as dedup 
from awsdatacatalog.{insert athena database name}.{insert athena table name}) A
where dedup=1
order by record_id
