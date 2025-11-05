
/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Renames SQL login, database user, or schema mappings as required
   ================================================================= */

---------------------------------------------------------------------------------------------------------------------------------

-- TO Alter Nmae of "Login In sever level  


								--		ALTER LOGIN [current_login_name] WITH NAME = [new_login_name];



---------------------------------------------------------------------------------------------------------------------------------


USE EmailAnalyticsDB;

---------------------------------------------------------------------------------------------------------------------------------

-- TO Alter Nmae of "Login In sever level  


								--		ALTER USER [current_user_name] WITH NAME = [new_user_name];

	ALTER USER	hmailuser WITH NAME = hmailadim1


---------------------------------------------------------------------------------------------------------------------------------