create table docent (docent_id int, naam varchar);
create table thema(thema_id int, docent_id int, naam varchar);
insert into docent (docent_id, naam) values (1, 'Luis');
insert into docent (docent_id, naam) values (2, 'Dr. Luis');
insert into docent (docent_id, naam) values (3, 'Luis Ferreira Pires');
insert into docent (docent_id, naam) values (4, 'Dr. Luis Ferreira Pires');
insert into thema (thema_id, docent_id, naam) values (1, 11, 'sql');
insert into thema (thema_id, docent_id, naam) values (2, 11, 'git');
insert into thema (thema_id, docent_id, naam) values (3, 12, 'uml');
insert into thema (thema_id, docent_id, naam) values (4, 13, 'jsp');
insert into thema (thema_id, docent_id, naam) values (5, 13, 'rest');
insert into thema (thema_id, docent_id, naam) values (6, 14, 'xml');


