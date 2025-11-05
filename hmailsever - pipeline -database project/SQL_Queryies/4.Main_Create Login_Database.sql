

/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Creates SQL login, password, and database for hMailServer, 
                 then assigns db_owner permissions
   ================================================================= */


USE master;

/*

explain .. why master ,,... we can create a seperate database?


[[🧩 First, understand the hierarchy in SQL Server

SQL Server has two levels of security:

Level			Object		Purpose
Server-level	Login		Allows connecting to the SQL Server instance
Database-level	User		Allows access to a specific database

So:

You create a Login → at the server level (inside master).

Then you map that Login to a User → inside a specific database.

------------------------------------------------------------------

🧠 Why “USE master;” comes first ?

master is the system database that holds metadata for the entire SQL Server instance — including Logins and system configurations.

When you write:

						USE master;
						CREATE LOGIN hmailuser WITH PASSWORD = 'StrongPassword123!';


You’re saying:

“Add a new account (hmailuser) who is allowed to connect to this SQL Server instance.”

It’s like creating a door key to the whole building.

--------------------------------------------------------------------------------

🏗️ Then, the second part — connecting that login to your database


After the login exists, you need to allow it inside your specific database — that’s where we use:

						USE EmailAnalyticsDB;
						CREATE USER hmailuser FOR LOGIN hmailuser;
						ALTER ROLE db_owner ADD MEMBER hmailuser;


This means:

“Let that server-level login (hmailuser) access this particular database (EmailAnalyticsDB) and give it full rights (db_owner).”

So:

CREATE LOGIN → server-level

CREATE USER → database-level

ALTER ROLE → gives permissions (here, full control)

--------------------------------------------------------------------

🧱 Can we skip master or create directly inside our database?

No — because you can’t create a login inside a user database.
You can only create users inside a database, but a user must be mapped to a login.

So the proper order is:

Create Login (in master)

Create Database (e.g., EmailAnalyticsDB)

Create User (inside that database, mapped to the login)

-----------------------------------------------------------

🔒 Why not use only Windows Authentication?

You could — but hMailServer and most other services need SQL Authentication (username/password) because they can’t use Windows user tokens.
That’s why we create a separate login with its own password.


*/
LAPTOP-G7658GA9

USE master;
GO
CREATE LOGIN hmailuser WITH PASSWORD = 'StrongPassword123!';
CREATE DATABASE EmailAnalyticsDB;
GO
USE EmailAnalyticsDB;																		
CREATE USER hmailuser FOR LOGIN hmailuser;												-- CREATE USER hmailadim1 FOR LOGIN hmailuser;		&
ALTER ROLE db_owner ADD MEMBER hmailuser;   -- db_owner is inbuilt function				--	ALTER ROLE db_owner ADD MEMBER hmailadim1;     
GO




---------------------------------------------------------------------------------------------------------------------------------






/* Summary

CREATE LOGIN → allows server access.

CREATE USER → allows database access.

ALTER ROLE db_owner ADD MEMBER → gives full rights in that database.

Using a separate database (not master) keeps your project isolated and safe.

*/

------------------------------------------------------------------------------------------------------------

CREATE USER hmailuser FOR LOGIN hmailuser; -- EXPLAIN (below)

/*

CREATE USER Username FOR LOGIN again username  -- username is the one which we gave in create login right?

✅ Yes — in this line:

					CREATE USER hmailuser FOR LOGIN hmailuser;


Both hmailuser refer to the same name you used when you created the login earlier with:

					CREATE LOGIN hmailuser WITH PASSWORD = 'YourStrongPassword';



Here’s what happens:

The first hmailuser → is the database user name (you can name it differently if you want).

The second hmailuser → is the server login that already exists.

So the syntax links that login to a database-level user.



✅ Example (same name):

					CREATE USER hmailuser FOR LOGIN hmailuser;


✅ Example (different names):

					CREATE USER maildb_user FOR LOGIN hmailuser;


This means: “Inside this database, I’ll call the user maildb_user, but it’s still tied to the login hmailuser.”

So yes — by default, you can (and usually should) keep them the same name for simplicity.

*/

------------------------------------------------------------------------------------------------------------------------------

ALTER ROLE db_owner ADD MEMBER hmailuser;

/*

You already know ALTER usually means “change something that already exists.”
Here, we’re not changing a table — we’re changing a role (a group of permissions).

-- ----------------------------------------------------------------------------

🧠 What’s a “role” in SQL Server?-----------


Think of a role like a “team” or “group” that has certain permissions.
For example:

				The db_owner			role = full control over the database (like an admin).

				The db_datareader		role = can only read tables.

				The db_datawriter		role = can insert/update/delete but not change structure.

Instead of assigning 10 permissions one by one, we just say:
				“Make this user a member of this role.”

ADD MEMBER	-		We’re adding a user into that role.
---------------------------------------------------------------------------------------------------------------

🧩 Breaking down the syntax


Part				|	Meaning
--------------------|--------------------------
ALTER ROLE			|	Change something about a database role.
db_owner			|	The built-in role we’re modifying. It already exists in every database.
ADD MEMBER			|	We’re adding a user into that role.
hmailuser			|	The username inside this database.


So effectively, this command means:

“Add the user hmailuser into the db_owner team so it gets full permissions on this database.”

-------------------------------------------------------------------------------------------------------------------

🧩 Example to make it click -------------------------------------

Imagine your database is like a company:

					db_owner = “Manager” group

					hmailuser = “Employee”
-----------------------
When you run:

ALTER ROLE db_owner ADD MEMBER hmailuser;

------------------------
You’re saying:

“Make hmailuser a Manager in this company (MailDB).”

*/


-----------------------------------------------------------------------------------------------

/*

can i delete this login later? 

🧩 1️⃣ Delete only the database user (inside one database)------------------------------

If you just want to remove the user from your project database but keep the login:

								USE EmailAnalyticsDB;
								DROP USER hmailuser;
								GO


This removes their access to that one database, but the login still exists at the SQL Server level.

----------------------------------------------------------------------------------------------------------------------------------

🧩 2️⃣ Delete the server-level login---------------------

If you want to fully remove the account from your SQL Server (cannot log in anymore):

								USE master;
								DROP LOGIN hmailuser;
								GO


👉 You can only drop a login after removing its corresponding database user(s).

---------------------------------------------------------------------------------------------------------------------------------------

🧩 3️⃣ Delete the database itself (optional cleanup)-----------------------

If you want to reset completely and start fresh:

							USE master;
							DROP DATABASE EmailAnalyticsDB;
							GO

🧠 Summary-----------------------------------------

Action	Command	Effect
Remove user from one DB	DROP USER hmailuser	Removes access to that DB only
Remove from whole SQL Server	DROP LOGIN hmailuser	Deletes login from server
Remove everything (DB + user + login)

*/
---------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
/*

how to change password?

🧩 Change password for an existing SQL login


								ALTER LOGIN hmailuser WITH PASSWORD = 'NewStrongPassword123!';
								GO

----------------------------------------------------------------------
✅ What it does:

Changes the password for the server-level login hmailuser.

Works whether or not the login is currently mapped to any databases.

You must run it in a context where you have permission (for example, as an admin or sa user).

-----------------------------------------------------------------------

⚠️ Optional: enforce password policy--------------------------------

If you want SQL Server to apply Windows password rules (length, complexity, expiry), you can use:

ALTER LOGIN hmailuser WITH PASSWORD = 'NewStrongPassword123!' CHECK_POLICY = ON;


If you don’t want that (simpler for local testing), use:

ALTER LOGIN hmailuser WITH PASSWORD = 'NewStrongPassword123!' CHECK_POLICY = OFF;



🧠 Important notes----------------------------------

You don’t need to re-create the user or database — just update the connection password in hMailServer Administrator if it was already connected.

The change is instant — the new password takes effect immediately.

*/


 ---------------------------------------------------------

SELECT
  principal_id,
  name,
  type_desc,        -- SQL_LOGIN, WINDOWS_LOGIN, WINDOWS_GROUP, etc.
  is_disabled,
  create_date,
  modify_date
FROM sys.server_principals
WHERE type_desc IN ('SQL_LOGIN','WINDOWS_LOGIN','WINDOWS_GROUP')
ORDER BY name;


 ---------------------------------------------------------


 SELECT 1
FROM sys.server_principals
WHERE name = 'hmailuser'

GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hmailuser')
  PRINT 'Login exists';
ELSE
  PRINT 'Login does not exist';


 ---------------------------------------------------------
