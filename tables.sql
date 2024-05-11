/* drop tables in case exist already */

set echo on
set verify on

drop table vacc_record cascade constraints purge; 
drop table valid_for cascade constraints purge; 
drop table vaccinations cascade constraints purge;
drop table patient cascade constraints purge;
drop table visits cascade constraints purge;
drop table doctor cascade constraints purge;

/* create the base tables */

create table patient (
pid char(6) constraint pkp primary key,
pname char(20),
address varchar2(100),
dobirth date,
date_reg date);

create table doctor (
did char(1) constraint pkd primary key,
dname char(20),
date_start date);

create table valid_for (
vaccinated char(20) constraint pkvf primary key,
lasting_years number); 

create table visits (
pid char(6),
did char(1),
vdate date,
constraint pkvis primary key (pid,vdate),
foreign key(pid) REFERENCES patient(pid),
foreign key(did) REFERENCES doctor(did)
);

create table vaccinations (
pid char(6),
vdate date,
action number,
vaccinated char(20),
constraint pkvac primary key (pid,vdate,action),
constraint ukvac UNIQUE (pid,vdate,vaccinated),
foreign key(pid,vdate) REFERENCES visits(pid,vdate),
foreign key(pid) REFERENCES patient(pid),
foreign key(vaccinated) REFERENCES valid_for(vaccinated)
);

commit;

/* end of script */

