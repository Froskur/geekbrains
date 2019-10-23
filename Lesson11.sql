# =======================================================
# 1.
# �������� ������� logs ���� Archive. 
# ����� ��� ������ �������� ������ � �������� users, catalogs � products � ������� logs ���������� 
# ����� � ���� �������� ������, �������� �������, ������������� ���������� ����� � ���������� ���� name.

DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
	created_at DATETIME NOT NULL,
	target_id BIGINT NOT NULL,
	table_name ENUM('users', 'catalogs' ,'products') NOT NULL,
	name VARCHAR(255)
) ENGINE=Archive;

# ������� ������ �� ������ ������� 
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
# (�� �������) �������� SQL-������, ������� �������� � ������� users ������� �������.

# ������� ���������...

DROP PROCEDURE IF EXISTS users_create_big_data;

DELIMITER //

CREATE PROCEDURE users_create_big_data (IN count_rows INT)
  BEGIN 
	DECLARE new_birthday VARCHAR(10);  
	WHILE count_rows > 0 DO
		# ������� ���� ������������ ���� ������� �����������	
		SET new_birthday = CONCAT(FLOOR(RAND()*(2002-1960+1)+1960),'-',FLOOR(RAND()*(12-1+1)+1),'-',FLOOR(RAND()*(28-1+1)+1));	
		
		INSERT DELAYED INTO users SET name = 'Auto create', birthday_at = new_birthday;    	
    	SET count_rows = count_rows - 1;
  	END WHILE;	     
	  
END//
  
DELIMITER ;

# �������� ��������� ��� �������� �������� �������
CALL users_create_big_data(10);

INSERT DELAYED INTO users SET name = 'Auto create', birthday_at = '1979-10-11';