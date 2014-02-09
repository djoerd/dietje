create database dietje;
use dietje;
create user dietje;
grant usage on *.* to dietje@localhost identified by 'changethis';
grant all privileges on dietje.* to dietje@localhost;
