
/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Demonstrates how to add or remove SQL Server roles 
                 (e.g., granting sysadmin)
   ================================================================= */



-- Giving sysadmin permission for the login becuase ony sysadim can only create or delet database so -- for hmail we need to give so that it can create database and all the table

ALTER SERVER ROLE sysadmin ADD MEMBER hmailuser;



---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- To confirm the change, run:


SELECT sp.name, sr.name AS RoleName
FROM sys.server_role_members srm
JOIN sys.server_principals sp ON srm.member_principal_id = sp.principal_id
JOIN sys.server_principals sr ON srm.role_principal_id = sr.principal_id
WHERE sp.name = 'hmailuser';


--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- To remove the sysadim

		/* To remove sysadmin permissions from a SQL Server login, 
		execute the following command in SQL Server Management Studio (SSMS) while logged in as an admin (for safety, not with the same user you’re modifying):
		*/

ALTER SERVER ROLE sysadmin DROP MEMBER hmailuser;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--	Question - why can i just change the role to db_owner then deleting/drop ?

					/*	here’s the key difference and why you can’t just “change” from sysadmin to db_owner directly:

						sysadmin is a server-level role; it controls permissions across the entire SQL Server instance (can manage all databases, settings, logins, etc.).

						db_owner is a database-level role; it grants full control within only one specific database.

						Because they work at different scopes (server-level vs. database-level), there’s no single command to “convert” one into the other. Instead, you remove sysadmin access at the server level, then explicitly add db_owner at the database level.*/


--	Example Workflow

--	1]	Grant sysadmin to allow setup:


ALTER SERVER ROLE sysadmin ADD MEMBER hmailuser;

--After hMailServer finishes setup, lower privileges:

-----------------------------------------------------

-- 2]Remove sysadmin:

ALTER SERVER ROLE sysadmin DROP MEMBER hmailuser;

--Then assign db_owner at the database level:
-----------------------------------------------------

USE EmailAnalyticsDB; -- name i will in hmail to create new database 

ALTER ROLE db_owner ADD MEMBER hmailuser;

--That way, hmailuser can still fully control only its database but will no longer have access to other databases or server-wide settings.



/*In short:
You cannot “replace” sysadmin with db_owner — you remove sysadmin (server-level) and then grant db_owner (database-level) permissions afterward.​*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
