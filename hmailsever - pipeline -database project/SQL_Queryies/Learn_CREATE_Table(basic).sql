

USE EmailAnalyticsDB

-- ERROR WORNG WAY TO DO --------------XXXXXX-------		❌ Not ideal (can confuse ordering or conflict if not exact)

CREATE TABLE hm_accounts (
	accountid INT IDENTITY (1, 1) NOT NULL, --- this should be non clustered .. 
	accountdomainid INT NOT NULL ,
	accountadminlevel TINYINT NOT NULL,
	accountaddress NVARCHAR(255) NOT NULL UNIQUE ,
	accountpassword NVARCHAR(255) NOT NULL,
	accountactive BIT NOT NULL, 
	accountisad BIT NOT NULL, 
	accountaddomain NVARCHAR(255),
	accountadusername NVARCHAR(255),
	accountmaxsize INT,
	accountvacationmessageon BIT NOT NULL DEFAULT 0,
	accountvacationmessage NVARCHAR(1000),
	accountvacationsubject NVARCHAR(200),
	accountpwencryption TINYINT,
	accountforwardenabled BIT NOT NULL DEFAULT 0,
	accountforwardaddress NVARCHAR(255),
	accountforwardkeeporiginal BIT NOT NULL DEFAULT 1,
	accountenablesignature BIT NOT NULL DEFAULT 0,
	accountsignatureplaintext NVARCHAR(MAX),
	accountsignaturehtml NVARCHAR(MAX),
	accountlastlogontime DATETIME,
	accountvacationexpires BIT NOT NULL DEFAULT 0,
	accountvacationexpiredate DATETIME,
	accountpersonfirstname NVARCHAR(60),
	accountpersonlastname NVARCHAR(60)

	CONSTRAINT hm_accounts_pk PRIMARY KEY NONCLUSTERED (accountid),
	CONSTRAINT u_accountaddress UNIQUE CLUSTERED (accountaddress)
	
);

-- index (must be separate statement)
CREATE CLUSTERED INDEX idx_hm_accounts ON hm_accounts (accountaddress);


/* Note:--------------

While this might look fine syntactically, SQL Server does not allow multiple clustered keys/constraints in the same table definition.
A UNIQUE CLUSTERED constraint is implemented as a clustered index, and since the PRIMARY KEY also wants to define a key/index, SQL Server sometimes raises an error if the table doesn’t exist yet.

In practice:

You can only have one clustered index per table.

The PRIMARY KEY doesn’t have to be clustered — it can be explicitly NONCLUSTERED.

But to apply a CLUSTERED UNIQUE constraint on another column, SQL Server often requires the table to already exist.

So while your first definition is conceptually correct, it’s less clean and can fail or behave unexpectedly depending on SQL Server version or DDL parsing order.

---------------------------------------------------


🧩 Why not define both inside CREATE TABLE?

SQL Server allows clustered and nonclustered indexes/constraints to be defined inside the table statement, but mixing PRIMARY KEY NONCLUSTERED and UNIQUE CLUSTERED inside CREATE TABLE can look messy or confusing to maintain.
By separating them with ALTER TABLE and explicit CREATE INDEX, you:

Keep index/constraint logic modular.

Avoid dependency order issues.

Match enterprise-style standards.



*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Option							- ✅ The Best Practice (Cleaner & More Reliable)


-- It’s explicit, clear, and SQL Server likes it better:


CREATE TABLE hm_accounts2 (
	accountid INT IDENTITY(1,1) NOT NULL,
	accountdomainid INT NOT NULL,
	accountadminlevel TINYINT NOT NULL,
	accountaddress NVARCHAR(255) NOT NULL,
	accountpassword NVARCHAR(255) NOT NULL,
	accountactive BIT NOT NULL,
	accountisad BIT NOT NULL,
	accountaddomain NVARCHAR(255),
	accountadusername NVARCHAR(255),
	accountmaxsize INT,
	accountvacationmessageon BIT NOT NULL DEFAULT 0,
	accountvacationmessage NVARCHAR(1000),
	accountvacationsubject NVARCHAR(200),
	accountpwencryption TINYINT,
	accountforwardenabled BIT NOT NULL DEFAULT 0,
	accountforwardaddress NVARCHAR(255),
	accountforwardkeeporiginal BIT NOT NULL DEFAULT 1,
	accountenablesignature BIT NOT NULL DEFAULT 0,
	accountsignatureplaintext NVARCHAR(MAX),
	accountsignaturehtml NVARCHAR(MAX),
	accountlastlogontime DATETIME,
	accountvacationexpires BIT NOT NULL DEFAULT 0,
	accountvacationexpiredate DATETIME,
	accountpersonfirstname NVARCHAR(60),
	accountpersonlastname NVARCHAR(60)
);

-- Primary key as NONCLUSTERED on accountid
ALTER TABLE hm_accounts2
ADD CONSTRAINT hm_accounts_pk PRIMARY KEY NONCLUSTERED (accountid);

-- Unique constraint as NONCLUSTERED on accountaddress
ALTER TABLE hm_accounts2
ADD CONSTRAINT u_accountaddress UNIQUE NONCLUSTERED (accountaddress);

-- Then create a CLUSTERED INDEX on accountaddress
CREATE CLUSTERED INDEX idx_hm_accounts2 ON hm_accounts2 (accountaddress);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



/* 
NOTE 1 - FOR Option 2 

Quick notes / caveats

This will work: SQL Server allows a unique nonclustered index/constraint and a clustered index on the same column. 
But it’s usually redundant to keep both because the clustered index already enforces uniqueness for that column (if the clustered index is unique). 
You’ll end up maintaining two indexes on the same key which increases storage and write overhead.

If your goal is to have accountaddress be the clustered key and unique, you could instead create the UNIQUE constraint as CLUSTERED (or make the clustered index the unique clustered index) 
and avoid the extra nonclustered unique index.



Typical patterns:

	* Primary key CLUSTERED on accountid (default) and a UNIQUE NONCLUSTERED on accountaddress.

	* OR primary key NONCLUSTERED and CLUSTERED unique index on accountaddress (what you asked for).

	* Because you explicitly asked for PK NONCLUSTERED and idx_hm_accounts2 CLUSTERED on accountaddress, the script above does exactly that.


*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* 

-------------------------------------------------------

✅ What is allowed inside CREATE TABLE


Option 1: Inline UNIQUE constraint (default = NONCLUSTERED if a clustered index already exists)
-------

							CREATE TABLE hm_accounts (
								accountid INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
								accountaddress NVARCHAR(255) NOT NULL UNIQUE
							);


						-- index (must be separate statement)
						CREATE CLUSTERED INDEX idx_hm_accounts ON hm_accounts (accountaddress);



		👉 This creates a UNIQUE NONCLUSTERED index automatically (because the clustered one already belongs to the primary key).
		If there’s no clustered index yet, SQL Server may make the unique constraint clustered by default, unless you already defined another clustered index elsewhere.

--------------------------------------------------------------

Option 2: Table-level constraint with explicit index type
-------

	If you want explicit control over CLUSTERED vs NONCLUSTERED, you must define it after the table:

							CREATE TABLE hm_accounts (
								accountid INT IDENTITY(1,1) NOT NULL,
								accountaddress NVARCHAR(255) NOT NULL
							);

							ALTER TABLE hm_accounts
							ADD CONSTRAINT hm_accounts_pk PRIMARY KEY NONCLUSTERED (accountid);

							ALTER TABLE hm_accounts
							ADD CONSTRAINT u_accountaddress UNIQUE NONCLUSTERED (accountaddress);

							CREATE CLUSTERED INDEX idx_hm_accounts ON hm_accounts (accountaddress);

--------------------------------------------------------------

Option 3: If you want everything inline plus an index inside the CREATE TABLE
-------

	You can define constraints inline but indexes must be created separately, even within the same batch:

						CREATE TABLE hm_accounts (
							accountid INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED,
							accountaddress NVARCHAR(255) NOT NULL UNIQUE,
							accountpassword NVARCHAR(255) NOT NULL
						);

						-- index (must be separate statement)
						CREATE CLUSTERED INDEX idx_hm_accounts ON hm_accounts (accountaddress);



--------------------------------------------------------------
NOTE - 

🧩 Why SQL Server works this way

The UNIQUE keyword in the column definition is shorthand for a unique constraint, not a direct index definition.

SQL Server allows CLUSTERED / NONCLUSTERED keywords only in:

PRIMARY KEY or UNIQUE constraint definitions (table-level)

CREATE INDEX statements

It doesn’t allow them inline at the column level because it would blur the difference between a constraint and an index (and constraints can automatically create indexes).


*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



/*





Since this table (hm_accounts) is for hMailServer, it’s part of a mail system backend, so we must prioritize:
✅ fast lookups by account address (email)
✅ stable identity keys for relations (foreign keys)
✅ balanced read/write performance

----------------

Let’s break it down carefully.

⚙️ What hMailServer actually does

In the original hMailServer SQL schema, the setup looks almost exactly like what you posted:

					ALTER TABLE hm_accounts ADD CONSTRAINT hm_accounts_pk PRIMARY KEY NONCLUSTERED (accountid)
					ALTER TABLE hm_accounts ADD CONSTRAINT u_accountaddress UNIQUE NONCLUSTERED (accountaddress)
					CREATE CLUSTERED INDEX idx_hm_accounts ON hm_accounts (accountaddress)


So the hMailServer developers deliberately made:

					Primary key = accountid (NONCLUSTERED)

Clustered index = accountaddress

-----------------------------

🔍 Why they did that

Email address (accountaddress) is the most frequently queried field — every time a user logs in, sends/receives mail, or system checks mailbox, it searches by address.
→ Clustering on it means data is physically ordered by accountaddress → very fast lookups.

accountid is mainly used as a foreign key reference (in other tables like hm_messages, hm_imapfolders, etc.).
→ Those tables don’t need clustered ordering by accountid; a simple nonclustered PK is enough for referential integrity.

So they optimized for lookup speed by email address (real-world query pattern), not just traditional “PK clustered” setup.

-----------------


Option - 2 is best 

*/