--Sorting Query Results to provide more readable and meaningful data

DROP TABLE IF EXISTS dept
CREATE TABLE dept
	(deptno int, dname varchar(255), loc varchar(255))
INSERT INTO dept
	(deptno, dname, loc)
VALUES
	('10','ACCOUNTING','NEW YORK'),
	('20','RESEARCH','DALLAS'),
	('30','SALES','CHICAGO'),
	('40','OPERATIONS','BOSTON')

DROP TABLE IF EXISTS emp
CREATE TABLE emp
	(empno INT, ename varchar(255), job varchar(255), mgr INT, hiredate date, sal INT, comm INT, deptno INT) 
INSERT INTO emp
	(empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES
	('7369','SMITH','CLERK','7902','12-17-2005','800','0','20'),
	('7499','ALLEN','SALESMAN','7698','2-20-2006','1600','300','30'),
	('7521','WARD','SALESMAN','7698','2-22-2006','1250','500','30'),
	('7566','JONES','MANAGER','7839','4-2-2006','2975','0','20'),
	('7654','MARTIN','SALESMAN','7698','9-29-2006','1250','1400','30'),
	('7698','BLAKE','MANAGER','7839','5-1-2006','2850','0','30'),
	('7782','CLARK','MANAGER','7839','6-9-2006','2450','0','10'),
	('7788','SCOTT','ANALYST','7566','12-9-2007','3000','0','20'),
	('7839','KING','PRESIDENT','0','11-17-2006','5000','0','10'),
	('7844','TURNER','SALESMAN','7698','9-8-2006','1500','0','30'),
	('7876','ADAMS','CLERK','7788','1-12-2008','1100','0','20'),
	('7900','JAMES','CLERK','7698','12-3-2006','950','0','30'),
	('7902','FORD','ANALYST','7566','12-3-2006','3000','0','20'),
	('7934','MILLER','CLERK','7782','1-23-2007','1300','0','10')

--1 - Returning Query Results in a specified order
--Display names, jobs, and salaries of employees in dept 10 in order based on their salary (from lowest to highest).
--Use the ORDER BY clause

SELECT
	ename,
	job,
	sal
FROM
	emp
WHERE
	deptno = 10
ORDER BY
	sal ASC

--The ORDER BY clause allows you to order the rows of your result set. The solution sorts the rows based on sal in ascending order.
--By default, ORDER BY will sort in ascending order, and the ASC clause is optional, use DESC to sort in descending order:

SELECT
	ename,
	job,
	sal
FROM
	emp
WHERE
	deptno = 10
ORDER BY
	sal DESC

--You can specify a column by number as well as name, though it is always better to be explicit so that code is readable. We write code for humans first and machines second.

--2 - Sorting by Multiple Fields
--You want to sort the rows from emp first by deptno ascending, then by salary descending.
--You do this by listing different sort columns in the ORDER BY clause, separated by commas.

SELECT
	empno,
	deptno,
	sal,
	ename,
	job
FROM
	emp
ORDER BY
	deptno,
	sal DESC

--The order of precedence in ORDER BY is left to right. If you are ordering using the numeric position of a column in the SELECT list, then that number must not be greater than the number of items in the SELECT list.
--You are generally permitted to order by a column not in the SELECT list, but to do so you must explicitly name the column.
--However, if you are using GROUP BY or DISTINCT in your query, you cannot order by columns that are not in the SELECT list.

--3 - Sorting by Substrings
--You want to sort the results of a query by specific parts of a string.
--Return employee names and jobs from table emp and sort by the last two characters in the job field. Do this using the SUBSTRING function combined with the LEN function.

SELECT
	ename,
	job
FROM
	emp
ORDER BY
	SUBSTRING(job,LEN(job)-1,2)

--To sort by the last two characters of a string, find the end of the string (which is the length of the string) and subtract one. The start position will be the second to last character in the string. 
--SQL Server's SUBSTRING function requires a third parameter to specify how many characters to take.

--4 - Sorting Mixed Alphanumeric Data
--You have mixed alphanumeric data and want to sort by either the numeric or character portion of the data.
--First we'll create the following View:

CREATE VIEW V
AS
	SELECT
		CONCAT(ename, ' ', deptno) AS [data]
	FROM
		emp

SELECT
	*
FROM
	V

--You can use the functions REPLACE and TRANSLATE to modify the string for sorting.
--Order by Deptno
SELECT
	[data]
FROM
	V
ORDER BY
	REPLACE([data],
	REPLACE(
	TRANSLATE([data],'0123456789','##########'),'#',''),'')

--Order by ename
SELECT
	[data]
FROM
	V
ORDER BY
	REPLACE(
	TRANSLATE([data],'0123456789','##########'),'#','')

--The TRANSLATE and REPLACE functions remove either the numbers or characters from each row, allowing you to easily sort by one or the other.

--5 - Dealing with Nulls when sorting
--You want to sort results from emp by comm, but the field is nullable, you need a way to specify whether nulls sort first:
SELECT
	ename,
	sal,
	comm
FROM
	emp
ORDER BY
	comm
--or last:
SELECT
	ename,
	sal,
	comm
FROM
	emp
ORDER BY 
	comm DESC

--If instead you would like to sort NULL values different than non-NULL values you can use the CASE expression to flag when a value is NULL.
--Non-NULL comm sorted ascending, all NULLS last
SELECT
	ename,
	sal,
	comm
FROM 
	(
	SELECT
		ename,
		sal,
		comm,
		CASE WHEN comm IS NULL THEN 0 ELSE 1 
END AS IS_NULL
FROM
	emp
) X
ORDER BY
	IS_NULL DESC,
	comm
--Non-NULL comm sorted descending, all NULLS last
SELECT
	ename,
	sal,
	comm
FROM
	(
	SELECT
		ename,
		sal,
		comm,
		CASE WHEN comm IS NULL then 0 ELSE 1
END AS IS_NULL
FROM
	emp
) X
ORDER BY
	IS_NULL DESC,
	comm DESC
--non-NULL sorted ascending, all NULLS first
SELECT
	ename,
	sal,
	comm
FROM
	(
	SELECT
		ename,
		sal,
		comm,
		CASE WHEN comm IS NULL then 0 ELSE 1
END AS IS_NULL
FROM
	emp
) X
ORDER BY
	IS_NULL,
	comm
--Non-NULL com sorted descending, all NULLS first
SELECT
	ename,
	sal,
	comm
FROM
	(
	SELECT
		ename,
		sal,
		comm,
		CASE WHEN comm IS NULL then 0 ELSE 1
END AS IS_NULL
FROM
	emp
) X
ORDER BY
	IS_NULL,
	comm DESC

--6 - Sorting on a Data-dependent key
--You want to sort based on some conditional logic. For example, if job is salesman, you want to sort on comm; otherwise, you want to sort  by sal.
--You scan use the CASE expression to dynamically change how results are sorted.
SELECT
	ename,
	sal,
	job,
	comm
FROM
	emp
ORDER BY
	CASE WHEN job = 'SALESMAN' THEN comm ELSE sal END

SELECT
	ename,
	sal,
	job,
	comm,
	CASE WHEN job = 'SALESMAN' THEN comm ELSE sal END AS ordered
FROM
	emp
ORDER BY
	ordered

--Sorting query results is one of the core skills for all users of SQL. 
