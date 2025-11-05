
/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Changes password for existing SQL login used by hMailServer
   ================================================================= */



ALTER LOGIN hmailuser WITH PASSWORD = 'NewStrongPassword123!';
GO


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
-------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
============================================================================================================================================

/*


🧩 1️⃣ What CHECK_POLICY actually does-------------------------------------------



CHECK_POLICY controls whether SQL Server enforces Windows password policy rules for that SQL login.

When it’s set to ON, SQL Server uses the same password rules as Windows does — meaning:
✅ minimum length
✅ complexity (uppercase, lowercase, number, symbol)
✅ can require periodic changes (if Windows policy enforces that)

When it’s OFF, SQL Server accepts any password you type (even simple ones like 1234).


-----------------------------------------------------------------------------------------------------------------

🧩 2️⃣ Why you didn’t need it in your first script-----------------------------------

When you ran:

CREATE LOGIN hmailuser WITH PASSWORD = 'StrongPassword123!';


you didn’t include CHECK_POLICY = ON or OFF.

That’s fine — SQL Server defaults to:

CHECK_POLICY = ON if your system is joined to a Windows domain or uses Windows authentication policy.

CHECK_POLICY = OFF if you’re on a standalone machine (common for local laptop testing).

So, your original script was safe.
It just inherited whatever your SQL Server default security policy was.

--------------------------------------------------------------------------------------------------------------------------

🧩 3️⃣ If you ever want to check or change it-----------------------


You can view whether the policy is on:

					SELECT name, is_policy_checked
					FROM sys.sql_logins
					WHERE name = 'hmailuser';


If is_policy_checked = 1, it means CHECK_POLICY is ON.

You can change it anytime:

					ALTER LOGIN hmailuser WITH CHECK_POLICY = OFF;


🧠 In short:
Option	Meaning	When to use
CHECK_POLICY = ON	Enforces strong passwords using Windows security rules	For production / real servers
CHECK_POLICY = OFF	Lets you use any password	For local testing & projects like hMailServer + SQL setup

--========================================================================================================================