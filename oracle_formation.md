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
