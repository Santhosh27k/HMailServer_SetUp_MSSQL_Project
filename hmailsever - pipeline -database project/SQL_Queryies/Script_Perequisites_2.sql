
/* ================================================================
   Author      : Santhosh
   GitHub      : https://github.com/Santhosh27k
   LinkedIn    : https://www.linkedin.com/in/santhosh-s-219287228
   Project     : hMailServer SQL Database Setup
   Description : Removes all constraints, indexes, tables, and database 
                 (only run if an existing hMailServer setup needs to be deleted)
   ================================================================= */






IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('hm_drop_column_objects'))
DROP PROC hm_drop_column_objects
GO


CREATE OR ALTER PROCEDURE hm_drop_column_objects
    @TableName SYSNAME,
    @ColumnName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'';

    ----------------------------------------------------------------
    -- 1️⃣ DROP DEFAULT CONSTRAINTS
    ----------------------------------------------------------------
    SELECT @sql = @sql +
        N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) +
        N' DROP CONSTRAINT ' + QUOTENAME(dc.name) + N';' + CHAR(13)
    FROM sys.default_constraints AS dc
    JOIN sys.columns AS c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
    JOIN sys.tables AS t ON t.object_id = c.object_id
    JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    WHERE t.name = @TableName
      AND c.name = @ColumnName;

    ----------------------------------------------------------------
    -- 2️⃣ DROP CHECK CONSTRAINTS
    ----------------------------------------------------------------
    SELECT @sql = @sql +
        N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) +
        N' DROP CONSTRAINT ' + QUOTENAME(cc.name) + N';' + CHAR(13)
    FROM sys.check_constraints AS cc
    JOIN sys.tables AS t ON cc.parent_object_id = t.object_id
    JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    WHERE t.name = @TableName
      AND cc.definition LIKE '%' + @ColumnName + '%';

    ----------------------------------------------------------------
    -- 3️⃣ DROP FOREIGN KEYS
    ----------------------------------------------------------------
    SELECT @sql = @sql +
        N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) +
        N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(13)
    FROM sys.foreign_keys AS fk
    JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
    JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    WHERE t.name = @TableName
      AND OBJECT_DEFINITION(fk.object_id) LIKE '%' + @ColumnName + '%';

    ----------------------------------------------------------------
    -- 4️⃣ DROP INDEXES
    ----------------------------------------------------------------
    SELECT @sql = @sql +
        N'DROP INDEX ' + QUOTENAME(i.name) +
        N' ON ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + N';' + CHAR(13)
    FROM sys.indexes AS i
    JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    JOIN sys.tables AS t ON t.object_id = c.object_id
    JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    WHERE t.name = @TableName
      AND c.name = @ColumnName
      AND i.is_primary_key = 0
      AND i.is_unique_constraint = 0;

    ----------------------------------------------------------------
    -- 5️⃣ DROP PRIMARY OR UNIQUE CONSTRAINTS (if referencing this column)
    ----------------------------------------------------------------
    SELECT @sql = @sql +
        N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) +
        N' DROP CONSTRAINT ' + QUOTENAME(i.name) + N';' + CHAR(13)
    FROM sys.indexes AS i
    JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    JOIN sys.tables AS t ON t.object_id = c.object_id
    JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    WHERE t.name = @TableName
      AND c.name = @ColumnName
      AND (i.is_primary_key = 1 OR i.is_unique_constraint = 1);

    ----------------------------------------------------------------
    -- 6️⃣ EXECUTE ALL GENERATED COMMANDS
    ----------------------------------------------------------------
    IF @sql <> N''
    BEGIN
        PRINT 'Dropping related constraints and indexes for [' + @TableName + '].[' + @ColumnName + ']...';
        PRINT @sql;  -- Optional: view generated commands before execution
        EXEC sp_executesql @sql;
    END
    ELSE
        PRINT 'No related objects found for [' + @TableName + '].[' + @ColumnName + '].';

END;

