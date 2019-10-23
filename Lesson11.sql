# =======================================================
# 1.
# Создайте таблицу logs типа Archive. 
# Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается 
# время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
	created_at DATETIME NOT NULL,
	target_id BIGINT NOT NULL,
	table_name ENUM('users', 'catalogs' ,'products') NOT NULL,
	name VARCHAR(255)
) ENGINE=Archive;

# создаем тригер на каждую таблицу 
DROP TRIGGER IF EXISTS trg_users_logs_create;
DROP TRIGGER IF EXISTS trg_catalogs_logs_create;
DROP TRIGGER IF EXISTS trg_products_logs_create;

DELIMITER //

CREATE TRIGGER trg_users_logs_create AFTER INSERT ON users
FOR EACH ROW BEGIN
   INSERT INTO logs SET created_at = NOW(), 
   						target_id = NEW.id,
   						table_name = 'users',
   						name = NEW.name
  	;
END//

CREATE TRIGGER trg_catalogs_logs_create AFTER INSERT ON catalogs
FOR EACH ROW BEGIN
   INSERT INTO logs SET created_at = NOW(), 
   						target_id = NEW.id,
   						table_name = 'catalogs',
   						name = NEW.name
  	;
END//

CREATE TRIGGER trg_products_logs_create AFTER INSERT ON products
FOR EACH ROW BEGIN
   INSERT INTO logs SET created_at = NOW(), 
   						target_id = NEW.id,
   						table_name = 'products',
   						name = NEW.name
  	;
END//

DELIMITER ;

# =====================================================================================
# 2.
# (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

# Создаем процедуру...

DROP PROCEDURE IF EXISTS users_create_big_data;

DELIMITER //

CREATE PROCEDURE users_create_big_data (IN count_rows INT)
  BEGIN 
	DECLARE new_birthday VARCHAR(10);  
	WHILE count_rows > 0 DO
		# Добавил чтоб пользователи хоть немного различались	
		SET new_birthday = CONCAT(FLOOR(RAND()*(2002-1960+1)+1960),'-',FLOOR(RAND()*(12-1+1)+1),'-',FLOOR(RAND()*(28-1+1)+1));	
		
		INSERT DELAYED INTO users SET name = 'Auto create', birthday_at = new_birthday;    	
    	SET count_rows = count_rows - 1;
  	END WHILE;	     
	  
END//
  
DELIMITER ;

# Вызываем процедуру для создания миллиона записей
CALL users_create_big_data(1000000);

