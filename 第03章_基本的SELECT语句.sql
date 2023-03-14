SELECT
	1 + 1,
	3 * 2;
SELECT
	1 + 1,
	3 * 2
FROM
	DUAL; -- 伪表
	
-- *：表中的所有字段（或列）
SELECT
	*
FROM
	employees;
	
SELECT
	employee_id,
	last_name,
	salary
FROM
	employees;
	
-- 6、列的别名
-- as:全程 alias(别名)，可以省略
-- 列的别名可以使用一对""引起来，不要使用''
SELECT
	employee_id emp_id,
	last_name AS lname,
	department_id '部门id',
	salary * 12 'annual sal'
FROM
	employees;
	
-- 7、去除重复行
-- 查询员工表中一共有哪些部门id呢？
SELECT
	DISTINCT department_id
FROM
	employees;
	
-- 8、空值参与运算
-- 空值：null
-- null不等同于0，''，'null'
SELECT
	*
FROM
	employees;
	
-- 空值参与运算
SELECT
	employee_id,
	salary"月工资",
	salary *(1 + commission_pct)* 12 '年工资',
	commission_pct
FROM
	employees;
-- 实际问题的解决方案：引入IFNULL
SELECT
	employee_id,
	salary"月工资",
	salary *(1 + ifnull(commission_pct, 0))* 12 '年工资',
	commission_pct
FROM
	employees;

-- 9、着重号 ``
SELECT * FROM `order`;

-- 10、查询常数
SELECT
	'尚硅谷',
	employee_id,
	last_name
FROM
	employees;
	
-- 11、显示表结构
DESCRIBE employees; -- 显示了表中字段的详细信息

DESC employees;

DESC departments;

-- 12、过滤数据
-- 查询90号部门的员工信息
SELECT
	*
FROM
	employees
-- 过滤条件
WHERE department_id = 90;

-- 练习：查询last_name为'King'的员工信息
SELECT
	*
FROM
	employees
WHERE
	last_name = 'King';
	
-- 第03章_基本的SELECT语句的课后联系
-- 1.查询员工12个月的工资总和，并起别名为ANNULA SALARY
-- 理解1：计算12月的基本工资
SELECT
	employee_id,
	last_name,
	salary * 12 'ANNULA SALARY'
FROM
	employees;
-- 理解2：计算12月的基本工资和奖金
SELECT
	employee_id,
	last_name,
	salary * 12 *(1 + ifnull(commission_pct, 0)) 'ANNULA SALARY'
FROM
	employees;

-- 2.查询employees表中去除重复的job_id以后的数据
SELECT
	DISTINCT job_id
FROM
	employees;

-- 3.查询工资大于12000的员工姓名和工资
SELECT
	last_name,
	salary
FROM
	employees
WHERE
	salary>12000;
	
-- 4.查询员工号为176的员工的姓名和部门号
SELECT
	last_name,
	department_id
FROM
	employees
WHERE
	employee_id = 176;
	
-- 5.显示表departments的结构，并查询其中的全部数据
DESCRIBE departments;

SELECT * FROM departments;