

/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Removes all constraints, indexes, tables, and database 
                 (only run if an existing hMailServer setup needs to be deleted)
   ================================================================= */


--  NOTE - Replace database name in line 24 and 295 (and remove comment for that)

/*

Understanding what ScriptPrerequisitesMSSQL.sql is doing

This script, as the name suggests, sets up prerequisite objects and permissions that hMailServer needs before creating its main database schema. It typically:

Creates helper stored procedures, functions, or supporting objects.

Grants required permissions on the database or schema for the login.

Prepares the environment so the main schema creation scripts won't fail due to missing rights or dependencies.

*/

						--SELECT * FROM sysobjects

-- USE  Database_name

 -- Example -    
 -- USE  EmailAnalyticsDB

GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('hm_drop_column_objects'))
DROP PROC hm_drop_column_objects
GO

		/*	sysobjects				-		It only shows objects within the current database you are connected to.	
			IF OBJECT_ID (Function) -		It’s just a way to check if a database object exists before doing something (like dropping it).
			Stored Procedure /PROC	-		A precompiled block of SQL code that can include queries, IF...ELSE, loops, transactions, and even error handling.
		*/

CREATE OR ALTER PROCEDURE hm_drop_column_objects

						/*
						🔹 Purpose of this Procedure

						The procedure hm_drop_column_objects is meant to:

						Delete constraints (like PRIMARY KEY, FOREIGN KEY, CHECK, DEFAULT) that involve a specific column.

						Delete indexes that include that column.

						This is often used before dropping a column, because SQL Server won’t allow you to drop a column if there are dependent constraints or indexes.
						*/

	@tablename SYSNAME,      -- Name of the table
	@columnname SYSNAME     -- Name of the column to remove dependencies from
                                                    /* What is sysname?
                                                    sysname is a built-in user-defined type provided by SQL Server.
                                                    It is used internally by SQL Server to store names of database objects — like tables, columns, constraints, etc.*/
	AS
	BEGIN
	
    SET NOCOUNT ON;

                                                     /*
                    
                                                            *    When you run a SQL statement (like UPDATE, DELETE, INSERT, etc.), SQL Server by default sends back a message like:

                                            (5 rows affected)           -- message  -- That’s what @@ROWCOUNT refers to — it’s the number of rows affected by the last statement.

                                                             *    SET NOCOUNT ON; tells SQL Server:       “Don’t send back those (x rows affected) messages.”


                                                              #  Why It’s Used in Stored Procedures ?

                                                                        * Prevents extra network traffic

                                                                        *    Avoids confusion in results
                    */



    DECLARE @constname SYSNAME,             -- To hold the name of the current constraint or index being dropped inside the cursor loop.
            @cmd NVARCHAR(1024);            --  To hold the dynamic SQL command built as a text string.

    PRINT '--- Starting cleanup for column [' + @columnname + '] in table [' + @tablename + '] ---';

    -----------------------------------------------------------------------
    -- ✅ Check if table exists
    -----------------------------------------------------------------------
    IF OBJECT_ID(@tablename, 'U') IS NULL
    BEGIN
        PRINT 'Error: Table [' + @tablename + '] does not exist.';
        RETURN;
    END

    -----------------------------------------------------------------------
    -- ✅ Check if column exists
    -----------------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@tablename)
          AND name = @columnname
    )
    BEGIN
        PRINT 'Error: Column [' + @columnname + '] does not exist in table [' + @tablename + '].';
        RETURN;
    END

----------------------------------------------------------------------
    -- 🔹 1: Drop Column-Level Constraints (DEFAULT, column-level CHECK)
    -----------------------------------------------------------------------
    DECLARE curs_column_constraints CURSOR FOR
    SELECT dc.name
    FROM sys.default_constraints dc                                     -- # sys.default_constraints is a system catalog view in SQL Server.
   
    --Matches each default constraint to the column it belongs to.
   
   INNER JOIN sys.columns c                                            -- # sys.columns is another system view.
        ON dc.parent_object_id = c.object_id                           -- → constraint belongs to this table 
       AND dc.parent_column_id = c.column_id                           -- → constraint belongs to this column 
    WHERE c.name = @columnname
      AND OBJECT_NAME(c.object_id) = @tablename;

    OPEN curs_column_constraints;
    FETCH NEXT FROM curs_column_constraints INTO @constname;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @cmd = 'ALTER TABLE ' + QUOTENAME(@tablename) +
                   ' DROP CONSTRAINT ' + QUOTENAME(@constname);
        PRINT 'Dropping column-level constraint: ' + @constname;
        EXEC sp_executesql @cmd;

        FETCH NEXT FROM curs_column_constraints INTO @constname;
    END

    CLOSE curs_column_constraints;
    DEALLOCATE curs_column_constraints;



    -----------------------------------------------------------------------
    -- 🔹 2: Drop Table-Level Constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE)
    -----------------------------------------------------------------------
    DECLARE curs_table_constraints CURSOR FOR
    SELECT CONSTRAINT_NAME
    FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
    WHERE TABLE_NAME = @tablename
      AND COLUMN_NAME = @columnname;

    OPEN curs_table_constraints;
    FETCH NEXT FROM curs_table_constraints INTO @constname;          -- it takes the next row (next constraint name) from the cursor’s result set and puts it into the variable @constname.

    WHILE @@FETCH_STATUS = 0                                        -- @@FETCH_STATUS is a system variable that shows the result of the last FETCH NEXT command.
                                                                    -- It returns: 0 → Success (a row was fetched) ; -1 → No more rows (end of cursor) ; -2 → Row was missing (error) ;
                                    --(same as python)             --  ✅ The loop continues as long as condition is True
                                                                    --  ❌ The loop stops when condition becomes  False
    
    BEGIN
        SET @cmd = 'ALTER TABLE ' + QUOTENAME(@tablename) +
                   ' DROP CONSTRAINT ' + QUOTENAME(@constname);         -- If your table name = Orders and your constraint name = FK_Orders_Customers
                                                                            --      'ALTER TABLE [Orders] DROP CONSTRAINT [FK_Orders_Customers]'  --# which is still a string


        PRINT 'Dropping table-level constraint: ' + @constname;

        EXEC sp_executesql @cmd;                                        ---  sp_executesql is a system stored procedure that executes a string as SQL code.

        FETCH NEXT FROM curs_table_constraints INTO @constname;
    END

    CLOSE curs_table_constraints;
    DEALLOCATE curs_table_constraints;


    -----------------------------------------------------------------------
    -- 🔹 3. Drop Indexes associated with the column
    -----------------------------------------------------------------------
    DECLARE curs_indexes CURSOR FOR
    SELECT i.name
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE c.name = @columnname
      AND OBJECT_NAME(i.object_id) = @tablename
      AND i.is_primary_key = 0
      AND i.is_unique_constraint = 0;

    OPEN curs_indexes;
    FETCH NEXT FROM curs_indexes INTO @constname;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @cmd = 'DROP INDEX ' + QUOTENAME(@constname) + 
                   ' ON ' + QUOTENAME(@tablename);
        PRINT 'Dropping index: ' + @constname;
        EXEC sp_executesql @cmd;

        FETCH NEXT FROM curs_indexes INTO @constname;
    END

    CLOSE curs_indexes;
    DEALLOCATE curs_indexes;


    -----------------------------------------------------------------------
    -- 🔹 4. Drop Indexes associated with the Table-level                                -- Simpler method 
    -----------------------------------------------------------------------

    DECLARE @sql NVARCHAR(MAX) = '';

-- Build DROP INDEX statements for all user-created indexes
    SELECT 
        @sql = @sql + 
                'DROP INDEX ' + QUOTENAME(i.name) + 
                ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';' + CHAR(13)
    FROM sys.indexes AS i
    JOIN sys.tables AS t ON i.object_id = t.object_id
    JOIN sys.schemas AS s ON t.schema_id = s.schema_id
    WHERE 
        i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND i.name IS NOT NULL
        AND t.is_ms_shipped = 0;

    -- Show what will run (optional for review)
    PRINT @sql;

    -- Uncomment to actually run it
    EXEC sp_executesql @sql;

    -----------------------------------------------------------------------
    -- ✅ Summary
    -----------------------------------------------------------------------
    PRINT '--- All related constraints, defaults, and indexes dropped for [' + @columnname + '] in [' + @tablename + '] ---';
  END

GO

    -----------------------------------------------------------------------
    -- 🔹 5. Drop All Table if any in database
    -----------------------------------------------------------------------

    DECLARE @sql2 NVARCHAR(MAX) = N'';

    -- Build DROP TABLE statements for all user tables
    SELECT @sql2 += N'DROP TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + N';' + CHAR(13)
            
                                                        /* The N in SQL has nothing to do with appending or concatenation.
                                                            It’s only about the type of string — telling SQL Server:

                                                            “Hey, treat this text as Unicode (NVARCHAR), not as regular text (VARCHAR).” 
                                                            
                                                            If we add N in front it will consider has Unicode */


                                                        /* 
                                                        🧩 What is CHAR(13)?

                                                                It’s a carriage return (Enter key) character.
                                                                In plain English → it tells SQL Server:

                                                                “Move the cursor to the beginning of the next line.”

                                                                🧠 Think of it like typing this:

                                                                                DROP TABLE [dbo].[Customers];
                                                                                ↩️  ← (that’s CHAR(13))
                                                                                DROP TABLE [dbo].[Orders];


                                                                So when you PRINT the SQL script later, you get:

                                                                                    DROP TABLE [dbo].[Customers];
                                                                                    DROP TABLE [dbo].[Orders];


                                                                Instead of this:

                                                                                    DROP TABLE [dbo].[Customers];DROP TABLE [dbo].[Orders];

                                                                */


    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.is_ms_shipped = 0;  -- Skip system tables

    -- Show what will run (optional, for review)
    PRINT @sql2;

    -- Uncomment to actually run the drop statements
    EXEC sp_executesql @sql2;

    GO

    --# DROP DATABASE Database_name