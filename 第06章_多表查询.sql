-- 第06章_多表查询

-- 1.熟悉常见的几个表
DESC employees;

DESC departments;

DESC locations;

-- 查询员工名为"Abel"的人在哪个城市工作？
SELECT
	*
FROM
	employees
WHERE
	last_name = 'Abel';

SELECT
	*
FROM
	departments
WHERE
	department_id = 80;
	
SELECT
	*
FROM
	locations
WHERE
	location_id = 2500;
	
-- 2.多表的查询如何实现？
-- 错误的原因：缺少了多表的连接条件
-- 错误的实现方式：每个员工都与每个部门匹配了一遍
SELECT
	employee_id,
	department_name
FROM
	employees,
	departments; -- 查询出2889条记录
	
-- 错误的方式
SELECT
	employee_id,
	department_name
FROM
	employees
CROSS JOIN departments;
	
SELECT
	*
FROM
	employees; -- 107条记录
	
SELECT
	*
FROM
	departments; -- 27条记录
	
SELECT
	107 * 27
FROM
	DUAL;
	
-- 3.多表查询的正确方式：需要有连接条件
SELECT
	employee_id,
	department_name
FROM
	employees,
	departments
	-- 两个表的连接条件
WHERE
	employees.department_id = departments.department_id;
	
-- 4.如果查询语句中出现了多个表中都存在的字段，则必须指明此字段所在的表。
SELECT
	employees.employee_id,
	departments.department_name,
	employees.department_id
FROM
	employees,
	departments
WHERE
	employees.department_id = departments.department_id
	
-- 建议：从sql优化的角度，建议多表查询时，每个字段前都指明其所在的表
	
-- 5. 可以给表起别名，在SELECT和WHERE中使用表的别名.
SELECT
	emp.employee_id,
	dept.department_name,
	emp.department_id
FROM
	employees emp,
	departments dept
WHERE
	emp.department_id = dept.department_id
	
-- 如果给表起了别名，一旦在SELECT或WHERE中使用表名的话，则必须使用表的别名，不能再使用表的原名
-- 如下的操作是错误的：
SELECT
	emp.employee_id,
	dept.department_name,
	emp.department_id
FROM
	employees emp,
	departments dept
WHERE
	emp.department_id = departments.department_id;
	
-- 6.如果有n个表实现多表的查询，则需要n-1个连接条件
-- 练习：查询员工的employee_id,last_name,department_name,city
SELECT
	e.employee_id,
	e.last_name,
	d.department_name,
	l.city,
	e.department_id,
	l.location_id
FROM
	employees e,
	departments d,
	locations l
WHERE
	e.department_id = d.department_id
	AND d.location_id = l.location_id;

/*
演绎式：提出问题1 ---> 解决问题1 ---> 提出问题2 ---> 解决问题2 ....

归纳式：总--分
*/
-- 7.多表查询的分类
/*
角度1：等值连接 vs 非等值连接

角度2：自连接 vs 非自连接

角度3：内连接 vs 外连接
*/

-- 7.1 等值连接 vs 非等值连接
-- 非等值连接的例子：
SELECT
	*
FROM
	job_grades;
	
SELECT
	e.last_name,
	e.salary,
	j.grade_level
FROM
	employees e,
	job_grades j
WHERE
	e.salary >= j.lowest_sal
	AND e.salary <= j.highest_sal;
	
-- 7.2 自连接vs非自连接
SELECT * FROM employees;

-- 练习：查询员工id，员工姓名及其管理者的id和姓名
SELECT
	emp.employee_id,
	emp.last_name,
	mgr.employee_id,
	mgr.last_name
FROM
	employees emp,
	employees mgr
WHERE
	emp.manager_id = mgr.employee_id
	
-- 7.3 内连接 vs 外连接
	
-- 内连接：合并具有同一列的两个以上的表的行，结果集中不包含一个表与另一个表不匹配的行
SELECT
	e.employee_id,
	d.department_name
FROM
	employees e,
	departments d
WHERE
	e.department_id = d.department_id;-- 只有106条数据
	
-- 外连接：合并具有同一列的两个以上的表的行，结果集中除了包含一个表与另一个表匹配的行之外，还查询到了左表或右表中不匹配的行。
-- 外连接的分类：左连接、右连接、满外连接
-- 左外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回左表中不满足条件的行，这种链接成为左外连接
-- 右外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回右表中不满足条件的行，这种链接成为右外连接

-- 练习：查询所有员工的last_name,department_name信息
SELECT
	e.employee_id,
	d.department_name
FROM
	employees e,
	departments d
WHERE
	e.department_id = d.department_id
	
-- SQL92语法实现内连接：见上。略
-- SQL92语法实现外连接：使用 + ------- MYSQL不支持SQL92语法中外连接的写法！
SELECT
	employee_id,
	department_name
FROM
	employees e,
	departments d
WHERE
	e.department_id = d.department_id(+);

-- SQL99语法中使用JOIN..。ON的方式实现多表的查询。这种方式也能解决外连接的问题。MYSQL是支持此种方式的
-- SQL99语法如何实现多表的查询

-- SQL99语法实现内连接
SELECT
	last_name,
	department_name
FROM
	employees e
INNER JOIN departments d ON
	e.department_id = d.department_id;
	
SELECT
	last_name,
	department_name,
	city
FROM
	employees e
INNER JOIN departments d ON
	e.department_id = d.department_id
INNER JOIN locations l ON
	d.location_id = l.location_id;
	
-- SQL99语法实现外连接
-- 练习：查询所有的员工的last_name,department_name信息
-- 左外连接
SELECT
	last_name,
	department_name
FROM
	employees e
LEFT OUTER JOIN departments d ON
	e.department_id = d.department_id;
-- 右外连接
SELECT
	last_name,
	department_name
FROM
	employees e
RIGHT OUTER JOIN departments d ON
	e.department_id = d.department_id;
	
-- 8.UNION和UNION ALL的使用
-- UNION：会执行去重操作
-- UNION ALL：不会执行去重操作
-- 结论：如果明确知道合并数据后的结果数据不存在重复数
-- 则尽量使用UNION ALL语句，以提高数据的查询的效率

-- 9.7种JOIN的实现
-- 中图：内连接
SELECT
	employee_id,
	department_name
FROM
	employees e
JOIN departments d ON
	e.department_id = d.department_id;

-- 左上图：左外连接
SELECT
	employee_id,
	department_name
FROM
	employees e
LEFT JOIN departments d ON
	e.department_id = d.department_id;

-- 右上图：右外连接
SELECT
	employee_id,
	department_name
FROM
	employees e
RIGHT JOIN departments d ON
	e.department_id = d.department_id;
	
-- 左中图
SELECT
	employee_id,
	department_name
FROM
	employees e
LEFT JOIN departments d ON
	e.department_id = d.department_id
WHERE
	d.department_id IS NULL;
	
-- 右中图
SELECT
	employee_id,
	department_name
FROM
	employees e
RIGHT JOIN departments d ON
	e.department_id = d.department_id
WHERE
	e.department_id IS NULL;
	
-- 左下图：满外连接
-- 方式1：左上图 UNION ALL 右中图
SELECT
	employee_id,
	department_name
FROM
	employees e
LEFT JOIN departments d ON
	e.department_id = d.department_id
UNION ALL
SELECT
	employee_id,
	department_name
FROM
	employees e
RIGHT JOIN departments d ON
	e.department_id = d.department_id
WHERE
	e.department_id IS NULL;
-- 方式2：左中图UNION ALL 右上图
SELECT
	employee_id,
	department_name
FROM
	employees e
LEFT JOIN departments d ON
	e.department_id = d.department_id
WHERE
	d.department_id IS NULL
UNION ALL
SELECT
	employee_id,
	department_name
FROM
	employees e
RIGHT JOIN departments d ON
	e.department_id = d.department_id;
	
-- 右下图：左中图  UNION ALL 右中图
SELECT
	employee_id,
	department_name
FROM
	employees e
LEFT JOIN departments d ON
	e.department_id = d.department_id
WHERE
	d.department_id IS NULL
UNION ALL
SELECT
	employee_id,
	department_name
FROM
	employees e
RIGHT JOIN departments d ON
	e.department_id = d.department_id
WHERE
	e.department_id IS NULL;
	
-- SQL99语法的新特性1：自然连接
SELECT
	employee_id,
	last_name,
	department_name
FROM
	employees e
JOIN departments d
ON
	e.department_id = d.department_id
	AND e.manager_id = d.manager_id;
	
SELECT
	employee_id,
	last_name,
	department_name
FROM
	employees e
NATURAL JOIN departments d;

-- 11.SQL99语法的新特性2：USING
SELECT
	employee_id,
	last_name,
	department_name
FROM
	employees e
JOIN departments d ON
	e.department_id = d.department_id;
	
SELECT
	employee_id,
	last_name,
	department_name
FROM
	employees e
JOIN departments d
		USING(department_id);

-- 第06章_多表查询的课后练习
-- 1.显示所有员工的姓名，部门号和部门名称。
SELECT
	e.last_name,
	e.department_id,
	d.department_name
FROM
	employees e
LEFT OUTER JOIN departments d ON
	e.department_id = d.department_id;
-- 2.查询90号部门员工的job_id和90号部门的location_id
SELECT
	e.job_id,
	l.location_id
FROM
	employees e
JOIN departments d ON
	e.department_id = d.department_id
JOIN locations l ON
	d.location_id = l.location_id
WHERE
	d.department_id = 90;

-- 3.选择所有有奖金的员工的 last_name , department_name , location_id , city
SELECT
	e.last_name,
	e.commission_pct,
	d.department_name,
	d.location_id,
	l.city
FROM
	employees e
LEFT JOIN departments d ON
	e.department_id = d.department_id
LEFT JOIN locations l ON
	d.location_id = l.location_id
WHERE
	e.commission_pct IS NOT NULL;
-- 4.选择city在Toronto工作的员工的 last_name , job_id , department_id , department_name
SELECT
	e.last_name,
	e.job_id,
	e.department_id,
	d.department_name
FROM
	employees e
JOIN departments d ON
	e.department_id = d.department_id
JOIN locations l ON
	d.location_id = l.location_id
WHERE
	l.city = 'Toronto';

-- 5.查询员工所在的部门名称、部门地址、姓名、工作、工资，其中员工所在部门的部门名称为’Executive’
SELECT
	d.department_name,
	l.street_address,
	e.last_name,
	e.job_id,
	e.salary
FROM
	employees e
JOIN departments d ON
	e.department_id = d.department_id
LEFT JOIN locations l ON
	d.location_id = l.location_id
WHERE
	d.department_name = 'Executive';

-- 6.选择指定员工的姓名，员工号，以及他的管理者的姓名和员工号，结果类似于下面的格式
-- employees	Emp# 	manager 	Mgr#
-- 	kochhar  	101 	king 		100
SELECT
	emp.last_name 'employees',
	emp.employee_id 'Emp#',
	mgr.last_name 'manager',
	mgr.employee_id 'Mgr#'
FROM
	employees emp
LEFT JOIN employees mgr ON
	emp.manager_id = mgr.employee_id;
-- 7.查询哪些部门没有员工
SELECT
	d.department_id
FROM
	departments d
LEFT JOIN employees e ON
	d.department_id = e.department_id
WHERE
	e.department_id IS NULL;
# 8. 查询哪个城市没有部门
SELECT
	l.location_id,
	l.city
FROM
	locations l
LEFT JOIN departments d ON
	l.location_id = d.location_id
WHERE
	d.location_id IS NULL;
# 9. 查询部门名为 Sales 或 IT 的员工信息
SELECT
	e.employee_id,
	e.last_name,
	d.department_id
FROM
	employees e
JOIN departments d ON
	e.department_id = d.department_id
WHERE
	d.department_name IN ('Sales', 'IT');