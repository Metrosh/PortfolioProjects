--Retrieving Records

--1
--You have a table and want to see all of the data in it.

SELECT 
	*
FROM 
	emp

SELECT 
	empno,
	ename,
	job,
	mgr,
	hiredate,
	sal,
	comm,
	deptno
FROM 
	emp

--For program code, it's better to specify each column individually. The performance will be the same, but by being explicit you will always know what columns you are returning from the query.
--These queries will be easier to understand by people other than yourself who may or may not know all the columns in a table.

--2
--You have a table and want to see only rows that satisfy a specific condition.
--Use the WHERE clause to specify which rows to keep.
--Find: all the employees in dept 10

SELECT 
	*
FROM 
	emp
WHERE 
	deptno = 10

--Common operators are =, <, >, <=, >=, ! and <>. You may want rows that satisfy multiple conditions, as in the next example.

--3
--You want to return rows that satisfy multiple conditions.
--Find: All the employees in dept 10, all employees who earn a commission, all employees in dept 20 who earn at most 2000

SELECT 
	*
FROM 
	emp
WHERE
	deptno = 10 OR comm IS NOT NULL	OR sal <= 2000 AND deptno = 20

--You can use a combination of AND, OR, and parentheses () to return rows that satisfy multiple conditions.
--The presence of parentheses causes conditions within them to be evaluated together. 

SELECT 
	*
FROM 
	emp
WHERE
	(
	deptno = 10	OR comm IS NOT NULL	OR sal <= 2000
	) AND deptno = 20

--4
--You want to see values for specific columns rather than for all of the columns, you merely specifiy the columns you're interested in.
--Let's look at only name, department number, and salary for employees:

SELECT
	ename,
	deptno,
	sal
FROM 
	emp

--By specifiying the columns in the SELECT clause you ensure no extraneous data is returned.
--This is especially important when retrieving data across a network, as it avoids the waste of time inherent in retrieving data you do not need.

--5
--You would like to change the names of the columns that are returned by your query so they as more readable and understandable.
--Do this by using the AS keyword.

SELECT
	sal AS Salary,
	comm AS Commission
FROM 
	emp

--This is known as aliasing the columns. Creating good aliases goes a long way towards making queries and their results understandable to others.

--6
--You can reference aliased columns by wrapping your query as an inline view.

SELECT 
	*
FROM 
	(
	SELECT
		sal AS Salary,
		comm AS Commission
	FROM 
		emp
) x
WHERE 
	Salary < 5000

--This solution introduces you to what you would need to do when attempting to reference the following in a WHERE clause:
--Aggregate functions, Scalar subqueries, Windowing functions, Aliases.
--Placing your query, the one giving aliases, in an inline view gives you the ability to reference the aliased columns in your outer query.
--The WHERE causes is evaluated before the SELECT, thus Salary and Commission do not yet exist when the "Problem" query's WHERE clause is evaluated.
--Those aliases are not applied until after the WHERE clause processing is complete. However, the FROM clause is evaluated before the WHERE.
--By placing the original query in a FROM clause, the results from that query are generated before the outermost WHERE clause, and your outermost WHERE clause sees the alias names.
--This is useful when the columns in a table are not named particularly well.

--7
--you want to return values in multiple columns as one column by using the concatenate function.

SELECT 
	CONCAT(ename, ' WORKS AS A ', job) AS msg
FROM 
	emp
WHERE 
	deptno = 10


SELECT
	ename + ' WORKS AS A ' + job AS msg
FROM
	emp
WHERE 
	deptno = 10

--You can use CONCAT() or the + symbol as a shortcut in SQL Server

--8
--You want to perform IF-ELSE operations on values in your select statement.
--For example, you would like to produce a result set such that if an employee is paid $2000 or less, a message of "UNDERPAID" is returned; if an employee is paid $4000 or more, a message of "OVERPAID" is returned.
--If they make somewhere in between then "OK" is returned.
--Use the CASE expression to perform conditional logic directly in your SELECT statement

SELECT
	ename,
	sal,
	CASE 
		WHEN sal <= 2000 THEN 'UNDERPAID'
		WHEN sal >= 4000 THEN 'OVERPAID'
		ELSE 'OK'
	END AS [status]
FROM
	emp

--The CASE expression allows you to perform condition logic on values returned by a query.
--You can provide an alias for a CASE exxpression to return a more readable result set.
--In the above solution, the alias of status given to the result of the CASE expression.
-- The ELSE clause is option, by omitting the ELSE the CASE expression will instead return NULL for any row not satisfying the test condition.

--9
--You want to limit the number of rows returned in your query. 
--You are not concerned with order, any n rows will do.
--SQL server uses the TOP keyword to restrict the number of rows returned.

SELECT
	TOP 5 *
FROM
	emp

--10
--You want to return a specific number of random records.
--SQL server has a function NEWID, used along with TOP and ORDER BY we can return a random result set.

SELECT
	TOP 5
	ename,
	job
FROM
	emp
ORDER BY
	newid()

--The ORDER BY clause can accept a function's return value and use it to change the order of the result set.
--This solution restricts the number of rows to return after the function in the ORDER BY clause is executed.
--It is important that you don't confuse using a function in the ORDER BY clause with using a numeric constant.
--When specifying a numeric constant in the ORDER BY clause, you are requesting that the sort be done according to the column in that ordinal position in the SELECT list.
--When you specify a function in the ORDER BY clause, the sort is performed on the result from the function as it is evaluated for each row.

--11
--To determine when a value is null, you must use IS NULL

SELECT
	*
FROM
	emp
WHERE
	comm IS NULL

--Null is never equal to anything, not even itself, therefore you cannot use = or != for testing whether a column is NULL.
--To determine whether a row had NULL values you must use IS NULL. You can also use IS NOT NULL to find rows without a null in a given column.

--12
--You can use the COALESCE function to substitute real values for nulls:

SELECT
	COALESCE(comm,0)
FROM
	emp

--The COALESCE function takes one or more values as arguments. 
--The function returns the first non-null value in the list. In the above, the value of comm is returned whenever comm is NOT null, otherwise a zero is returned.
--You can also use CASE to translate nulls into values, however it is much easier and more succint to use COALESCE:

SELECT
	CASE
		WHEN comm IS NOT NULL
		THEN comm
		ELSE 0
	END 
	AS comm
FROM
	emp

--13
--You want to return rows that match a particular substring or pattern.
--Of the employees in departments 10 and 20, you want to return only those that have either an "I" somewhere in their name or a job title ending with "ER"
--Use the LIKE operator in conjunction with the SQL wildcard operator (%)

SELECT
	ename,
	job
FROM
	emp
WHERE
	deptno IN (10,20)
	AND (ename LIKE '%i%'
	OR job LIKE '%er')

--When used in a LIKE pattern-match operation, the percent operator matches any sequence of characters.
--By enclosing the search pattern "i" with % operators, any string that contains an "i" (at any position) will be returned.
--If you do not enclose the search pattern with %, then where you place the operator will affect the results of the query.
--For example, by prefixing the % to "er" we find values that END in "er". If we were to add the % after the "er" then we find values that start with "er"

--Information retrieval is the core of database querying.