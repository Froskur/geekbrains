# ================================================================================================
# 1.� ���� ������ shop � sample ������������ ���� � �� �� �������, ������� ���� ������.
# ����������� ������ id = 1 �� ������� shop.users � ������� sample.users.
# ����������� ����������.

START TRANSACTION;
  INSERT INTO sample.users (SELECT * FROM shop.users WHERE id=1);
  DELETE FROM shop.users WHERE id=1;
COMMIT;

# 2.�������� �������������, ������� ������� �������� name �������� ������� �� ������� 
# products � ��������������� �������� �������� name �� ������� catalogs.

DROP VIEW IF EXISTS v_products;

CREATE VIEW v_products (catalog_name, products_name) AS 
  (SELECT products.name, catalogs.name 
    FROM products
      JOIN catalogs ON products.catalog_id=catalogs.id
   );

# ================================================================================================
# 3.����� ������� ������� � ����������� ����� created_at.
# � ��� ��������� ���������� ����������� ������ �� ������ 2018 ���� '2018-08-01', '2018-08-04', '2018-08-16' � 2018-08-17. 
# ��������� ������, ������� ������� ������ ������ ��� �� ������, ��������� � �������� ���� �������� 1, ���� ���� ������������ 
# � �������� ������� � 0, ���� ��� �����������.

USE sample;
DROP TABLE IF EXISTS test;
CREATE TABLE IF NOT EXISTS test (created_at DATE);

INSERT INTO test (created_at) VALUES ('2018-08-01'),('2018-08-04'),('2018-08-16'), ('2018-08-17');

SELECT a.Date, NOT isnull(created_at) AS created_at 
from (
    select curdate() - INTERVAL (a.a + (10 * b.a) + (100 * c.a) + (1000 * d.a) ) DAY as Date
    from (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as a
    JOIN (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as b
    JOIN (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as c
    JOIN (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as d
) a
LEFT JOIN test ON a.date=test.created_at
WHERE a.Date between '2018-08-01' and '2018-08-31'
ORDER BY a.date
;

# =========================================================================
# 4.����� ������� ����� ������� � ����������� ����� created_at. �������� ������, ������� ������� 
# ���������� ������ �� �������, �������� ������ 5 ����� ������ �������.

# ����� ������� ����� ���������� ����������� �������, �� ������� ��� ID ����� ����� 
# � �� ���� ��� ��� ����� �����
DROP TABLE IF EXISTS test;
CREATE TABLE IF NOT EXISTS test (created_at DATE);
INSERT INTO test (created_at) VALUES ('2019-08-01'),('2018-08-04'),('2016-08-16'), ('2018-09-11'),
  									 ('2018-09-19'),('2019-12-04'),('2018-11-16'), ('2017-05-20'),
									 ('2017-11-01'),('2018-11-01'),('2019-03-04'), ('2018-09-15')
;

#������� ��������� ������� 
CREATE TEMPORARY TABLE temp (created_at DATE);
# ��������� ������ ������
INSERT INTO temp (SELECT * FROM test ORDER BY  created_at DESC LIMIT 5);
# ������� ������ ������� ��� �� �������� ������� 
DELETE FROM test 
WHERE created_at NOT IN (SELECT temp.created_at FROM temp);
# ������� ��������� ������� 
DROP TEMPORARY TABLE IF EXISTS temp;

=======================================================================================
# 5. �������� ���� ������������� ������� ����� ������ � ���� ������ shop.
# ������� ������������ shop_read ������ ���� �������� ������ ������� �� ������ ������,
# ������� ������������ shop � ����� �������� � �������� ���� ������ shop.

DROP USER IF EXISTS 'shop'@'localhost'; 
DROP USER IF EXISTS 'shop_read'@'localhost'; 

CREATE USER IF NOT EXISTS 'shop'@'localhost' IDENTIFIED WITH sha256_password BY 'password';
GRANT ALL ON shop.* TO 'shop'@'localhost';

CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY 'password';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';

# ============================================================================================
# 6. �������� �������� ������� hello(), ������� ����� ���������� �����������, � ����������� �� �������� ������� �����. � 6:00 �� 12:00 ������� ������
# ���������� ����� "������ ����", � 12:00 �� 18:00 ������� ������ ���������� ����� "������ ����", � 18:00 �� 00:00 � "������ �����", � 00:00 �� 6:00 � "������ ����".

# ��� ���� ����� � ���� ������� NOT DETERMINISTIC ��� ����� ���� ������ ��� ����� ���������
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS hello;

DELIMITER //
CREATE FUNCTION hello() RETURNS text CHARSET utf8mb4 NOT DETERMINISTIC
BEGIN
	DECLARE return_text text;
	if hour(now())>=6 AND hour(now())<=12 then
	  set return_text='������ ����';
	elseif hour(now())>12 AND hour(now())<=18 then
	  set return_text='������ ����';
	elseif hour(now())>18 AND hour(now())<=23 then 
	  set return_text='������ �����';
	else 
	  set return_text='������ ����'; 
	end if;
RETURN return_text;
END//
DELIMITER ;

SELECT hello();

# ====================================================================================================================================
# 7. � ������� products ���� ��� ��������� ����: name � ��������� ������ � description � ��� ���������.  ��������� ����������� ����� ����� 
# ��� ���� �� ���. ��������, ����� ��� ���� ��������� �������������� �������� NULL �����������.  ��������� ��������, ��������� ����, 
# ����� ���� �� ���� ����� ��� ��� ���� ���� ���������. ��� ������� ��������� ����� NULL-�������� ���������� �������� ��������.

DELIMITER //

CREATE TRIGGER trg_products_insert_check BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  IF ISNULL(NEW.name) && ISNULL(NEW.desription) THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name and desription can`t be null';
  END IF; 
END//

CREATE TRIGGER trg_products_update_check BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  IF ISNULL(NEW.name) && ISNULL(NEW.desription) THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name and desription can`t be null';
  END IF; 
END//

DELIMITER ;
