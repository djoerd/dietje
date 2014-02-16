-- courses
insert into course (cid, name) values ('assign-di', 'Data and Information Assignments');
insert into course (cid, name) values ('utwente-di', 'Data and Information Project');
insert into course (cid, name) values ('utwente-ds', 'Data Science');
insert into course (cid, name) values ('utwente-ir', 'Information Retrieval');
insert into course (cid, name) values ('utwente-mdb', 'Managing Big Data');
-- students
insert into student (sid, github_id, realname) values ('m76426485', 'djoerd', 'Djoerd Hiemtra');
insert into student (sid, github_id, realname) values ('m72983120', 'lferreirapires', 'Luis Ferreira Pires');
insert into student (sid, github_id) values ('s01231485', 'dutchprostudent22');
insert into student (sid, github_id, realname) values ('group01', 'group01', 'Klaas, Maurice, Djoerd, Luis');
-- assignments
insert into assignment (aid, cid, title, description) values ('assign01', 'assign-di', 'Assignment 1', 'Introduction to git and sql');
insert into assignment (aid, cid, title, description) values ('assign02', 'assign-di', 'Assignment 2', 'Git branching and maven');
insert into assignment (aid, cid, title, description) values ('assign03', 'assign-di', 'Assignment 3', 'Functional dependencies and normal forms');
insert into assignment (aid, cid, title, description) values ('level01', 'utwente-di', 'Achievement 1', 'Use Case Diagram');
-- professor
insert into professor (pid, name) values (1, 'Prof. Dietje');
-- submits
insert into submits (aid, sid, pid, request_date) values ('assign01', 'm76426485', 1, '2014-02-14 20:24:12');
insert into submits (aid, sid, pid, request_date) values ('assign01', 'm72983120', 1, '2014-02-14 20:36:57');
insert into submits (aid, sid, pid, request_date) values ('assign01', 's01231485', 1, '2014-02-14 20:41:08');
insert into submits (aid, sid, pid, request_date) values ('assign02', 'm72983120', 1, '2014-02-14 20:41:42');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group01', 1, '2014-02-14 20:42:01');



