


/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Finds and deletes any existing SQL logins related to hMailServer
   ================================================================= */




--🧩 Step 1: Find which login hMailServer uses

'''The login info is stored in hMailServer’s configuration file, not inside SQL.
Open this file on your computer:

C:\Program Files (x86)\hMailServer\Bin\hMailServer.ini


Then look under the [Database] section — for example:

[Database]
Type=MSSQLCE
Username=hmailuser
Password=encryptedpasswordhere
Port=0
Server=localhost
Database=hMailServer


👉 The Username= line tells you the SQL login name hMail uses to connect (e.g. hmailuser).'''

-------------------------------------------------------------------------------------------------------------------------------------------
								--		OR	--
-------------------------------------------------------------------------------------------------------------------------------------------

--🧩 Step 2: Find that login inside SQL Server

'''In SQL Server Management Studio (SSMS), open a New Query in the master database and run:'''

SELECT name, type_desc
FROM sys.server_principals
WHERE name LIKE '%hmail%';


'''That will list any logins related to hMail (adjust the LIKE filter if you see a different username in the INI file).'''


--🧩 Step 3: Delete the login (if you’re sure)

'''Once you confirm the exact username, run:'''

DROP LOGIN [hmailuser];


'''Replace hmailuser with the actual name from step 1 or step 2.'''

-------------------------------------------

-- If the login is also mapped to a user inside the hMailServer database, you can remove that too:

--USE [hMailServer];

--DROP USER [hmailuser];


-------------------------------------------------------------------------------------------------------------------------------------------

--🧩 Step 4: Verify it’s gone

SELECT name
FROM sys.server_principals
WHERE name LIKE '%hmail%';


'''If no rows are returned — ✅ the SQL login is deleted.'''


