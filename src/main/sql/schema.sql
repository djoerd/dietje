create table course (
  cid varchar(16) not null, 
  name varchar, 
  primary key(cid)
);
create table assignment (
  aid varchar(16) not null,
  cid varchar(16),
  title varchar,
  description varchar,
  primary key(aid),
  foreign key(cid) references course(cid)
);
create table student (
  sid varchar(16) not null, 
  github_id varchar, 
  realname varchar, 
  unique(github_id), 
  primary key(sid) 
);
create table professor (
  pid varchar(16) not null,
  name varchar,
  primary key(pid)
);
create table submits (
  aid varchar(16),
  sid varchar(16),
  pid varchar(16),
  request_date date,
  feedback_date date,
  grade float,
  attempts int,
  primary key(aid, sid),
  foreign key (aid) references course(aid),
  foreign key (sid) references student(sid),
  foreign key (pid) references professor(pid)
);
