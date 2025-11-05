



-- To view logins at the server level:


SELECT name, type_desc, default_database_name FROM sys.server_principals WHERE type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN');


--To view users within a specific database:

SELECT name, type_desc, authentication_type_desc FROM sys.database_principals WHERE name NOT IN ('sys', 'INFORMATION_SCHEMA');



--These queries will help you identify all logins and users in your SQL Server environment.



-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- The Two Levels in SQL 

/*

In SQL Server, the security model works on two levels: logins and users.

1] At the "Server level" - a login is the entity that allows a person or application to connect to the SQL Server instance. It acts as an authentication mechanism. You can think of a login as gaining entry to the building (the SQL Server). Logins are stored in the master database and can be SQL logins (username/password) or Windows logins (Windows domain accounts).​

2] At the "Database level" -  a user is created inside each database and is associated (mapped) to a login. The database user controls what the login can do within that specific database, granting authorization such as permissions to read or modify data. One login can be mapped to users across multiple databases, but each user is specific to one database only. This is like having a keycard that opens certain rooms inside the building based on assigned permissions.​

In short:

Login = authentication at server level (can you connect?).

User = authorization at database level (what can you do inside the database?).

This two-level system separates access to the server from access to individual databases.

*/

-------------------------------------------------------------------------------------------------------------------------------------------------------------