-- 第12章_MYSQL数据类型精讲

-- 1. 关于属性：character set name
SHOW variables LIKE 'character_%';

-- 创建数据库时指明字符集
CREATE DATABASE IF NOT EXISTS dbtest12 CHARACTER SET
'utf8';

SHOW CREATE DATABASE dbtest12;

USE dbtest12;

-- 创建表的时候，指明表的字符集
CREATE TABLE temp(
	id int
)CHARACTER SET
'utf8';

SHOW CREATE TABLE temp;

-- 创建表，指明表中的字段时，可以指定字段的字符集
CREATE TABLE temp1(
	id int,
	name varchar(15) charater SET
'gbk'
);
SHOW CREATE TABLE temp1;

-- 2. 整型数据类型
CREATE TABLE test_int1(
	f1 TINYINT,
	f2 SMALLINT,
	f3 MEDIUMINT,
	f4 integer,
	f5 bigint
);

DESC test_int1;

INSERT INTO test_int1(f1)
values(12),(-12),(-128),(127);

SELECT
	*
FROM
	test_int1;
	
-- Out of range value from column 'f1' at row 1
INSERT
	INTO
	test_int1(f1)
VALUES(128);

CREATE TABLE test_int2(
	f1 int,
	f2 int(5),
	f3 int(5) ZEROFILL
-- ① 显示宽度为5。当insert的值不足5位时，使用5填充 ② 当使用ZEROFILL时，自动会添加UNSIGNED
);

INSERT
	INTO
	test_int2(f1,
	f2)
VALUES(123,
123),
(123456,
123456);

SELECT
	*
FROM
	test_int2;
	
INSERT
	INTO
	test_int2(f3)
VALUES(123),
(123456);

SHOW CREATE TABLE test_int2;

CREATE TABLE test_int3(
	f1 int UNSIGNED
);

DESC test_int3;

INSERT
	INTO
	test_int3
VALUES(2412321);

-- Out of range value for column 'f1' at row 1
INSERT
	INTO
	test_int3
VALUES(4294967296);

-- 3. 浮点类型
CREATE TABLE test_double1(
	f1 float,
	f2 float(5,
2),
	f3 double,
	f4 double(5,
2)
);

DESC test_double1;

INSERT
	INTO
	test_double1(f1,
	f2)
VALUES (123.45,
123.45);

SELECT
	*
FROM
	test_double1;
	
INSERT
	INTO
	test_double1(f3,
	f4)
VALUES(123.45,
123.456); -- 存在四舍五入

-- Out of range value for column 'f4' at row 1
INSERT
	INTO
	test_double1(f3,
	f4)
VALUES(123.45,
1234.456);

-- Out of range value for column 'f4' at row 1
INSERT
	INTO
	test_double1(f3,
	f4)
VALUES(123.45,
999.995);

INSERT
	INTO
	test_double1
VALUES (0,
47),
(0.44),
(0.19);

SELECT
	sum(f1)
FROM
	test_double1;
	
SELECT
	sum(f1) = 1.1,
	1.1 = 1.1
FROM
	test_double1;
	
-- 4. 定点数类型
CREATE TABLE test_decimal1(
	f1 decimal,
	f2 decimal(5,2)
);

DESC test_decimal1;

INSERT
	INTO
	test_decimal1(f1)
VALUES(123),
(123.45);

SELECT
	*
FROM
	test_decimal1;
	
INSERT
	INTO
	test_decimal1(f2)
VALUES(999.99);

INSERT
	INTO
	test_decimal1(f2)
VALUES(67.567); -- 存在四舍五入

-- Out of range value for column 'f2' at row 1
INSERT
	INTO
	test_decimal1(f2)
VALUES(1267.567);

-- Out of range value for column 'f2' at row 1
INSERT
	INTO
	test_decimal1(f2)
VALUES(999.995);

ALTER TABLE test_double1
MODIFY f1 decimal(5,
2);

DESC test_double1;

SELECT
	sum(f1)
FROM
	test_double1;
	
SELECT
	sum(f1)= 1.1,
	1.1 = 1.1
FROM
	test_double1;
	
-- 5. 位类型：BIT
CREATE TABLE test_bit1(
	f1 bit,
	f2 bit(5),
	f3 bit(64)
);

DESC test_bit1;

INSERT
	INTO
	test_bit1(f1)
VALUES(0),
(1);

SELECT
	*
FROM
	test_bit1;
	
-- Data truncation: Data too long for column 'f1' at row 1
INSERT
	INTO
	test_bit1(f1)
VALUES(2);

INSERT
	INTO
	test_bit1(f2)
VALUES(31);

-- Data truncation: Data too long for column 'f2' at row 1
INSERT
	INTO
	test_bit1(f2)
VALUES(32);

SELECT
	bin(f1),
	bin(f2),
	hex(f1),
	hex(f2)
FROM
	test_bit1;
	
SELECT
	f1 + 0,
	f2 + 0
FROM
	test_bit1;
	
-- 6.1 YEAR类型
CREATE TABLE test_year(
	f1 YEAR,
	f2 YEAR(4)
);

DESC test_year;

INSERT
	INTO
	test_year(f1)
VALUES('2021'),(2022)

SELECT
	*
FROM
	test_year;
	
--
INSERT
	INTO
	test_year(f1)
VALUES('2155');

-- Data truncation: Out of range value for column 'f1' at row 1
INSERT
	INTO
	test_year(f1)
VALUES('2156');

INSERT
	INTO
	test_year(f1)
VALUES ('69'),
('70');

INSERT
	INTO
	test_year(f1)
VALUES(0),
('00');

-- 6.2 DATE类型
CREATE TABLE test_date1(
	f1 date
);

DESC test_date1;

INSERT
	INTO
	test_date1
VALUES('2020-10-01'),
('20201001'),
(20201001);

INSERT
	INTO
	test_date1
VALUES('00-01-01'),
('000101'),
('69-10-01'),
('691001'),
('70-01-01'),
('700101'),
('99-01-01'),
('990101');

INSERT
	INTO
	test_date1
VALUES(000301),
(690301),
(700301),
(990301); -- 存在隐式转换

INSERT
	INTO
	test_date1
VALUES(current_date()),
(now());

SELECT
	*
FROM
	test_date1;
	
-- 6.3 TIME类型
CREATE TABLE test_time1(
	f1 time
);

DESC test_time1;

INSERT
	INTO
	test_time1
VALUES ('2 12:30:29'),
('12:35:29'),
('12:40'),
('2 12:40'),
('1 05'),
('45');

INSERT
	INTO
	test_time1
VALUES(123520),
(124011),
(1210);

INSERT
	INTO
	test_time1
VALUES(now()),
(CURRENT_time()),
(curtime());

SELECT
	*
FROM
	test_time1;
	
-- DATETIME类型
CREATE TABLE test_datetime1(
	dt DATETIME
);

INSERT
	INTO
	test_datetime1
VALUES ('2021-01-01 06:50:30'),
('20210101065030');

INSERT
	INTO
	test_datetime1
VALUES ('99-01-01 00:00:00'),
('990101000000'),
('20-01-01 00:00:00'),
('200101000000');

INSERT
	INTO
	test_datetime1
VALUES (20200101000000),
(200101000000),
(19990101000000),
(990101000000);

INSERT
	INTO
	test_datetime1
VALUES (CURRENT_TIMESTAMP()),
(NOW());

INSERT
	INTO
	test_datetime1
VALUES(sysdate());

SELECT
	*
FROM
	test_datetime1;
	
-- 6.5 TIMESTAMP类型
CREATE TABLE test_timestamp1(
	ts timestamp
);

INSERT
	INTO
	test_timestamp1
VALUES ('1999-01-01 03:04:50'),
('19990101030405'),
('99-01-01 03:04:05'),
('990101030405');

INSERT
	INTO
	test_timestamp1
VALUES ('2020@01@01@00@00@00'),
('20@01@01@00@00@00');

INSERT
	INTO
	test_timestamp1
VALUES (CURRENT_TIMESTAMP()),
(NOW());

#Incorrect datetime value
INSERT
	INTO
	test_timestamp1
VALUES ('2038-01-20 03:14:07');

SELECT
	*
FROM
	test_timestamp1;
	
-- 对比TIMESTAMP和TIMESTAMP
CREATE TABLE temp_time(
	d1 datetime,
	d2 timestamp
);

INSERT
	INTO
	temp_time
VALUES('2021-9-2 14:45:52',
'2021-9-2 14:45:52');

INSERT
	INTO
	temp_time
VALUES(now(),
now());

SELECT
	*
FROM
	temp_time;
	
-- 7.1 CHAR类型
CREATE TABLE test_char1(
	c1 char,
	c2 char(5)
);

DESC test_char1;

-- Data truncation: Data too long for column 'c1' at row 1
INSERT
	INTO
	test_char1(c1)
VALUES('ab');

INSERT
	INTO
	test_char1(c2)
VALUES('ab');

INSERT INTO test_char1(c2)
values('hello');

INSERT
	INTO
	test_char1(c2)
VALUES('尚');

INSERT
	INTO
	test_char1(c2)
VALUES('硅谷');

INSERT
	INTO
	test_char1(c2)
VALUES('尚硅谷教育');

-- Data truncation: Data too long for column 'c2' at row 1
INSERT
	INTO
	test_char1(c2)
VALUES('尚硅谷IT教育');

SELECT
	*
FROM
	test_char1;
	
SELECT
	concat(c2, '***')
FROM
	test_char1;
	
INSERT
	INTO
	test_char1(c2)
VALUES('ab  ');

SELECT
	char_length(c2)
FROM
	test_char1;
	
-- 7.2 VARCHAR类型
CREATE TABLE test_varchar1(
	name varchar -- 错误
);

-- Column length too big for column 'name' (max = 21845); use BLOB or TEXT instead
CREATE TABLE test_varchar2(
	name varchar(65535)
);

CREATE TABLE test_varchar3(
	name varchar(5)
);

INSERT
	INTO
	test_varchar3
VALUES('尚硅谷'),
('尚硅谷教育');

-- Data truncation: Data too long for column 'name' at row 1
INSERT
	INTO
	test_varchar3
VALUES ('尚硅谷IT教育');

-- 7.3 TEXT类型
CREATE TABLE test_text(
	tx text
);

INSERT
	INTO
	test_text
VALUES ('atguigu   ');

SELECT
	char_length(tx)
FROM
	test_text; -- 10
	
-- 8. ENUM类型
CREATE TABLE test_enum(
	season ENUM('春',
'夏',
'秋',
'冬',
'unknow')
);

INSERT
	INTO
	test_enum
VALUES('春'),
('秋');

-- Data truncated for column 'season' at row 1
INSERT
	INTO
	test_enum
VALUES('春,秋');

-- Data truncated for column 'season' at row 1
INSERT
	INTO
	test_enum
VALUES('人');

INSERT
	INTO
	test_enum
VALUES('unknow');

-- 忽略大小写的
INSERT
	INTO
	test_enum
VALUES('UNKNOW');
-- 可以使用索引进行枚举元素的调用
INSERT
	INTO
	test_enum
VALUES(1),
('3');

INSERT
	INTO
	test_enum
VALUES(NULL);

SELECT
	*
FROM
	test_enum;
	
-- SET类型
CREATE TABLE test_set(
	s SET
('A',
'B',
'C')
);

INSERT
	INTO
	test_set (s)
VALUES ('A'),
('A,B');

#插入重复的SET类型成员时，MySQL会自动删除重复的成员
INSERT
	INTO
	test_set (s)
VALUES ('A,B,C,A');

#向SET类型的字段插入SET成员中不存在的值时，MySQL会抛出错误。
INSERT
	INTO
	test_set (s)
VALUES ('A,B,C,D');

SELECT
	*
FROM
	test_set;
	
CREATE TABLE temp_mul(
	gender ENUM('男',
	'女'),
	hobby SET
	('吃饭',
	'睡觉',
	'打豆豆',
	'写代码')
);

INSERT
	INTO
	temp_mul
VALUES('男',
'睡觉,打豆豆');

INSERT
	INTO
	temp_mul
valeus ('男,女',
	'睡觉,打豆豆');

SELECT
	*
FROM
	temp_mul;
	
-- 10.1 BINARY 与 VARBINARY类型
CREATE TABLE test_binary1(
	f1 BINARY,
	f2 BINARY(3),
-- f3 varbinary,
f4 VARBINARY(10)
);

DESC test_binary1;

INSERT
	INTO
	test_binary1(f1,
	f2)
VALUES ('a',
'abc');

-- Data truncation: Data too long for column 'f1' at row 1
INSERT
	INTO
	test_binary1(f1)
VALUES('ab');

INSERT
	INTO
	test_binary1(f2,
	f4)
VALUES('ab',
'ab');

SELECT
	LENGTH(f1),
	LENGTH(f2)
FROM
	test_binary1;

SELECT
	*
FROM
	test_binary1;
	
-- 10.2 Blob类型
CREATE TABLE test_blob1(
	id int,
	img MEDIUMBLOB
);

INSERT
	INTO
	test_blob1(id)
VALUES (1001);

SELECT
	*
FROM
	test_blob1;
	
-- 11. JSON类型
CREATE TABLE test_json(
	js json
);

INSERT
	INTO
	test_json (js)
VALUES ('{"name":"songhk", "age":18, "address":{"province":"beijing","city":"beijing"}}');

SELECT
	*
FROM
	test_json;
	
SELECT
	js -> '$.name' AS NAME,
	js -> '$.age' AS age ,
	js -> '$.address.province' AS province,
	js -> '$.address.city' AS city
FROM
	test_json;