create table course (
  cid varchar(16) not null, 
  name varchar(255),
  constraint pk_cid primary key(cid) 
);
create table assignment (
  aid varchar(16) not null,
  cid varchar(16),
  title varchar(32) not null,
  description varchar(255),
  constraint pk_aid primary key(aid),
  constraint fk_cid foreign key(cid) references course(cid)
);
create table student (
  sid varchar(16) not null, 
  studentNr varchar(16) not null, 
  realname varchar(32), 
  constraint pk_sid primary key(sid),
  unique(studentNr)
);
create table professor (
  pid varchar(16) not null,
  name varchar(32),
  constraint pk_pid primary key(pid)
);
create table submits (
  aid varchar(16),
  sid varchar(16),
  pid varchar(16),
  request_date date,
  feedback_date date,
  grade float,
  attempts int,
  constraint pk_asid primary key(aid, sid),
  foreign key (aid) references assignment(aid),
  foreign key (sid) references student(sid),
  foreign key (pid) references professor(pid)
);
