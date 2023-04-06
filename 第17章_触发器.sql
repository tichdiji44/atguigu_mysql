-- 第17章_触发器

-- 0. 准备工作
CREATE DATABASE dbtest17;

USE dbtest17;

-- 1. 创建触发器

-- ① 创建数据表
CREATE TABLE test_trigger (
	id int PRIMARY KEY AUTO_INCREMENT,
	t_note varchar(30)
);

CREATE TABLE test_trigger_log(
	id int PRIMARY KEY AUTO_INCREMENT,
	t_log varchar(30)
);

-- ② 查看表数据
SELECT
	*
FROM
	test_trigger;
	
SELECT
	*
FROM
	test_trigger_log;
	
-- ③ 创建触发器
-- 创建名为before_insert的触发器，向test_trigger数据表插入数据之前，
-- 向test_trigger_log数据表中插入before_insert的日志信息
delimiter //
CREATE TRIGGER before_insert_test_tri
BEFORE INSERT ON test_trigger
FOR EACH ROW
BEGIN
	INSERT INTO test_trigger_log(t_log) VALUES ("before insert...");
END //
delimiter ;

-- ④ 测试
INSERT
	INTO
	test_trigger(t_note)
VALUES('Tom..');

SELECT
	*
FROM
	test_trigger;

SELECT
	*
FROM
	test_trigger_log;

-- 举例2：
-- 创建名称为after_insert的触发器，向test_trigger数据表插入数据之后，
-- 向test_trigger_log数据表中插入after_insert的日志信息。
delimiter $
CREATE TRIGGER after_insert_test_tri
AFTER INSERT ON test_trigger
FOR EACH ROW
BEGIN
	INSERT INTO test_trigger_log(t_log)
	values('after insert...');
END $
delimiter ;

-- 测试
INSERT
	INTO
	test_trigger(t_note)
VALUES('Jerry..');

SELECT
	*
FROM
	test_trigger;

SELECT
	*
FROM
	test_trigger_log;
	
-- 举例3：
-- 定义触发器“salary_check_trigger”，基于员工表“employees”的INSERT事件，
-- 在INSERT之前检查将要添加的新员工薪资是否大于他领导的薪资，如果大于领导薪资，
-- 则报sqlstate_value为'HY000'的错误，从而使得添加失败。

-- 准备工作
CREATE TABLE employees
AS
SELECT
	*
FROM
	atguigudb.employees;

CREATE TABLE departments
SELECT
AS
	*
FROM
	atguigudb.departments;
	
-- 创建触发器
delimiter //
CREATE TRIGGER salary_check_trigger
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	-- 查询到要添加的数据的manager的薪资
	DECLARE mgr_sal double;

	SELECT salary INTO mgr_sal FROM employees
	WHERE employee_id = NEW.manager_id;

	IF NEW.salary > mgr_sal
		THEN SIGNAL SQLSTATE 'HY000' SET message_text = '薪资高于领导薪资错误';
	END IF;
END //
delimiter ;

-- 测试
DESC employees;

-- 添加成功：依然触发了触发器
INSERT
	INTO
	employees(employee_id,
	last_name,
	email,
	hire_date,
	job_id,
	salary,
	manager_id)
VALUES (300,
'Tom',
'tom@126.com',
curdate(),
'AD_VP',
8000,
103);

-- 添加失败
INSERT
	INTO
	employees(employee_id,
	last_name,
	email,
	hire_date,
	job_id,
	salary,
	manager_id)
VALUES (300,
'Tom1',
'tom@126.com',
curdate(),
'AD_VP',
10000,
103);

SELECT * FROM employees;

-- 2. 查看触发器
-- ① 查看当前数据库的所有触发器的定义
SHOW TRIGGERS;

-- ② 方式2：查看当前数据库中某个触发器的定义
SHOW CREATE TRIGGER salary_check_trigger;

-- ③ 方式3：从系统库information_schema的TRIGGERS表中查询"salary_check_trigger"触发器的信息
SELECT * FROM information_schema.TRIGGERS;

-- 3. 删除触发器
DROP TRIGGER IF EXISTS after_insert_test_tri;

-- 第17章_触发器的课后练习
-- 练习1：
-- 0. 准备工作
CREATE DATABASE test17_trigger;

USE test17_trigger;

CREATE TABLE emps
AS
SELECT
	employee_id,
	last_name,
	salary
FROM
	atguigudb.employees;
	
SELECT * FROM emps;

-- 1. 复制一张emps表的空表emps_back，只有表结构，不包含任何数据
CREATE TABLE emps_back
AS
SELECT
	*
FROM
	emps
WHERE
	1 = 2;
	
-- 查询emps_back表中的数据
SELECT
	*
FROM
	emps_back;
	
-- 3. 创建触发器emps_insert_trigger，每当向emps表中添加一条记录时，同步将这条记录
-- 添加到emps_back表中
delimiter //
CREATE TRIGGER emps_insert_trigger
AFTER INSERT ON emps
FOR EACH ROW
BEGIN
	-- 将新添加到emps表中的记录添加到emps_back表中
	INSERT INTO emps_back(employee_id, last_name, salary)
	values(NEW.employee_id, NEW.last_name, NEW.salary);
END //
delimiter ;

-- SHOW triggers;

-- 4. 验证触发器是否起作用
SELECT
	*
FROM
	emps;

SELECT
	*
FROM
	emps_back;
	
INSERT
	INTO
	emps(employee_id,
	last_name,
	salary)
VALUES(300,
'Tom',
3400);

-- 练习2：
-- 0. 准备工作：使用练习1中的emps表
-- 1. 复制一张emps表的空表emps_back1，只有表结构，不包含任何数据
CREATE TABLE emps_back1
AS
SELECT
	*
FROM
	emps
WHERE
	1 = 2;

-- 2. 查询emps_back1表中的数据
SELECT
	*
FROM
	emps_back1;

-- 3. 创建触发器emps_del_trigger，每当向emps表中删除一条记录时，同步将删除的这条记录添加到emps_back1表中
delimiter //
CREATE TRIGGER emps_del_trigger
BEFORE DELETE ON emps
FOR EACH ROW
BEGIN
	-- 将emps表中删除的记录，添加到emps_back1表中
	INSERT INTO emps_back1(employee_id, last_name, salary)
	VALUES (OLD.employee_id, OLD.last_name, OLD.salary);
END //
delimiter ;

-- 4. 验证触发器是否起作用
DELETE
FROM
	emps
WHERE
	employee_id = 101;

DELETE
FROM
	emps;

SELECT
	*
FROM
	emps;
	
SELECT
	*
FROM
	emps_back1;