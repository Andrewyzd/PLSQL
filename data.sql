/* patients see doctors at visits where they  receive vaccinations valid for a particular time */
insert into patient values('1','Fred','Newcastle','14-mar-1976','29-sep-2006');
insert into patient values('2','Mary','Heaton','28-oct-1989','06-aug-1996');
insert into patient values('3','Susan','Tynemouth','07-feb-1935','01-jan-1975');
insert into patient values('4','Bill','Gosforth','03-jan-1987','18-jul-1993');
insert into patient values('5','Joan','Gateshead','30-may-1922','14-jun-1991');

insert into doctor values ('1','Peter Roberts','25-apr-1997');
insert into doctor values ('2','Brenda Townsend','06-sep-2000');

insert into visits values('1','1','04-dec-2010');
insert into visits values('2','2','07-mar-2011');
insert into visits values('2','2','03-mar-2011');
insert into visits values('2','2','27-jul-2009');
insert into visits values('2','2','16-dec-2009');
insert into visits values('4','1','22-jul-2009');
insert into visits values('4','1','26-jun-2008');
insert into visits values('4','2','31-jan-2011');
insert into visits values('3','2','09-jul-2009');
insert into visits values('3','1','28-jan-2011');
insert into visits values('5','2','17-mar-2011');

insert into valid_for values('smallpox',10);
insert into valid_for values('typhoid',3);
insert into valid_for values('cholera',0.5);
insert into valid_for values('polio',10);
insert into valid_for values('tetanus',7);
insert into valid_for values('hepatitis',0.5);

insert into vaccinations values('1','04-dec-2010',1,'smallpox');
insert into vaccinations values('1','04-dec-2010',2,'typhoid');
insert into vaccinations values('2','07-mar-2011',1,'typhoid');
insert into vaccinations values('2','07-mar-2011',2,'cholera');
insert into vaccinations values('2','07-mar-2011',3,'polio');
insert into vaccinations values('2','03-mar-2011',1,'typhoid');
insert into vaccinations values('2','27-jul-2009',1,'typhoid');
insert into vaccinations values('2','27-jul-2009',2,'tetanus');
insert into vaccinations values('2','16-dec-2009',1,'typhoid');
insert into vaccinations values('2','16-dec-2009',2,'hepatitis');
insert into vaccinations values('4','22-jul-2009',1,'typhoid');
insert into vaccinations values('4','22-jul-2009',2,'cholera');
insert into vaccinations values('4','26-jun-2008',1,'tetanus');
insert into vaccinations values('4','31-jan-2011',1,'typhoid');
insert into vaccinations values('3','09-jul-2009',1,'typhoid');
insert into vaccinations values('3','09-jul-2009',2,'hepatitis');

commit;

/* end of script */
