# Virtual Columns in Oracle Database 11g Release 1

[__](http://twitter.com/intent/tweet?status=ORACLE-
BASE%20-%20Virtual%20Columns%20in%20Oracle%20Database%2011g%20Release%201+https%3A%2F%2Foracle-
base.com%2Farticles%2F11g%2Fvirtual-columns-11gr1)
[__](http://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Foracle-
base.com%2Farticles%2F11g%2Fvirtual-columns-11gr1&title=ORACLE-
BASE%20-%20Virtual%20Columns%20in%20Oracle%20Database%2011g%20Release%201)
[__](https://plus.google.com/share?url=https%3A%2F%2Foracle-
base.com%2Farticles%2F11g%2Fvirtual-columns-11gr1)
[__](http://www.linkedin.com/shareArticle?mini=true&url=https%3A%2F%2Foracle-
base.com%2Farticles%2F11g%2Fvirtual-columns-11gr1&title=ORACLE-
BASE%20-%20Virtual%20Columns%20in%20Oracle%20Database%2011g%20Release%201&source=oracle-
base.com) [__](http://www.reddit.com/submit?url=https%3A%2F%2Foracle-
base.com%2Farticles%2F11g%2Fvirtual-columns-11gr1&title=ORACLE-
BASE%20-%20Virtual%20Columns%20in%20Oracle%20Database%2011g%20Release%201)

[Home](https://oracle-base.com/) » [Articles](https://oracle-
base.com/articles) » [11g](https://oracle-base.com/articles/11g) » Here  

# Virtual Columns in Oracle Database 11g Release 1

When queried, virtual columns appear to be normal table columns, but their
values are derived rather than being stored on disc. The syntax for defining a
virtual column is listed below.

    
    
    column_name [datatype] [GENERATED ALWAYS] AS (expression) [VIRTUAL]

If the datatype is omitted, it is determined based on the result of the
expression. The `GENERATED ALWAYS` and `VIRTUAL` keywords are provided for
clarity only.

The script below creates and populates an employees table with two levels of
commission. It includes two virtual columns to display the commission-based
salary. The first uses the most abbreviated syntax while the second uses the
most verbose form.

    
    
    CREATE TABLE employees (
      id          NUMBER,
      first_name  VARCHAR2(10),
      last_name   VARCHAR2(10),
      salary      NUMBER(9,2),
      comm1       NUMBER(3),
      comm2       NUMBER(3),
      salary1     AS (ROUND(salary*(1+comm1/100),2)),
      salary2     NUMBER GENERATED ALWAYS AS (ROUND(salary*(1+comm2/100),2)) VIRTUAL,
      CONSTRAINT employees_pk PRIMARY KEY (id)
    );
    
    INSERT INTO employees (id, first_name, last_name, salary, comm1, comm2)
    VALUES (1, 'JOHN', 'DOE', 100, 5, 10);
    
    INSERT INTO employees (id, first_name, last_name, salary, comm1, comm2)
    VALUES (2, 'JAYNE', 'DOE', 200, 10, 20);
    COMMIT;

Querying the table shows the inserted data plus the derived commission-based
salaries.

    
    
    SELECT * FROM employees;
    
            ID FIRST_NAME LAST_NAME      SALARY      COMM1      COMM2    SALARY1    SALARY2
    ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
             1 JOHN       DOE               100          5         10        105        110
             2 JAYNE      DOE               200         10         20        220        240
    
    2 rows selected.
    
    SQL>

The expression used to generate the virtual column is listed in the
`DATA_DEFAULT` column of the `[DBA|ALL|USER]_TAB_COLUMNS` views.

    
    
    COLUMN data_default FORMAT A50
    SELECT column_name, data_default
    FROM   user_tab_columns
    WHERE  table_name = 'EMPLOYEES';
    
    COLUMN_NAME                    DATA_DEFAULT
    ------------------------------ --------------------------------------------------
    ID
    FIRST_NAME
    LAST_NAME
    SALARY
    COMM1
    COMM2
    SALARY1                        ROUND("SALARY"*(1+"COMM1"/100),2)
    SALARY2                        ROUND("SALARY"*(1+"COMM2"/100),2)
    
    8 rows selected.
    
    SQL>

Notes and restrictions on virtual columns include:

  * Indexes defined against virtual columns are equivalent to function-based indexes.
  * Virtual columns can be referenced in the `WHERE` clause of updates and deletes, but they cannot be manipulated by DML.
  * Tables containing virtual columns can still be eligible for result caching.
  * Functions in expressions must be deterministic at the time of table creation, but can subsequently be recompiled and made non-deterministic without invalidating the virtual column. In such cases the following steps must be taken after the function is recompiled:  

    * Constraint on the virtual column must be disabled and re-enabled.
    * Indexes on the virtual column must be rebuilt.
    * Materialized views that access the virtual column must be fully refreshed.
    * The result cache must be flushed if cached queries have accessed the virtual column.
    * Table statistics must be regathered.
  * Virtual columns are not supported for index-organized, external, object, cluster, or temporary tables.
  * The expression used in the virtual column definition has the following restrictions:  

    * It cannot refer to another virtual column by name.
    * It can only refer to columns defined in the same table.
    * If it refers to a deterministic user-defined function, it cannot be used as a partitioning key column.
    * The output of the expression must be a scalar value. It cannot return an Oracle supplied datatype, a user-defined type, or LOB or LONG RAW.

Here is an example of [Virtual Column-Based Partitioning](https://oracle-
base.com/articles/11g/partitioning-
enhancements-11gr1#virtual_column_based_partitioning).

For more information see:

  * [CREATE TABLE](http://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_7002.htm)
  * [Virtual Column-Based Partitioning](https://oracle-base.com/articles/11g/partitioning-enhancements-11gr1#virtual_column_based_partitioning)

Hope this helps. Regards Tim...

[Back to the Top.](https://oracle-base.com/articles/11g/virtual-
columns-11gr1#Top)



---
### TAGS
{virtual column}

---
### NOTE ATTRIBUTES
>Created Date: 2018-05-24 06:00:52  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>source: web.clip7  
>source-url: https://oracle-base.com/articles/11g/virtual-columns-11gr1  
>source-application: WebClipper 7  