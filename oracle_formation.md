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
--
show parameter block;

create tablespace franck_ts datafile '/u01/app/oracle/oradata/orcl/franck_ts01.dbf' size 5M;
drop tablespace franck_off_ts including contents and datafiles;

select * from dba_tablespaces where tablespace_name like 'FRANCK_%TS';
select * from dba_data_files where tablespace_name like 'FRANCK_%TS';
select * from v$tablespace;

alter tablespace franck_ts coalesce; --defrag tbs
create temporary tablespace franck_tmp tempfile '/u01/app/oracle/oradata/orcl/franck_tmp.dbf' size 10M;
create undo tablespace franck_undo datafile '/u01/app/oracle/oradata/orcl/franck_undo.dbf' size 10M;

create user franck identified by franck;
grant connect to franck;
GRANT CREATE SESSION TO "FRANCK" ;
alter user franck default tablespace franck_ts temporary tablespace franck_tmp;

select * from database_properties;

alter database set time_zone = '';
ALTER DATABASE SET TIME_ZONE = 'Pacific/Noumea';

select * from dba_tab_columns where data_type like '%LOCAL%';

alter system set recyclebin=OFF scope=spfile;
select * from recyclebin;
select SYSTIMESTAMP from dual;
grant dba to franck;
select col1, rowid , 
DBMS_ROWID.ROWID_RELATIVE_FNO(rowid) 
from t1;
    
select * from v$datafile where name like '%franck%';

select * from dba_tables where table_name = 'T1';

select * from dba_objects;

select * from dba_sequences;
--20190911
select * from dba_sequences
where sequence_owner='FRANCK'
;

CREATE OR REPLACE TRIGGER TRG_ANALYSE 
AFTER ANALYZE ON DATABASE 
BEGIN
  insert into T3 values (user, sysdate, 'analyse');
END;
/

select * from t3;

show PARAMETERS count;

select * from dba_indexes
where owner = 'FRANCK'
;

alter index "FRANCK"."FACTURE_PK" rebuild;
alter index "FRANCK"."STOCK_PK" rebuild;
```

```sql
--permanent
--externe
--temporaire
--OIT organistaion des blocks
create table T1 (
col1 number,
col2 varchar2(250),
col3 date);

insert into t1 values (1,'bbb',sysdate);
commit;

select col1, rowid , DBMS_ROWID.ROWID_OBJECT(rowid) from t1;
    


select col1, rowid , 
DBMS_ROWID.ROWID_RELATIVE_FNO(rowid) 
from t1;

desc v1;
--20190911
create sequence seqT1;

select seqT1.current from dual;
select seqT1.nextval from dual;

drop sequence seqT1;
create sequence seqT1 start with 1000;

select seqt1.nextval from dual;

insert into T1 values (seqT1.nextval, 'tt'||to_char(seqT1.nextval), sysdate);

select * from T1;

create or replace procedure proc1 as 
begin
    for i in 1..10 
    loop
        --insert into T1 values (seqT1.nextval,concat('machaine',to_char(seqT1.nextval)), sysdate);
        insert into T1 (col2, col3) values (concat('machaine',to_char(seqT1.nextval)), sysdate);
    end loop;
end;
/ 

-- pour utiliser une procédure
exec proc1 ;

select count(1) from t1;

create or replace function func1 return date as
    maxdate franck.t1.col3%type;
begin
    select max(col3) into maxdate from franck.T1;
    return (maxdate) ;
end;
/
-- pour utiliser une fonction
select func1 from dual;

create table T2 (col1 varchar2(20), col2 date,col3 number);

create or replace trigger T1_T2 
after delete on T1
for each row
begin
    insert into T2 values (user, sysdate, :old.col1);
end;
/

insert into T1 values (seqT1.nextval,concat('machaine',to_char(seqT1.nextval)), sysdate); 
select * from T1;
select * from t2;

delete from T1 where col1 in (1,1001,1002);

insert into T1 (col2, col3) values (concat('machaine',to_char(seqT1.nextval)), sysdate);

CREATE PUBLIC DATABASE LINK LINK_ALLAN 
CONNECT TO allan IDENTIFIED BY allan 
USING 'ORCL_ALAN';

select 'ALLAN', count(*) from ALLAN.T1@LINK_ALLAN
union
select 'FRANCK', count(*) from T1;

create public synonym SYNALLAN for ALLAN.T1@LINK_ALLAN;
drop synonym "PUBLIC"."SYNALLAN3";
select * from SYS.dba_synonyms
where synonym_name like '%SYN%';

select count(*) from SYNALLAN;

create table facture (
id number,
quantite number,
idarticle number,
prix number(6,2));

create table stock (idarticle number,
quantite number,
prix number(6,2));

insert into facture values (seqt1.nextval, 10, 1 , 10);
insert into facture values (seqt1.nextval, 40, 1 , 10);
select * from stock;

analyze TABLE stock compute statistics;

create or replace directory DIRFRANCK as '/home/oracle/bkp';


create or replace procedure proc_populate(nblig number) as 
begin
    declare
        n_commit number :=0 ;
    begin
        for i in 1..nblig 
        loop
            insert into stock values (seqt1.nextval, round(dbms_random.value(1,10000000)) , round(dbms_random.value(1,1000000)));
            n_commit:=n_commit+1;
            if n_commit >= 10000 then
                commit;
                n_commit := 0;
            end if;
        end loop;
        commit;
    end;
end;
/

select count(*) from stock;

exec proc_populate(5000000);

CREATE INDEX STOCK_INDEX ON STOCK (QUANTITE);
DROP INDEX STOCK_INDEX;

analyze TABLE stock compute statistics;

select *
from stock
where to_char(quantite) = '2000';


```

## 20190911

OLTP
OLAP

## 20190912

fichier d'adminmatin

```bash
#!/bin/bash
ORACLE_UNQNAME=orcl
ORACLE_SID=orcl
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1

cat $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/alert_orcl.log |grep 'ERROR\|ORA-' > /home/oracle/$(date +%Y%m%d%H%M%S)-admmatin.log

sqlplus /nolog <<EOF
connect / as sysdba
set linesize 200
spool /home/oracle/invalid_object_list.lis
ttitle 'Liste de objets invalides'
col owner format A10
col object_name format A20
col objet_type format A10
select owner,object_name,object_type from dba_objects where status='INVALID';
spool off
EOF
```

### Install oracle 12c

desinstall oracle
cd /u01/app/oracle/
rm -rf admin cfgtoollogs checkpoints diag flash_recovery_area oradata oradiag_oracle
rm -rf oraInventory/
cd /etc
rm oraInst.loc oratab
cd /usr/local/bin
rm -rf coraenv dbhome oraenv

```sql
-- ora12c
create user franck IDENTIFIED by franck;

grant dba to franck;

select * from dba_users
where username like 'FRANCK%';

alter DATABASE backup controlfile to trace;


archive log list;

show PARAMETERS reco;
alter system set db_recovery_file_dest_size=20G scope=both;

show parameter max_string_size;

startup mount
alter database archivelog;
archive log list;

select * from v$log;
alter system SWITCH logfile;
select * from v$log;

--connected to target database: ORA12C (DBID=396582979)
--
RMAN> show all;

using target database control file instead of recovery catalog
RMAN configuration parameters for database with db_unique_name ORA12C are:
CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
CONFIGURE BACKUP OPTIMIZATION OFF; # default
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
CONFIGURE CONTROLFILE AUTOBACKUP ON; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE MAXSETSIZE TO UNLIMITED; # default
CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/12.0.1/dbhome_1/dbs/snapcf_ora12c.f'; # default

CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 2 TIMES TO DISC;
CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY BACKED UP 1 TIMES TO DISK;

backup database;
backup archivelog all;
backup database plus archivelog;


-- check du matin
rman
list backup;
sequentialité des arc
taille des logs


rman target sys/oracle < /home/oracle/rman.txt

```

## 20190913

vim /home/oracle/expdb.param

```bash
DIRECTORY=DIRFRANCK
DUMPFILE=expfull.dmp
LOGFILE=expdp.log
FULL=Y

--autre version
DIRECTORY=DIRFRANCK
DUMPFILE=expfull.dmp
LOGFILE=expdp.log
SCHEMAS=FRANCK
REUSE_DUMPFILES=YES
```

```bash
expdp franck/franck parfile=/home/oracle/expdb.param
```

```bash
#!/bin/bash
export ORACLE_UNQNAM=ora12c
export ORACLE_SID=ora12c
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.0.1/dbhome_1
PATH=/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin:/u01/app/oracle/product/12.0.1/dbhome_1/bin

date_jour=`date +%Y%m%d%H%M%S`
echo "DEBUT EXPDB" > "/home/oracle/$date_jour-my_expdp.log"
echo "================================================================" >> "/home/oracle/$date_jour-admmatin.log"

expdp franck/franck parfile=/home/oracle/expdp.param

echo "FIN EXPDB" >> "/home/oracle/$date_jour-my_expdp.log"
echo "================================================================" >> "/home/oracle/$date_jour-admmatin.log"
```

vim impdp.param

```bash
DIRECTORY=DIRFRANCK
DUMPFILE=expfull.dmp
LOGFILE=impdpmetier.log
TABLES=T1
```

impdp franck/franck parfile=/home/oracle/impdpmetier.param

transportable_tablespace
au lieu de faire
arret production
expdp full serveur A
impdp ful serveur B
reprise production

on va faire
arret production
expdp metadonné serveur A
base arreter cp de tous les dbff
deplace les sur serveur B
impdb metadone serveur B
startup serveur B

FlashBACk
flachback scn ou flashback_time (avant l'heure de la sauvegarde expdp)

PARALLEL= integer

REMAP_SCHEMA=FRANCK:FRANCK2 permettre à impdp de restature un bojet apartenet à P1 et P2
REMAP_TABLE=T1:T2  permettre à impdp de restature un objet apartenant à P1 et P2

==== crash
Analyse: alerte_sid.log
fichier dbf
fichier de log
fichier ctl
fichier spfile
fichier des mots de passe
base arrêteé
données corrompues

1) fichier df
sql>shutdown immediate
sql>shutdown abort
sql>shartup nomount
sql>shutdown immediate
sql>shartup mount

rman>restore database;
ou
rman>restore tbs users;
ou
rman>restore datafile 7;

rman>recover database;
sql> alter database open;

PITR: repere temps / SCN / restore point
Point de controle:
11:28=count(*) 5
11:29=count(*) 7
12:54=count(*) 11

le metier appelle demande resto à 11:28
sql>shutdown immediate
! rm users01.dbf
sql>startup mount

rman>run
{
set until time "to_date('13/09/19 11:29:13','DD/MM/YY HH24:MI:SS')";
restore database;
recover database;
}

sql> alter database open resetlogs;

rman> backup database plus archivelog;

test final le résultat est count(*) 7

TP5: restaurer sur un autre disque
rman>run
{
set newname for datafile '/u01/app/oracle/oradata/ora12c/users01.dbf' to '/u01/app/oracle/oradatabis/ora12c/users01.dbf';
restore database;
switch datafile all;
recover database;
}
sql> alter database open;

comment restaure pfile
sql> startup nomount
rman>restore spfile from autobackup;

comment restaure fichier pwd
recrer le fichier

comment restaure fichier de log

TP6 le metier demande une restaauration avant la création dela facture

flashback

1) flashback table to before drop \
metier (connect franck/franck) \
drop table --> oups \
dba \
select * from dba_recyclebin; \
flashback table franck.t1 to before drop; \

2) undo \
le tbs undo conserve pendant 900 secondes les transactions de chaque utilisateurs \
select systimestamp from dual; \
insert into franck.T1 values (12345, test flash', sysdate); \
select systimestamp from dual; \

3) FDA (Flashback data archive)

4) restauration de la base dans le délai de rétention déclaré \
pre requis: base possede les propriete flasback database \
sql>alter system set db_flashback_retention_target=3600 scope=spfile; \
sql>shutdown immediate \
sql>startup mount \
sql>alter database flashback on; \
sql>alter database open; \
create restore point avantinter; \
sql>shutdown immediate \
startup mount \

```bash
select * from dba_objects
where object_name like 'SYS_AUT%';

select * from dba_jobs;

select * from DBA_SCHEDULER_WINDOWS;

create or replace directory DIRFRANCK as '/home/oracle/bkp';

select * from franck.t1;

select name, space_limit/(1024*1024) "tot", round(space_used/(1024*1024)) "used", round(space_reclaimable/(1024*1024)"rec", number_of_files files from v$recovery_file_dest;
select * from v$recovery_file_dest;

select SYSTIMESTAMP from dual;

select * from dba_recyclebin;
flashback table franck.t1 to before drop;

show parameter retention;

select systimestamp from dual;
insert into franck.T1 values (12345, 'test flash', sysdate);
commit;
select systimestamp from dual;
delete franck.t1 where col1=12345;
commit;
select systimestamp from dual;

SELECT versions_startscn,versions_endscn, versions_operation,col1 
FROM   franck.T1
VERSIONS BETWEEN TIMESTAMP TO_TIMESTAMP('2019-09-13 15:20:08', 'YYYY-MM-DD HH24:MI:SS')
 AND TO_TIMESTAMP('2019-09-13 15:29:00', 'YYYY-MM-DD HH24:MI:SS') 
where col1=12345;


select * from database_properties
;
select * from v$database;
```

## 20190916

```sql
select * from v$recovery_file_dest;

select * from dba_scheduler_job_log
where status='FAILED';
select * from dba_SCHEDULER_JOB_RUN_DETAILS;
/*
6960 16/09/19 00:00:26,542151000 +11:00 SYS ORA$AT_OS_OPT_SY_575  ORA$AT_JCNRM_OS RUN FAILED        
6984 16/09/19 00:10:29,655930000 +11:00 SYS ORA$AT_OS_OPT_SY_577  ORA$AT_JCNRM_OS RUN FAILED        
7008 16/09/19 00:20:29,609957000 +11:00 SYS ORA$AT_OS_OPT_SY_579  ORA$AT_JCNRM_OS RUN FAILED        
7038 16/09/19 00:30:31,033074000 +11:00 SYS ORA$AT_OS_OPT_SY_581  ORA$AT_JCNRM_OS RUN FAILED        
7062 16/09/19 00:40:35,652059000 +11:00 SYS ORA$AT_OS_OPT_SY_583  ORA$AT_JCNRM_OS RUN FAILED        
7086 16/09/19 00:50:33,906399000 +11:00 SYS ORA$AT_OS_OPT_SY_585  ORA$AT_JCNRM_OS RUN FAILED        
7110 16/09/19 01:00:36,455188000 +11:00 SYS ORA$AT_OS_OPT_SY_587  ORA$AT_JCNRM_OS RUN FAILED        
7138 16/09/19 01:10:38,384502000 +11:00 SYS ORA$AT_OS_OPT_SY_589  ORA$AT_JCNRM_OS RUN FAILED        
7162 16/09/19 01:20:39,076684000 +11:00 SYS ORA$AT_OS_OPT_SY_591  ORA$AT_JCNRM_OS RUN FAILED        
7198 16/09/19 01:30:40,213375000 +11:00 SYS ORA$AT_OS_OPT_SY_593  ORA$AT_JCNRM_OS RUN FAILED        
7222 16/09/19 01:40:41,536016000 +11:00 SYS ORA$AT_OS_OPT_SY_595  ORA$AT_JCNRM_OS RUN FAILED        
*/

exec dbms_stats.gather_database_stats();

create pfile='/home/oracle/pfile20190916.ora' from spfile;

alter DATABASE backup controlfile to trace;
--version A: desactiver le lancement
begin
dbms_auto_task_admin.disable(
client_name=>'auto optimizer stats collection',
operation=>NULL,
window_name=>NULL);
end;
/

show parameter tunin;
show parameter pack; --control_management_pack_access string DIAGNOSTIC+TUNING --- sous licence


create FLASHBACK ARCHIVE DEFAULT fda_1year TABLESPACE TS_FBDA QUOTA 10G RETENTION 1 YEAR;

grant FLASHBACK ARCHIVE on fda_1year to franck;

select * from dba_flashback_archive;
select * from dba_flashback_archive_ts;
select * from dba_flashback_archive_tables;

select  idarticle, 
        versions_startscn, 
        versions_endscn,
        versions_operation
from franck.test_fda
versions between scn minvalue and maxvalue
order by versions_startscn;


select * from dba_extents
where owner = 'FRANCK'
and segment_name = 'TEST_FDA';

create restore point avant_delete;

select * from v$restore_point;

--pour le supprimer
drop restore point avant_delete;


-----
sql> shutdown immediate;
sql> startup mount;
rman> restaure database;
rman> recover database;
sql> alter database open;

select sql_fulltext ,command_type,fetches,parsing_schema_name ,parsing_user_id    from sys.v_$sqlarea;


select * from dba_jobs;
select * from dba_jobs_running;

select owner, job_name, run_count, last_start_date, next_run_date from dba_scheduler_jobs
where owner = 'FRANCK';

select systimestamp from dual;


BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"FRANCK"."JOBTESTFDA"',
            job_type => 'STORED_PROCEDURE',
            job_action => 'FRANCK.PROC_POPULATE',
            number_of_arguments => 1,
            start_date => NULL,
            repeat_interval => 'FREQ=DAILY',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => '');

    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE( 
             job_name => '"FRANCK"."JOBTESTFDA"', 
             argument_position => 1, 
             argument_value => '100000');
         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"FRANCK"."JOBTESTFDA"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"FRANCK"."JOBTESTFDA"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"FRANCK"."JOBTESTFDA"');
END;

```

--franck

```sql
create tablespace ts_FBDA datafile '/u01/app/oracle/oradata/ora12c/fda_01.dbf' size 1M autoextend on next 1M;

--as sysdba
create FLASHBACK ARCHIVE DEFAULT fda_1year TABLESPACE TS_FBDA QUOTA 10G RETENTION 1 YEAR;

create table test_fda (idarticle number,
quantite number,
prix number)
FLASHBACK ARCHIVE;

create sequence seqT1;
create or replace procedure proc_populate(nblig number) as 
begin
    declare
        n_commit number :=0 ;
    begin
        for i in 1..nblig 
        loop
            insert into test_fda values (seqt1.nextval, round(dbms_random.value(1,10000000)) , round(dbms_random.value(1,1000000)));
            n_commit:=n_commit+1;
            if n_commit >= 10000 then
                commit;
                n_commit := 0;
            end if;
        end loop;
        commit;
    end;
end;
/

exec proc_populate(100000);

select  idarticle, 
        versions_startscn, 
        versions_endscn,
        versions_operation
from franck.test_fda
versions between scn minvalue and maxvalue
order by versions_startscn;

delete from test_fda where idarticle = 1;
commit;

select  *
from franck.test_fda 
as of SCN 2142695;

insert into test_fda values (1,1155933,90540);
commit;

select  idarticle, 
        versions_startscn, 
        versions_endscn,
        versions_operation
from franck.test_fda
versions between scn minvalue and maxvalue
where idarticle=1
order by versions_startscn;

SELECT versions_startscn,versions_endscn, versions_operation,col1 
FROM   franck.T1
versions between scn minvalue and maxvalue  
;

---franck
BEGIN
    DBMS_SCHEDULER.DROP_JOB (
            job_name => '"FRANCK"."JOBFRANCK"');
END;
/

BEGIN
dbms_credential.create_credential(
credential_name=>'franckcred',
username=>'oracle',
password=>'oracle');
END;
/
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"FRANCK"."JOBFRANCK"',
            job_type => 'EXECUTABLE',
            job_action => '/home/oracle/testjob.sh',
            auto_drop =>false,
            enabled => FALSE
            credential_name=>'franckcred');
END;
/

exec DBMS_SCHEDULER.enable(name=>'JOBFRANCK');
exec DBMS_SCHEDULER.RUN_JOB(job_name => 'JOBFRANCK');

BEGIN
    DBMS_SCHEDULER.set_attribute( name => '"FRANCK"."JOBFRANCK"', attribute => 'repeat_interval', value => 'FREQ=HOURLY');
        DBMS_SCHEDULER.set_attribute( name => '"FRANCK"."JOBFRANCK"', attribute => 'start_date', value => TO_TIMESTAMP_TZ('2019-09-16 13:52:00.000000000 PACIFIC/GUADALCANAL','YYYY-MM-DD HH24:MI:SS.FF TZR'));
        DBMS_SCHEDULER.set_attribute( name => '"FRANCK"."JOBFRANCK"', attribute => 'end_date', value => TO_TIMESTAMP_TZ('2019-09-16 15:52:00.000000000 PACIFIC/GUADALCANAL','YYYY-MM-DD HH24:MI:SS.FF TZR'));

END; 
/

create table franck.t3ext (col1 varchar2(50), col2 number) organization external
(
type oracle_loader
default directory DIRFRANCK
access parameters (
records delimited by newline
fields terminated by ','
)
location ('donneeExt.txt')
)
reject limit unlimited;

select * from t3ext;



```

le sequenceur/scheduler ?

sql loader
controlfile: loader.ctl
