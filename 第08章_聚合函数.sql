-- 第08章_聚合函数
-- 1.常见的几个聚合函数
-- 1.1 AVG / SUM
SELECT
	avg(salary),
	sum(salary),
	avg(salary)* 107
FROM
	employees;
-- 如下操作没有意义
SELECT
	sum(last_name),
	avg(last_name),
	sum(hire_date)
FROM
	employees;

-- 1.2 MAX / MIN：适用于数值类型、字符串类型、日期时间类型的字段（或变量）
SELECT
	max(salary),
	min(salary)
FROM
	employees;

SELECT
	max(salary),
	min(last_name),
	max(hire_date),
	min(hire_date)
FROM
	employees;

-- 1.3 COUNT
-- ①作用：计算指定字段在查询结果中出现的个数
SELECT
	count(employee_id),
	count(salary),
	count(2 * salary),
	count(1)
FROM
	employees;

-- 如果计算表中有多少条记录，如何实现？
-- 方式1：COUNT(*)
-- 方式2：COUNT(1)
-- 方式3：COUNT(具体字段)：不一定对！
-- ②注意：计算指定字段出现的个数时，不一定对！
SELECT
	count(commission_pct)
FROM
	employees;

-- ③ AVG = SUM / COUNT
SELECT
	avg(salary),
	sum(salary) / count(salary),
	sum(commission_pct) / count(commission_pct),
	sum(commission_pct) / 107
FROM
	employees;

-- 需求：查询公司中平均奖金率
-- 错误的！
SELECT
	avg(commission_pct)
FROM
	employees;

-- 正确的：
SELECT
	sum(commission_pct)/ count(ifnull(commission_pct, 0))
FROM
	employees;

-- 如果需要统计表中的记录数，使用COUNT(*)、COUNT(1)、COUNT(具体字段)哪个效率更高呢？
-- 如果使用的是MyISAM存储引擎，则三者效率相同，都是O(1)
-- 如果使用的是InnoDB存储引擎，则三者效率：COUNT(*)=COUNT(1)>COUNT(字段)

-- 其他：方差、标准差、中位数

-- 2.GROUP BY的使用
-- 需求：查询各个部门的平均工资，最高工资
SELECT
	department_id,
	avg(salary),
	sum(salary)
FROM
	employees
GROUP BY
	department_id;

-- 需求查询各个job_id平均工资
SELECT
	job_id,
	avg(salary)
FROM
	employees
GROUP BY
	job_id;

-- 需求：查询各个department,job_id的平均工资
-- 方式1：
SELECT
	department_id,
	job_id,
	avg(salary)
FROM
	employees
GROUP BY
	department_id,
	job_id;
-- 方式2：
SELECT
	department_id,
	job_id,
	avg(salary)
FROM
	employees
GROUP BY
	job_id,
	department_id;

SELECT
	department_id,
	job_id,
	avg(salary)
FROM
	employees;

-- 结论1：SELECT中出现的非组函数的字段必须声明在GROUP BY中。
-- 		反之，GROUP BY中声明的字段可以不出现在SELECT中

-- 结论2：GROUP BY声明在FROM后面，WHERE后面，ORDER BY前面、LIMIT前面
-- 结论3：MYSQL中GROUP BY中使用WITH ROLLUP
SELECT
	department_id,
	avg(salary)
FROM
	employees
GROUP BY
	department_id WITH ROLLUP;

-- 需求：查询各个部门的平均工资，按照平均工资升序排列
SELECT
	department_id,
	avg(salary) avg_sal
FROM
	employees
GROUP BY
	department_id
ORDER BY
	avg_sal ASC;

-- 说明当使用ROLLUO时，不能同时使用ORDER BY子句进行结果排序，即ROLLUP和ORDER BY是相互排斥的

-- 3.HAVING的使用（作用：用来过滤数据的）
-- 练习：查询各个部门中最高工资比10000高的部门信息
-- 错误的写法：
SELECT
	department_id,
	max(salary)
FROM
	employees
WHERE
	max(salary) > 10000;
GROUP BY department_id;

-- 要求1：如果过滤条件使用了聚合函数，则必须使用HAVING来替换WHERE。否则，报错。
-- 要求2：HAVING必须声明在GROUP BY的后面。
-- 正确的写法：
SELECT
	department_id,
	max(salary)
FROM
	employees
GROUP BY
	department_id
HAVING
	max(salary) >10000;

-- 要求3：开发中，我们使用HAVING的前提是SQL中使用了GROUP BY。

-- 练习：查询部门id为10，20，30，40这4个部门中最高工资比10000高的部门信息
-- 方式1
SELECT
	department_id,
	max(salary)
FROM
	employees
WHERE
	department_id IN (10, 20, 30, 40)
GROUP BY
	department_id
HAVING
	max(salary) > 10000;

-- 方式2
SELECT
	department_id,
	max(salary)
FROM
	employees
GROUP BY
	department_id
HAVING
	max(salary) > 10000
	AND department_id IN (10, 20, 30, 40);

-- 结论：当过滤条件中有聚合函数时，则此过滤条件必须声明在HAVING中。
--     当过滤条件中没有聚合函数时，则此过滤条件声明在WHERE中或HAVING中都可以。但是，建议大家声明在WHERE中

/*
	WHERE与HAVING对比
1.从适用范围上来讲，HAVING的适用范围更广
2.如果过滤条件中没有聚合函数：这种情况下，WHERE的执行效率要高于HAVING
*/

-- 4.SQL底层执行原理
-- 4.1 SELECT语句的完整结构

/*
-- sql92语法：
SELECT ...., ...., ....(存在聚合函数)
FROM ...., ...., ....
WHERE 多表连接条件 AND不包含聚合函数的过滤条件
GROUP BY ...., ...
HAVING 包含聚合函数的过滤条件
ORDER BY ...., ...(ASC/DESC)
LIMIT ..., ...

-- sql99语法：
SELECT ...., ...., ....(存在聚合函数)
FROM .... (LEFT/RIGHT)JOIN ....ON 多表的连接条件
WHERE 不包含聚合函数的过滤条件
GROUP BY ...., ...
HAVING 包含聚合函数的过滤条件
ORDER BY ...., ...(ASC/DESC)
LIMIT ..., ...
*/

-- 4.2 SQL底层的执行原理
-- FROM ...,... -> ON -> (LEFT/RIGHT JOIN) -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT -> ORDER BY -> LIMIT

-- 第08章_聚合函数的课后练习
-- 1.where子句可否使用组函数进行过滤? NO!

-- 2.查询公司员工工资的最大值，最小值，平均值，总和
SELECT
	max(salary) 'max_sal',
	min(salary) 'min_sal',
	avg(salary) avg_sal,
	sum(salary) sum_sal
FROM
	employees;

-- 3.查询各job_id的员工工资的最大值，最小值，平均值，总和
SELECT
	job_id,
	max(salary),
	min(salary),
	avg(salary),
	sum(salary)
FROM
	employees
GROUP BY
	job_id;
	
-- 4.选择具有各个job_id的员工人数
SELECT
	job_id,
	count(*)
FROM
	employees
GROUP BY
	job_id;

# 5.查询员工最高工资和最低工资的差距（DIFFERENCE）
SELECT
	max(salary) - min(salary) 'DIFFERENCE'
FROM
	employees;
	
# 6.查询各个管理者手下员工的最低工资，其中最低工资不能低于6000，没有管理者的员工不计算在内
SELECT
	manager_id,
	min(salary)
FROM
	employees
WHERE
	manager_id IS NOT NULL
GROUP BY
	manager_id
HAVING
	min(salary) >= 6000;
	
# 7.查询所有部门的名字，location_id，员工数量和平均工资，并按平均工资降序
SELECT
	d.department_name,
	d.location_id,
	count(e.employee_id),
	avg(e.salary)
FROM
	departments d
LEFT JOIN employees e ON
	e.department_id = d.department_id
JOIN locations l ON
	d.location_id = l.location_id
GROUP BY
	department_name,
	location_id
ORDER BY
	avg(e.salary) DESC;
	
# 8.查询每个工种、每个部门的部门名、工种名和最低工资
SELECT
	d.department_name,
	e.job_id,
	min(e.salary)
FROM
	departments d
LEFT JOIN employees e ON
	e.department_id = d.department_id
GROUP BY
	d.department_name,
	e.job_id;