--Working with multiple tables using joins and set operations.

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

--1 - Stacking one rowset on top of another
--You want to return data stored in more than one table, conceptually stacking one result on top of the other. The tables do not necessarily have a common key, but their columns do have the same data types.
--For Example, you want to display the name and department number of the employees in department 10 in table emp along with the name and number of each department in table dept.
--Use the set operation UNION ALL to combine rows from multiple tables.

SELECT
	ename AS ename_and_dname,
	deptno
FROM
	emp
WHERE
	deptno = 10

UNION ALL
SELECT
	dname,
	deptno
FROM
	dept

--UNION ALL combines rows from multiple row sources into one result set. As with all set operations, the items in all the SELECT lists must match in number and data type..
--It's important to note, UNION ALL will include duplicates if they exist. If you want to filter out duplicates, use the UNION operator. 
--For example, a UNION between emp.deptno and dept.deptno returns only four rows:
SELECT
	deptno
FROM
	emp
UNION
SELECT
	deptno
FROM
	dept
--Specifying UNION rather than UNION ALL iwll most likely result in a sort operation to eliminate duplicates. Keep this in mind when working with large result sets.

--2 - Combining Related Rows
--You want to return rows from multiple tables by joining on a known common column or joining on columns that share common values.
--For example, you want to display the names of all employees in department 10 along with the location of each employee's department, but that data is stored in two separate tables.
SELECT
	e.ename,
	d.loc
FROM
	emp e,
	dept d
WHERE
	e.deptno = d.deptno
	AND e.deptno = 10

--The solution is an example of a join, or more accurately an equi-join which is a type of inner join.
--A join is an operation that combines rows from two tables into one. An equi-join is one in which the join condition is based on an equality condition. (Where on department number equals another.)
--An inner join is the original type of join, each row returned contains data from each table.
--Conceptually, the result set from a join is produced by first creating all possible combinations of rows from the tables listed in the FROM clause, shown here:
SELECT
	e.ename,
	d.loc,
	e.deptno AS emp_deptno,
	d.deptno AS dept_deptno
FROM
	emp e,
	dept d
WHERE
	e.deptno = 10
--every employee in table emp, in department 10, is returned along with every department in table dept. Then, the expression in the WHERE clause involving the join restricts the result set such that the only rows returned are the ones where deptno is equal in both tables.
SELECT
	e.ename,
	d.loc,
	e.deptno AS emp_deptno,
	d.deptno AS dept_deptno
FROM
	emp e,
	dept d
WHERE
	e.deptno = d.deptno	
	AND e.deptno = 10
--An alternative solution would be to make use of an explicit JOIN clause, the INNER keyword is optional in this case.
SELECT
	e.ename,
	d.loc
FROM
	emp e INNER JOIN dept d
	ON (e.deptno = d.deptno)
WHERE
	e.deptno = 10
--Use the JOIN clause if you prefer to have the join logic in the FROM clause rather than the WHERE clause.

--3 - Finding rows in common between two tables.
--You want to find common rows between two tables, but there are multiple columns on which you can join. 
--Let's first create a new view:
CREATE VIEW V
AS
SELECT
	ename,
	job,
	sal
FROM
	emp
WHERE
	job = 'CLERK'
SELECT 
	*
FROM
	V
--Only clerks are returned from this new view. However, the view does notshow all possible emp columns. Let's also return the empno, ename, job, sal, and deptno of all employees in emp that match the rows from this view.
--Join the tables by using multiple join conditions:
SELECT
	e.empno,
	e.ename,
	e.job,
	e.sal,
	e.deptno
FROM
	emp e, V
WHERE
	e.ename = v.ename
	AND e.job = v.job
	AND e.sal = v.sal
--Alternatively you can perform the same join via the JOIN clause:
SELECT
    e.empno,
    e.ename,
    e.job,
    e.sal,
    e.deptno
FROM
    emp e
JOIN V ON (
	e.ename = v.ename 
	AND e.job = v.job 
	AND e.sal = v.sal
    )
--When performing joins, you must consider the proper columns to join in order to return correct results. This is especially important when rows can have common values for some columns while having different values for others.
--the set operation INTERSECT will return rows common to both row sources. When using INTERSECT, you are required to compare the same number of items having the same data type, from two tables.
--When working with set operations, keep in mind that, by default, duplicate rows will not be returned.

--4 - Retrieving values from one table that do not exist in another
--You want to find those values in one table, we'll refer to it as the source table, that do not exist in some target table.
--For example, you want to find which department, if any, in table dept does not exist in table emp. In the example data, deptno 40 from table dept does not exist in table emp.
--Having functions that perform set difference is useful for this problem, the set operation EXCEPT
SELECT
	deptno 
FROM
	dept
EXCEPT
SELECT
	deptno
FROM
	emp
--Set difference functions make this operation easy, the EXCEPT operator takes the first result set and removes from it all rows found in the second result set. This operation is very much like a subtraction.
--There are restrictions on the use of set operators, including EXCEPT. Data types and number of values to compare must match in both SELECT lists.
--Additionally, EXCEPT will not return duplicates, and unlike a subquery using NOT IN, NULLS do not present a problem.
--The EXCEPT operator will return rolls from the upper query (before EXCEPT) that do not exist in the lower query (after EXCEPT)

--5 - Retrieving rows from one table that do NOT correspond to rows in another.
--You want to find rows that are in one table that do not have a match in another table, for two tables that have common keys.
--For example, you want to find which departments have no employees.
--Finding the department each employee works in requires an equi-join on deptno from emp to dept. The deptno column represents the common value between tables.
--Unfortunately, an equijoin will not show you which department has no employees - that is because by equijoining emp and dept you are returning all rows that satisfy the join condition. Instead, you want only those rows from dept that do NOT satisfy the join condition.
--This is a subtly different problem than in the preceding query, though at first glance they may seem similar.
--Use an out join and filter for NULLS - keyword OUTER is optional here.
SELECT
    d.*
FROM
    dept d
LEFT OUTER JOIN emp e ON
    (d.deptno = e.deptno)
WHERE
    e.deptno IS NULL
--This solution works by outer joining and then keeping only rows that have no match. This sort of operation is sometimes called an anti-join. 
--To get a better idea of how anti-join works, let's examine the result without filtering for NULLs:
SELECT
	e.ename,
	e.deptno AS emp_deptno,
	d.*
FROM
	dept d
LEFT OUTER JOIN emp e ON
	(d.deptno = e.deptno)
--The last row will return a NULL value for emp.ename and emp.deptno - that is because no employees work in department 40.
--The solution uses the WHERE clause to keep only the rows where emp.deptno is null - this way we only keep rows from dept that have no match in emp

--6 - Adding joins to a query without interfering with other joins
--You have a query that returns the results you want. You need additional info, but when trying to get it you lose data.
--For example: you want to return all employees, the location of the dept in which they work, and the date they received a bonus. 
--Let's first add a new table:
DROP TABLE IF EXISTS EMP_BONUS
CREATE TABLE EMP_BONUS
	(EMPNO numeric,
	RECEIVED datetime,
	[TYPE] numeric)
INSERT INTO EMP_BONUS
	(EMPNO,
	RECEIVED,
	[TYPE])
VALUES
	('7369',
	'3-14-2005',
	'1'),
	('7900',
	'3-14-2005',
	'2'),
	('7788',
	'3-14-2005',
	'3')
SELECT * FROM EMP_BONUS
--Great - now we start with this query:
SELECT
	e.ename,
	d.loc
FROM
	emp e,
	dept d
WHERE e.deptno = d.deptno
--You want to add to these results the date a bonus was given to an employee, but joining to the emp_bonus table returns fewer rows than you want, because not every employee has a bonus.
SELECT
	e.ename,
	d.loc,
	eb.received
FROM
	emp e,
	dept d,
	emp_bonus eb
WHERE
	e.deptno = d.deptno
	AND e.empno = eb.empno
--This only returns the three employee numbers who earneda  bonus.
--Instead, we can use an outer join to obtain the additional info without losing any data from the original query.
--First join table emp to table dept to get all employees and the location of the department they work then outer join to table emp_bonus to return the date of the bonus if there is one.
SELECT
    e.ename,
    d.loc,
    eb.received
FROM
    emp e
JOIN dept d ON
    (e.deptno = d.deptno)
LEFT JOIN emp_bonus eb ON
    (e.empno = eb.empno)
ORDER BY
    loc
--You can also use a scalar subquery to mimic an outer join. (This is a subquery placed in the SELECT list)
SELECT
	e.ename,
	d.loc,
	(SELECT
		eb.received
	FROM
		emp_bonus eb
	WHERE
		eb.empno = e.empno) AS RECEIVED
FROM
	emp e,
	dept d
WHERE 
	e.deptno = d.deptno
ORDER BY 
	loc
--An OUTER JOIN will return all rows from one table and matching rows from another. See the previous query for another example of such a join.
--The reason an outer join works to solve this problem is that it does not result in any rows being eliminated that would otherwise be returned. The query will return all the rows it would return without the outer join, it also returns the received date (if it exists)
--Use of a scalar subquery is also a convenient technique for this sort of problem, as it does not require you to modify already correct joins in your main query.
--Using a scalar subquery is an easy way to tack on extra data to a query without compromising the current result set. 
--When working with scalar subqueries, you must ensure they return a single value, if a subquery in the SELECT list returns more than one row, you will receive an error.

--7 - Determining whether two tables have the same data.
--You want to know whether two tables or views have the same data, cardinality and values.
--Let's create a new view for this:
CREATE VIEW V
AS
SELECT
	*
FROM 
	emp
WHERE
	deptno != 10
UNION ALL
SELECT
	*
FROM
	emp
WHERE
	ename = 'WARD'

SELECT * FROM V

--You want to determine whether this view has exactly the same data as table emp. The row for employee ward is duplicated to show that the solution will reveal not only different data, but also duplicates.
--based on the rows in table emp, the different will be the three rows for employees in department 10 and the two rows for employee WARD:
--Functions that perform SET difference EXCEPT make the problem of comparing tables a relatively easy one to solve:
--Buckle up! Let's use a correlated subquery and UNION ALL to find the rows in View V and not in table emp combined with the rows in table emp and not in view V.
--Still with me??
SELECT
    *
FROM
    (
    SELECT
        e.empno,
        e.ename,
        e.job,
        e.mgr,
        e.hiredate,
        e.sal,
        e.comm,
        e.deptno,
        COUNT(*) AS cnt
    FROM
        emp e
    GROUP BY
        empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno
) e
WHERE NOT
    EXISTS(
    SELECT NULL
FROM
    (
    SELECT
        v.empno,
        v.ename,
        v.job,
        v.mgr,
        v.hiredate,
        v.sal,
        v.comm,
        v.deptno,
        COUNT(*) AS CNT
    FROM
        v
    GROUP BY
        empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno
) v
WHERE
    v.empno = e.empno AND v.ename = e.ename AND v.job = e.job AND COALESCE(v.mgr, 0) = COALESCE(e.mgr, 0) AND v.hiredate = e.hiredate AND v.sal = e.sal AND v.deptno = e.deptno AND v.cnt = e.cnt AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
)
UNION ALL
SELECT
    *
FROM
    (
    SELECT
        v.empno,
        v.ename,
        v.job,
        v.mgr,
        v.hiredate,
        v.sal,
        v.comm,
        v.deptno,
        COUNT(*) AS cnt
    FROM
        v
    GROUP BY
        empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno
) v
WHERE NOT
    EXISTS(
    SELECT NULL
FROM
    (
    SELECT
        e.empno,
        e.ename,
        e.job,
        e.mgr,
        e.hiredate,
        e.sal,
        e.comm,
        e.deptno,
        COUNT(*) AS cnt
    FROM
        emp e
    GROUP BY
        empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno
) e
WHERE
    v.empno = e.empno AND v.ename = e.ename AND v.job = e.job AND COALESCE(v.mgr, 0) = COALESCE(e.mgr, 0) AND v.hiredate = e.hiredate AND v.sal = e.sal AND v.deptno = e.deptno AND v.cnt = e.cnt AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
)

--8 - Identifying and avoiding cartesian products
--You want to return the name of each employee in dept 10 along with the location of the department, the following query is returning incorrect data:
SELECT
	e.ename,
	d.loc
FROM
	emp e,
	dept d
WHERE 
	e.deptno = 10
--Instead, use a join between the tables in the FROM clause to return the correct result set:
SELECT
	e.ename,
	d.loc
FROM
	emp e,
	dept d
WHERE 
	e.deptno = 10
	AND d.deptno = e.deptno
--To understand why, let's look at the data in the dept table:
SELECT * FROM dept
--You can see that dept 10 is in New York, thus you can know that returning employees with any location outside of new york is incorrect.
--The number of rows returned by the incorrect query is the product of the cardinalities of the two tables in the FROM clause.
--In the original query, the filter on emp for dept 10 will result in three rows, because there is no filter for dept, all four rows from dept are returned.
--three multipled by four is twelve, so the incorrect query returns twelve rows. 
--Generally, to avoid a cartesian product, you would apply the n-1 rule where n represents the number of tables in the FROM clause and n-1 represents the minimum number of JOINS necessary to avoid a cartesian product.
--Depending on what the keys and join columns in your tables are, you may very well need more than n-1 joins, but n-1 is a good place to start.

select * FROM emp e
LEFT JOIN V on e.empno = V.empno
WHERE V.empno is null

--9 - performing joins when using aggregates.
--You want to perform an aggregation, but your query involves multiple tables.
--You want to ensure that joints do not disrupt the aggregation, for example:
--You want to find the sum of the salaries for employees in dept 10 along with the sum of their bonuses. 
--some employees have more than one bonus, and the join between table emp and emp_bonus is causing incorrect values to be returned by the aggregate function sum.
DROP TABLE IF EXISTS EMP_BONUS
CREATE TABLE emp_bonus
	(empno varchar(255), 
	received datetime, 
	[type] int)
INSERT INTO emp_bonus
	(empno, 
	received, 
	[type])
VALUES 
	('7934','3-17-2005','1'), 
	('7934','2-15-2005','2'), 
	('7839','2-15-2005','3'), 
	('7782','2-15-2005','1')

SELECT	* FROM emp_bonus
--Now, consider the following query that returns salary & bonus for all employees in dept 10.
--Table bonus.type determines the amount of the bonus, a type 1 is 10%, type 2 20% and type 3 30%
SELECT
	e.empno,
	e.ename,
	e.sal,
	e.deptno,
	e.sal * CASE 
				WHEN eb.[type] = 1 THEN .1
				WHEN eb.[type] = 2 THEN .2
				ELSE .3
			END AS bonus
FROM
	emp e,
	emp_bonus eb
WHERE
	e.empno = eb.empno
	AND e.deptno = 10
--Things go awry when you attemp a join to the emp_bonus table to sum the bonus amounts:
SELECT
	deptno,
	SUM(sal) AS total_sal,
	SUM(bonus) AS total_bonus
FROM (
	SELECT
	e.empno,
	e.ename,
	e.sal,
	e.deptno,
	e.sal * CASE 
				WHEN eb.[type] = 1 THEN .1
				WHEN eb.[type] = 2 THEN .2
				ELSE .3
			END AS bonus
	FROM
		emp e,
		emp_bonus eb
	WHERE
		e.empno = eb.empno
		AND e.deptno = 10
		) x
GROUP BY deptno
--The total bonus is correct, but the total sal is incorrect. The sum of all salaries in dept 10 is 8750, as the following query shows:
SELECT SUM(sal) FROM emp WHERE deptno = 10
--Why is total sal incorrect? the reason is the duplicate rows in the sal column created by the join.
--You have to be careful when computing aggregates across joins. Typically when duplicates are returned due to a join, you can avoid miscalculations by aggregate functions in two ways:
--You can simply use the keyword DISTINCT in the call to the aggregate function, so only unique instances of each value are used in the computation OR
--you can perform the aggregation first in an inline view prior to joining and in this way avoid the incorrect computation by the aggregate function since the aggregate will be computed before the join.
--The following solution uses the DISTINCT keyword:

SELECT 
	deptno,
	SUM(DISTINCT sal) AS total_sal,
	SUM(bonus) AS total_bonus
FROM (
	SELECT
		e.empno,
		e.ename,
		e.sal,
		e.deptno,
		e.sal * CASE
					WHEN eb.[type] = 1 THEN .1
					WHEN eb.[type] = 2 THEN .2
					ELSE .3
				END AS bonus
	FROM
		emp e,
		emp_bonus eb
	WHERE
		e.empno = eb.empno
		AND e.deptno = 10
		) x
GROUP BY deptno

--10 - Performing outer joins when using aggregates
--First, let's modify the emp_bonus table:
DROP TABLE IF EXISTS emp_bonus
CREATE TABLE emp_bonus
	(empno varchar(255), 
	received datetime, 
	[type] int)
INSERT INTO emp_bonus
	(empno, 
	received, 
	[type])
VALUES 
	('7934','3-17-2005','1'), 
	('7934','2-15-2005','2')
--Let's write a query to find both the sum of all salaries for dept 10 and the sum of all bonuses for all employees in dept 10:
--We will outer join to emp_bonus, then perform the sum on only distinct salaries from dept 10:
SELECT
	deptno,
	SUM(DISTINCT sal) AS total_sal,
	SUM(bonus) AS total_bonus
FROM (
	SELECT
		e.empno,
		e.ename,
		e.sal,
		e.deptno,
		e.sal * CASE
					WHEN eb.[type] IS NULL THEN 0
					WHEN eb.[type] = 1 THEN .1
					WHEN eb.[type] = 2 THEN .2
					ELSE .3
				END AS bonus
	FROM
		emp e 
	LEFT OUTER JOIN 
		emp_bonus eb
	ON
		(e.empno = eb.empno)
	WHERE
		e.deptno = 10
		) x
GROUP BY deptno

--The following query is an alternative solution, the sum of all salaries in dept 10 is computed first and then after joined to table emp, which is then joined to emp_bonus.
--This avoids the outer join

SELECT
	d.deptno,
	d.total_sal,
	SUM(e.sal * CASE
					WHEN eb.[type] = 1 THEN .1
					WHEN eb.[type] = 2 THEN .2
					ELSE .3
				END) AS total_bonus
FROM
	emp e,
	emp_bonus eb,
	(
	SELECT
		deptno,
		SUM(sal) AS total_sal
	FROM
		emp
	WHERE
		deptno = 10
	GROUP BY
		deptno
	) d
WHERE 
	e.deptno = d.deptno
	AND e.empno = eb.empno
GROUP BY
	d.deptno,
	d.total_sal

--11 - Returning missing data from multiple tables
--You want to return missing data from multiple tables simultaneously. Returning rows from table dept that do not exist in table emp requires an outer join.
--Consider the following query, which returns all deptnos and dnames from dept along with the names of all the employees in each department (if they exist)
SELECT
	d.deptno,
	d.dname,
	e.ename
FROM
	dept d
FULL OUTER JOIN
	emp e
ON 
	(d.deptno = e.deptno)
ORDER BY
	deptno,
	ename

--the full outer join is the combination of a LEFT OUTER JOIN and a RIGHT OUTER JOIN on both tables.

--12 - Using NULLS in operations and comparisons
--NULL is never equal to or not equal to any value, not even itself. 
--If you want to evaluate values returned by a nullable column like you would evaluate real values you would use a function such as COALESCE to transform the NULL values into real values that can be used:
SELECT
	ename,
	COALESCE(comm,0) AS comm
FROM
	emp


--Joins are a crucial aspect of querying databases. It will be normal going forward that you would need to join two or more tables together to find what you're looking for
--Mastering the different combinations of joins will set you up for success


