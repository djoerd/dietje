-- courses
insert into course (cid, name) values ('assign-di', 'Data and Information Assignments');
insert into course (cid, name) values ('utwente-di', 'Data and Information Project');
insert into course (cid, name) values ('utwente-ds', 'Data Science');
insert into course (cid, name) values ('utwente-ir', 'Information Retrieval');
insert into course (cid, name) values ('utwente-mdb', 'Managing Big Data');
-- students
insert into student (sid, studentNr, realname, email) values ('djoerd', 'm76426485', 'Djoerd Hiemstra', 'hiemstra@cs.utwente.nl');
insert into student (sid, studentNr, realname, email) values ('lferreirapires', 'm72983120', 'Luis Ferreira Pires', 'pires@cs.utwente.nl');
insert into student (sid, studentNr) values ('dutchprostudent2', 's01231485');
insert into student (sid, studentNr, realname) values ('group00', 'group00', 'Klaas, Maurice, Djoerd, Luis');
insert into student (sid, studentNr) values ('group01', 'group01');
insert into student (sid, studentNr) values ('group02', 'group02');
insert into student (sid, studentNr) values ('group03', 'group03');
insert into student (sid, studentNr) values ('group04', 'group04');
insert into student (sid, studentNr) values ('group05', 'group05');
insert into student (sid, studentNr) values ('group06', 'group06');
insert into student (sid, studentNr) values ('group07', 'group07');
insert into student (sid, studentNr) values ('group08', 'group08');
insert into student (sid, studentNr) values ('group09', 'group09');
insert into student (sid, studentNr) values ('group10', 'group10');
-- assignments
insert into assignment (aid, cid, title, description) values ('assign01', 'assign-di', 'Assignment 1', 'Introduction to git and sql');
insert into assignment (aid, cid, title, description) values ('assign02', 'assign-di', 'Assignment 2', 'Git branching and maven');
insert into assignment (aid, cid, title, description) values ('assign03', 'assign-di', 'Assignment 3', 'Functional dependencies and normal forms');
insert into assignment (aid, cid, title, description) values ('level01', 'utwente-di', 'Task 1', 'Git and git branching');
insert into assignment (aid, cid, title, description) values ('level02', 'utwente-di', 'Task 2', 'Trello');
insert into assignment (aid, cid, title, description) values ('level03', 'utwente-di', 'Task 3', 'Scrum standup meetings');
insert into assignment (aid, cid, title, description) values ('level04', 'utwente-di', 'Task 4', 'Use Case diagram');
insert into assignment (aid, cid, title, description) values ('level05', 'utwente-di', 'Task 5', 'Class diagram');
insert into assignment (aid, cid, title, description) values ('level06', 'utwente-di', 'Task 6', 'SQL database design');
insert into assignment (aid, cid, title, description) values ('level07', 'utwente-di', 'Task 7', 'Maven and Java WAR');
insert into assignment (aid, cid, title, description) values ('level08', 'utwente-di', 'Task 8', 'Unit tests');
insert into assignment (aid, cid, title, description) values ('level09', 'utwente-di', 'Task 9', 'Test-driven development');
insert into assignment (aid, cid, title, description) values ('level10', 'utwente-di', 'Task 10', 'JSP and Servlets');
insert into assignment (aid, cid, title, description) values ('level11', 'utwente-di', 'Task 11', 'RESTful web services');
insert into assignment (aid, cid, title, description) values ('level12', 'utwente-di', 'Task 12', 'JDBC or O/R mapping');
insert into assignment (aid, cid, title, description) values ('level13', 'utwente-di', 'Task 13', 'HTML, CSS and Javascript');
insert into assignment (aid, cid, title, description) values ('level14', 'utwente-di', 'Task 14', 'Login facilities');
insert into assignment (aid, cid, title, description) values ('level15', 'utwente-di', 'Task 15', 'Review meetings');
insert into assignment (aid, cid, title, description) values ('level16', 'utwente-di', 'Task 16', 'Evaluation and planning');
insert into assignment (aid, cid, title, description) values ('level17', 'utwente-di', 'Task 17', 'Team work');
insert into assignment (aid, cid, title, description) values ('level18', 'utwente-di', 'Task 18', 'Tomcat deployment');
insert into assignment (aid, cid, title, description) values ('level19', 'utwente-di', 'Task 19', 'Ethical guidelines');
insert into assignment (aid, cid, title, description) values ('level20', 'utwente-di', 'Task 20', 'Security analysis');
insert into assignment (aid, cid, title, description) values ('level21', 'utwente-di', 'Task 21', 'Database transactions');
-- professor
insert into professor (pid, name) values ('dietje', 'Prof. Dietje');
-- submits
insert into submits (aid, sid, pid, request_date, feedback_date, grade, feedback) values ('assign01', 'djoerd', 'dietje', '2014-02-14 20:24:12', '2014-02-14 20:42:53', 8.2, 'Prof. Dietje says: Welcome djoerd.
I will grade your results for assign01
1.1 ok
1.2 ok');
insert into submits (aid, sid, pid, request_date) values ('assign01', 'lferreirapires', 'dietje', '2014-02-14 20:36:57');
insert into submits (aid, sid, pid, request_date) values ('assign01', 'dutchprostudent2', 'dietje', '2014-02-14 20:41:08');
insert into submits (aid, sid, pid, request_date) values ('assign02', 'lferreirapires', 'dietje', '2014-02-14 20:41:42');
insert into submits (aid, sid, pid, request_date, feedback_date, grade) values ('level01', 'group00', 'dietje', '2014-02-14 20:42:01', '2014-02-14 20:42:01', 7.6);
insert into submits (aid, sid, pid, request_date, feedback_date, grade) values ('level02', 'group00', 'dietje', '2014-02-14 20:43:01', '2014-02-14 20:43:02', 8.3);
insert into submits (aid, sid, pid, request_date) values ('level01', 'group01', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group02', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group03', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group04', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group05', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group06', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group07', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group08', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group09', 'dietje', '2014-02-14 20:42:01');
insert into submits (aid, sid, pid, request_date) values ('level01', 'group10', 'dietje', '2014-02-14 20:42:01');



