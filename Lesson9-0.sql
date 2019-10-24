# ================================================================================================
# 1.В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
# Переместите запись id = 1 из таблицы shop.users в таблицу sample.users.
# Используйте транзакции.

START TRANSACTION;
  INSERT INTO sample.users (SELECT * FROM shop.users WHERE id=1);
  DELETE FROM shop.users WHERE id=1;
COMMIT;

# 2.Создайте представление, которое выводит название name товарной позиции из таблицы 
# products и соответствующее название каталога name из таблицы catalogs.

DROP VIEW IF EXISTS v_products;

CREATE VIEW v_products (catalog_name, products_name) AS 
  (SELECT products.name, catalogs.name 
    FROM products
      JOIN catalogs ON products.catalog_id=catalogs.id
   );

# ================================================================================================
# 3.Пусть имеется таблица с календарным полем created_at.
# В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и 2018-08-17. 
# Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует 
# в исходном таблице и 0, если она отсутствует.

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
# 4.Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет 
# устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

# Хотел сначала через транзакции попробовать сделать, но подумал что ID тогда нужны 
# а не факт что они могут будут
DROP TABLE IF EXISTS test;
CREATE TABLE IF NOT EXISTS test (created_at DATE);
INSERT INTO test (created_at) VALUES ('2019-08-01'),('2018-08-04'),('2016-08-16'), ('2018-09-11'),
  									 ('2018-09-19'),('2019-12-04'),('2018-11-16'), ('2017-05-20'),
									 ('2017-11-01'),('2018-11-01'),('2019-03-04'), ('2018-09-15')
;

#создаем временную таблицу 
CREATE TEMPORARY TABLE temp (created_at DATE);
# Вставялем нужные строки
INSERT INTO temp (SELECT * FROM test ORDER BY  created_at DESC LIMIT 5);
# удаляем строки которых нет во врменной таблице 
DELETE FROM test 
WHERE created_at NOT IN (SELECT temp.created_at FROM temp);
# Удаляем временную таблицу 
DROP TEMPORARY TABLE IF EXISTS temp;

=======================================================================================
# 5. Создайте двух пользователей которые имеют доступ к базе данных shop.
# Первому пользователю shop_read должны быть доступны только запросы на чтение данных,
# Второму пользователю shop — любые операции в пределах базы данных shop.

DROP USER IF EXISTS 'shop'@'localhost'; 
DROP USER IF EXISTS 'shop_read'@'localhost'; 

CREATE USER IF NOT EXISTS 'shop'@'localhost' IDENTIFIED WITH sha256_password BY 'password';
GRANT ALL ON shop.* TO 'shop'@'localhost';

CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY 'password';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';

# ============================================================================================
# 6. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна
# возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

# Для того чтобы у меня работал NOT DETERMINISTIC мне нужно было задать вот такую переенную
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS hello;

DELIMITER //
CREATE FUNCTION hello() RETURNS text CHARSET utf8mb4 NOT DETERMINISTIC
BEGIN
	DECLARE return_text text;
	if hour(now())>=6 AND hour(now())<=12 then
	  set return_text='Доброе утро';
	elseif hour(now())>12 AND hour(now())<=18 then
	  set return_text='Доброе день';
	elseif hour(now())>18 AND hour(now())<=23 then 
	  set return_text='Добрый вечер';
	else 
	  set return_text='Доброй ночи'; 
	end if;
RETURN return_text;
END//
DELIMITER ;

SELECT hello();

# ====================================================================================================================================
# 7. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.  Допустимо присутствие обоих полей 
# или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.  Используя триггеры, добейтесь того, 
# чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.

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
