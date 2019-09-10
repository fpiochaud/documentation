# Formation oracle
## code sql vue en formation
```sql
select 'controlfile',name from v$controlfile
union
select 'logfile',member from v$logfile
union
select 'datafile',name from v$datafile
union 
select 'tempfile',name from v$tempfile;

select * from v$logfile;
select * from v$log;

-- page 32
ALTER DATABASE add logfile '/u01/app/oracle/oradata/orcl/redo04.log' size 50M;
alter database drop logfile '/u01/app/oracle/oradata/orcl/redo04.log';

-- ajout member dans chaque groupe
alter DATABASE add logfile member '/u01/app/oracle/oradata/orcl/redo01_2.log' to group 1;
alter DATABASE add logfile member '/u01/app/oracle/oradata/orcl/redo02_2.log' to group 2;
alter DATABASE add logfile member '/u01/app/oracle/oradata/orcl/redo03_2.log' to group 3;
alter DATABASE add logfile member '/u01/app/oracle/oradata/orcl/redo01_3.log' to group 1;
alter DATABASE add logfile member '/u01/app/oracle/oradata/orcl/redo02_3.log' to group 2;
alter DATABASE add logfile member '/u01/app/oracle/oradata/orcl/redo03_3.log' to group 3;
alter DATABASE drop logfile member '/u01/app/oracle/oradata/orcl/redo01_3.log';
alter DATABASE drop logfile member '/u01/app/oracle/oradata/orcl/redo02_3.log';
alter DATABASE drop logfile member '/u01/app/oracle/oradata/orcl/redo03_3.log';

alter system CHECKPOINT;

alter system SWITCH logfile;

create pfile='/home/oracle/pfile.ora' from spfile;

alter system set control_files='/u01/app/oracle/oradata/orcl/control01.ctl', '/u01/app/oracle/oradata/orcl/control03.ctl', '/u01/app/oracle/flash_recovery_area/orcl/control02.ctl' scope=spfile;

show parameter control;

select * from v$parameter where name like '%control%';

ARCHIVE log LIST;

select * from v$parameter where name like '%pga%';

show parameter session;

show parameter dispatchers;

```
## Process oracle
DBW0 -> SGA et PGA
LOGWR -> log
ARCX -> archivage
SMON -> System Monitor
PMON -> Process monitor
CKPT -> Checkpoint 
RECO -> recover
VKTM -process temp
RBO -> rule
CBO -> cost
MMON
MMNL
MMAN
