-- 第13章_约束

/*
1. 基础知识
1.1 为什么需要约束？ 为了保证数据的完整性！

1.2 社么叫约束？ 对表中字段的限制。

1.3 约束的分类
角度1：约束的字段的个数
单列约束 vs 多列约束

角度2：约束的作用范围
列级约束：将此约束声明在对应字段的后面
表级约束：在表中所有字段都声明完，在所有字段的后面声明的约束

角度3：约束的作用（或功能）
① not null（非空约束）
② unique（唯一性约束）
③ primary key（主键约束）
④ foreign key（外键约束）
⑤ check（检查约束）
⑥ default（默认值约束）

-- 1.4 如何添加/删除约束？
CREATE TABLE时添加约束
ALTER TABLE时删除约束
*/

-- 2. 如何查看表中的约束
SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	table_name = 'employees';
	
CREATE DATABASE dbtest13;
USE dbtest13;

-- 3. not null（非空约束）
-- 3.1 在CREATE TABLE时添加约束
CREATE TABLE test1(
	id int NOT NULL,
	last_name varchar(15) NOT NULL,
	email varchar(25),
	salary decimal(10,
2)
);

DESC test1;

INSERT
	INTO
	test1(id,
	last_name,
	email,
	salary)
VALUES (1,
'Tom',
'tom@126.com',
3400);

--  Column 'last_name' cannot be null
INSERT
	INTO
	test1(id,
	last_name,
	email,
	salary)
VALUES(2,
NULL,
'tom1@126.com',
3400);

-- Column 'id' cannot be null
INSERT
	INTO
	test1(id,
	last_name,
	email,
	salary)
VALUES(NULL,
'Jerry',
'tom1@126.com',
3400);

-- Field 'last_name' doesn't have a default value
INSERT
	INTO
	test1(id,
	email)
VALUES(2,
'abc@126.com');

-- Column 'last_name' cannot be null
UPDATE
	test1
SET
	last_name = NULL
WHERE
	id = 1;
	
UPDATE
	test1
SET
	email = 'tom@126.com'
WHERE
	id = 1;
	
-- 3.2 在ALTER TABLE时添加约束
SELECT
	*
FROM
	test1;
	
DESC test1;

ALTER TABLE test1 MODIFY email varchar(25) NOT NULL;

-- 3.2 在ALTER TABLE时删除约束
ALTER TABLE test1
MODIFY email varchar(25) NULL;

-- 4. unique（唯一性约束）
-- 4.1 在CREATE TABLE时添加约束
CREATE TABLE test2(
	id int UNIQUE,
	last_name varchar(15),
	email varchar(25),
	salary decimal(10,
2),
-- 表级约束
	CONSTRAINT uk_test2_email UNIQUE(email)
);

DESC test2;

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'test2';
	
-- 在创建唯一约束的时候，如果不给唯一约束命名，就默认和列名相同。
INSERT
	INTO
	test2(id,
	last_name,
	email,
	salary)
VALUES(1,
'Tom',
'tom@126.com',
4500);

-- Duplicate entry '1' for key 'test2.id'
INSERT
	INTO
	test2(id,
	last_name,
	email,
	salary)
VALUES(1,
'Tom1',
'tom1@126.com',
4600);

-- Duplicate entry 'tom@126.com' for key 'test2.uk_test2_email'
INSERT
	INTO
	test2(id,
	last_name,
	email,
	salary)
VALUES(2,
'Tom1',
'tom@126.com',
4600);

-- 可以向声明为unique的字段上添加null值
INSERT
	INTO
	test2(id,
	last_name,
	email,
	salary)
VALUES (2,
'Tom1',
NULL,
4600);

INSERT
	INTO
	test2(id,
	last_name,
	email,
	salary)
VALUES(3,
'Tom2',
NULL,
4600);

SELECT
	*
FROM
	test2;
	
-- 4.2 在ALTER TABLE时添加约束
DESC test2;

UPDATE
	test2
SET
	salary = 5000
WHERE
	id = 3;

-- Duplicate entry '4600.00' for key 'test2.uk_test2_sal'
-- 方式1：
ALTER TABLE test2 
ADD CONSTRAINT uk_test2_sal UNIQUE(salary);
-- 方式2：
ALTER TABLE test2
MODIFY last_name varchar(15) UNIQUE;

-- 4.3 复合的唯一性约束
CREATE TABLE `USER`(
	id int,
	`name` varchar(15),
	`password` varchar(25),
-- 表级约束
	CONSTRAINT uk_user_name_pwd UNIQUE (`name`,
`password`)
);

INSERT
	INTO
	`user`
VALUES(1,
'Tom',
'abc');
-- 可以添加成功的
INSERT
	INTO
	`user`
VALUES (1,
'Tom1',
'abc');

SELECT
	*
FROM
	`user`;
	
-- 案例：复合的唯一性约束的案例
-- 学生表
create table student(
	sid int, -- 学号
	sname varchar(20), -- 姓名
	tel char(11) unique key, -- 电话
	cardid char(18) unique key -- 身份证号
);

-- 课程表
CREATE TABLE course(
	cid int,
-- 课程编号
cname varchar(20)
-- 课程名称
);

-- 选课表
CREATE TABLE student_course(
	id int,
	sid int,
-- 学号
cid int,
-- 课程编号
score int,
	UNIQUE KEY(sid,
cid)
-- 复合唯一
);

INSERT
	INTO
	student
VALUES(1,
'张三',
'13710011002',
'101223199012015623');
INSERT
	INTO
	student
VALUES(2,
'李四',
'13710011003',
'101223199012015624');
INSERT
	INTO
	course
VALUES(1001,
'Java'),
(1002,
'MySQL');

SELECT
	*
FROM
	student;

SELECT
	*
FROM
	course;

INSERT
	INTO
	student_course
VALUES
(1,
1,
1001,
89),
(2,
1,
1002,
90),
(3,
2,
1001,
88),
(4,
2,
1002,
56);

SELECT
	*
FROM
	student_course;
	
-- 4.4 删除唯一约束
-- 添加唯一性约束的列上也会自动创建唯一索引。
-- 删除唯一约束只能通过删除唯一索引的方式删除。
-- 删除时需要指定唯一索引名，唯一索引名就和唯一约束名一样。
-- 如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同；如果是组合列，那么默认和()中排在第一个的列名相同。也可以自定义唯一性约束名。

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'test2';
	
DESC test2;

-- 如何删除唯一性索引
ALTER TABLE test2
DROP INDEX last_name;

ALTER TABLE test2
DROP INDEX uk_test2_sal;

-- 5. primary key （主键约束）
-- 5.1 在CREATE TABLE时添加约束

-- 一个表中最多只能有一个主键约束

-- 错误：Multiple primary key defined
CREATE TABLE test3(
	id int PRIMARY KEY,
-- 列级约束
last_name varchar(15) PRIMARY KEY,
	salary decimal(10,
2),
	email varchar(25)
);

-- 主键约束特征：非空且唯一，用于唯一的表示表中的一条记录
CREATE TABLE test4(
	id int PRIMARY KEY,
-- 列级约束
last_name varchar(15),
	salary decimal(10,
2),
	email varchar(25)
);

CREATE TABLE test5(
	id int,
	last_name varchar(15),
	salary decimal(10,
2),
	email varchar(25),
-- 表级约束
	CONSTRAINT pk_test5_id PRIMARY KEY (id)
-- 没有必要起名字
);

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'test5';
	
INSERT
	INTO
	test4(id,
	last_name,
	salary,
	email)
VALUES(1,
'Tom',
4500,
'tom@126.com');

SELECT
	*
FROM
	test4;
	
CREATE TABLE `user1`(
	id int,
	name varchar(15),
	password varchar(25),
	PRIMARY KEY(name,
password)
);

-- 如果是多列组合的复合主键约束，那么这些列都不允许为空值，并且组合的值不允许重复
INSERT
	INTO
	user1
VALUES(1,
'Tom',
'abc');

INSERT
	INTO
	user1
VALUES(1,
'Tom1',
'abc');

-- 错误：Column 'name' cannot be null
INSERT
	INTO
	user1
VALUES(1,
NULL,
'abc');

SELECT
	*
FROM
	user1;
	
-- 4.2 在ALTER TABLE时添加约束
CREATE TABLE test6(
	id int,
	last_name varchar(15),
	salary decimal(10,2),
	email varchar(25)
);

DESC test6;

ALTER TABLE test6
ADD PRIMARY KEY(id);

-- 5.3 如何删除主键约束（在实际开发中，不回去删除表中的主键约束！）
ALTER TABLE test6
DROP PRIMARY KEY;

-- 6. 自增长列：AUTO_INCREMENT
CREATE TABLE test7(
	id int PRIMARY KEY AUTO_INCREMENT,
	last_name varchar(15)
);

INSERT
	INTO
	test7(last_name)
VALUES('Tom');

SELECT
	*
FROM
	test7;
	
-- 当我们向主键（含AUTO_INCREMENT）的字段上添加0或null时，实际上会自动的往上添加指定的字段的数值
INSERT
	INTO
	test7(id,
	last_name)
VALUES(0,
'Tom');

INSERT
	INTO
	test7(id,
	last_name)
VALUES(NULL,
'Tom');

INSERT
	INTO
	test7(id,
	last_name)
VALUES(10,
'Tom');

INSERT
	INTO
	test7(id,
	last_name)
VALUES(-10,
'Tom');

-- 6.2 在ALTER TABLE时添加
CREATE TABLE test8(
	id int PRIMARY KEY,
	last_name varchar(15)
);

DESC test8;

ALTER TABLE test8
MODIFY id int AUTO_INCREMENT;

-- 6.3 在ALTER TABLE时删除
ALTER TABLE test8
MODIFY id int;

-- 6.4 MYSQL 8.0新特性-自增变量的持久化
-- 在MYSQL5.7中演示

-- 在MYSQL8.0中演示

-- 7. foreign key（外键约束）
-- 7.1 在CREATE TABLE时添加
-- 主表和从表：父表和子表
-- ①先创建主表
CREATE TABLE dept1(
	dept_id int,
	dept_name varchar(15)
);

-- 上述操作报错，因为主表中的dept_id上没有注解约束或唯一性约束
-- ① 添加
ALTER TABLE dept1
ADD PRIMARY KEY (dept_id)

-- ②再创建从表
CREATE TABLE emp1(
	emp_id int PRIMARY KEY AUTO_INCREMENT,
	emp_name varchar(15),
	department_id int,
-- 表级约束
	CONSTRAINT fk_emp1_dept_id FOREIGN KEY (department_id) REFERENCES dept1(dept_id)
);

DESC emp1;

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'emp1';
	
-- 7.2 演示外键的效果
-- 添加失败
INSERT
	INTO
	emp1
VALUES(1001,
'Tom',
10);

INSERT
	INTO
	dept1
VALUES(10,
'IT');

-- 再主表dept1中添加了10号部门以后，我们就可以在从表添加10号部门的员工
INSERT
	INTO
	emp1
VALUES(1001,
'Tom',
10);

-- 删除失败
DELETE
FROM
	dept1
WHERE
	dept_id = 10;
	
-- 更新失败
UPDATE
	dept1
SET
	dept_id = 20
WHERE
	dept_id = 10;
	
CREATE TABLE dept2(
	dept_id int PRIMARY KEY,
	dept_name varchar(15)
);

CREATE TABLE emp2(
	emp_id int PRIMARY KEY AUTO_INCREMENT,
	emp_name varchar(15),
	department_id int
);

ALTER TABLE emp2
ADD CONSTRAINT fk_emp2_dept_id FOREIGN KEY(department_id) REFERENCES dept2(dept_id);

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'emp2';
	
CREATE TABLE dept(
did int PRIMARY KEY,
#部门编号
dname varchar(50)
#部门名称
);

CREATE TABLE emp(
eid int PRIMARY KEY,
#员工编号
ename varchar(5),
#员工姓名
deptid int,
#员工所在的部门
FOREIGN KEY (deptid) REFERENCES dept(did) ON
UPDATE
	CASCADE ON
	DELETE
		SET
		NULL
		#把修改操作设置为级联修改等级，把删除操作设置为set null等级
);

INSERT
	INTO
	dept
VALUES(1001,
'教学部');

INSERT
	INTO
	dept
VALUES(1002,
'财务部');

INSERT
	INTO
	dept
VALUES(1003,
'咨询部');

INSERT
	INTO
	emp
VALUES(1,
'张三',
1001);
#在添加这条记录时，要求部门表有1001部门
INSERT
	INTO
	emp
VALUES(2,
'李四',
1001);

INSERT
	INTO
	emp
VALUES(3,
'王五',
1002);

-- 7.5 删除外键约束

-- 一个表中可以声明有多个外键约束
USE atguigudb;

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'employees';
	
USE dbtest13;

SELECT
	*
FROM
	information_schema.table_constraints
WHERE
	TABLE_NAME = 'emp1';
	
-- 删除外键约束
ALTER TABLE emp1 DROP FOREIGN KEY fk_emp1_dept_id;

-- 再手动的删除外键约束对应的普通索引
SHOW INDEX FROM emp1;

ALTER TABLE emp1
DROP INDEX fk_emp1_dept_id;

-- 8. check约束
CREATE TABLE test10(
	id int,
	last_name varchar(15),
	salary decimal(10,
2) CHECK(salary > 2000)
);

INSERT
	INTO
	test10
VALUES(1,
'Tom',
2500);

-- 添加失败
INSERT
	INTO
	test10
VALUES(2,
'Tom1',
1500);

SELECT
	*
FROM
	test10;
	
-- 9. DEFAULT约束
CREATE TABLE test11(
	id int,
	last_name varchar(15),
	salary decimal(10,
2) DEFAULT 2000
);

DESC test11;

INSERT
	INTO
	test11(id,
	last_name,
	salary)
VALUES (1,
'Tom',
3000);

INSERT
	INTO
	test11(id,
	last_name)
VALUES(2,
'Tom1');

SELECT
	*
FROM
	test11;
	
-- 9.2 在ALERT TABLE添加约束
CREATE TABLE test12(
	id int,
	last_name varchar(15),
	salary decimal(10,
2)
);

DESC test12;

ALTER TABLE test12
MODIFY salary decimal(8,
2) DEFAULT 2500;

-- 9.3 在ALTER TABLE删除约束
ALTER TABLE test12
MODIFY salary decimal(8,
2);

-- 第13章_约束的课后练习

-- 练习1：
CREATE DATABASE test04_emp;

USE test04_emp;

CREATE TABLE emp2(
id INT,
emp_name VARCHAR(15)
);

CREATE TABLE dept2(
id INT,
dept_name VARCHAR(15)
);

-- 1.向表emp2的id列中添加PRIMARY KEY约束
ALTER TABLE emp2
ADD CONSTRAINT pk_emp2_id PRIMARY KEY(id);

-- 2. 向表dept2的id列中添加PRIMARY KEY约束
ALTER TABLE dept2
ADD CONSTRAINT pk_dept2_id PRIMARY KEY(id);

-- 3. 向表emp2中添加列dept_id，并在其中定义FOREIGN KEY约束，与之相关联的列是dept2表中的id列。
ALTER TABLE emp2
ADD dept_id int;

DESC emp2;

ALTER TABLE emp2
ADD CONSTRAINT fk_emp2_deptid FOREIGN KEY(dept_id) REFERENCES dept2(id);

-- 练习2：
-- 承接《第11章_数据处理之增删改》的综合案例
USE test01_library;

-- 根据题目要求给books表中的字段添加约束
--
ALTER TABLE books
ADD PRIMARY KEY (id);

ALTER TABLE books
MODIFY id int AUTO_INCREMENT;

-- 方式2
ALTER TABLE books
MODIFY id int PRIMARY KEY;

-- 针对于非id字段的操作
ALTER TABLE books 
MODIFY name VARCHAR(50) NOT NULL;

ALTER TABLE books
MODIFY `authors` VARCHAR(100) NOT NULL;

ALTER TABLE books
MODIFY price FLOAT NOT NULL;

ALTER TABLE books
MODIFY pubdate DATE NOT NULL;

ALTER TABLE books
MODIFY num INT NOT NULL;

-- 练习3：
-- 1. 创建数据库test04_company
CREATE DATABASE IF NOT EXISTS test04_company CHARACTER SET
'utf8';

USE test04_company;

CREATE TABLE IF NOT EXISTS offices(
	officeCode int(10) PRIMARY KEY,
	city varchar(50),
	address varchar(50),
	country varchar(50) NOT NULL,
	postalCode varchar(15) UNIQUE,
	CONSTRAINT uk_off_poscode UNIQUE(postalCode)
);

DESC offices;

CREATE TABLE employees(
	employeeNumber INT(11) PRIMARY KEY AUTO_INCREMENT,
	lastName VARCHAR(50) NOT NULL,
	firstName VARCHAR(50) NOT NULL,
	mobile VARCHAR(25) UNIQUE,
	officeCode INT(10) NOT NULL,
	jobTitle VARCHAR(50) NOT NULL,
	birth DATETIME NOT NULL,
	note VARCHAR(255),
	sex VARCHAR(5),
	CONSTRAINT fk_emp_ofCode FOREIGN KEY(officeCode) REFERENCES offices(officeCode)
);

DESC employees;

-- 3. 将表employees的mobile字段修改到officeCode字段后面
ALTER TABLE employees
MODIFY mobile varchar(25) AFTER officeCode;

-- 4. 将表employees的birth字段改名为employee_birth
ALTER TABLE employees
CHANGE birth employee_birth datetime;

-- 5. 修改sex字段，数据类型为CHAR(1)，非空约束
ALTER TABLE employees
MODIFY sex char(1) NOT NULL;

-- 6. 删除字段note
ALTER TABLE employees
DROP COLUMN note;

-- 7. 增加字段名favoriate_activity，数据类型为VARCHAR(100)
ALTER TABLE employees
ADD favorite_activity varchar(100);

-- 8. 将表employees名称修改为employees_info
RENAME TABLE employees
TO employees_info;

-- 错误：Table 'test04_company.employees' doesn't exist
DESC employees;

DESC employees_info;
