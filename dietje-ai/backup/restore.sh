#createuser di00
#createdb di00 -O di00
pg_restore -U di00  di00 di00-dump.sql

