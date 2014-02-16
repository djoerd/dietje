-- courses
insert into course (cid, name) values ('assign-di', 'Data and Information Assignments');
insert into course (cid, name) values ('utwente-di', 'Data and Information Project');
insert into course (cid, name) values ('utwente-ds', 'Data Science');
insert into course (cid, name) values ('utwente-ir', 'Information Retrieval');
insert into course (cid, name) values ('utwente-mdb', 'Managing Big Data');
-- students
insert into student (sid, studentNr, realname) values ('djoerd', 'm76426485', 'Djoerd Hiemstra');
insert into student (sid, studentNr, realname) values ('lferreirapires', 'm72983120', 'Luis Ferreira Pires');
insert into student (sid, studentNr) values ('dutchprostudent22', 's01231485');
insert into student (sid, studentNr, realname) values ('group01', 'group01', 'Klaas, Maurice, Djoerd, Luis');
-- assignments
insert into assignment (aid, cid, title, description) values ('assign01', 'assign-di', 'Assignment 1', 'Introduction to git and sql');
insert into assignment (aid, cid, title, description) values ('assign02', 'assign-di', 'Assignment 2', 'Git branching and maven');
insert into assignment (aid, cid, title, description) values ('assign03', 'assign-di', 'Assignment 3', 'Functional dependencies and normal forms');
insert into assignment (aid, cid, title, description) values ('level01', 'utwente-di', 'Achievement 1', 'Use Case Diagram');
-- professor
insert into professor (pid, name) values (1, 'Prof. Dietje');
-- submits
insert into submits (aid, sid, pid, request_date, feedback_date, grade) values ('assign01', 'djoerd', 1, '2014-02-14 20:24:12', '2014-02-14 20:42:53', 8.2);
insert into submits (aid, sid, pid, request_date) values ('assign01', 'lferreirapires', 1, '2014-02-14 20:36:57');
insert into submits (aid, sid, pid, request_date) values ('assign01', 'dutchprostudent22', 1, '2014-02-14 20:41:08');
insert into submits (aid, sid, pid, request_date) values ('assign02', 'lferreirapires', 1, '2014-02-14 20:41:42');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group01', 1, '2014-02-14 20:42:01');



