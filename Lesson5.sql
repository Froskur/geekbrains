use test;

# =======================================================================================
# 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
# 
# Создали табличку с пользователями
DROP TABLE IF EXISTS users;

CREATE TABLE users (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	birthday DATE NOT NULL,
	created_at DATETIME,
	updated_at DATETIME
);

# Заполнили тестовыми данными 
INSERT INTO `users` VALUES ('1','Kiana Kessler','2008-03-10',NULL,NULL),
('2','Silas Hackett PhD','2001-05-14',NULL,NULL),
('3','Glenda Jerde','1999-02-13',NULL,NULL),
('4','Alexandrea Russel','1995-02-07',NULL,NULL),
('5','Emmanuel Langworth','1997-03-08',NULL,NULL),
('6','Miss Micaela Lynch','1997-09-13',NULL,NULL),
('7','Shana Rippin','2008-11-03',NULL,NULL),
('8','Lonzo Schoen','2003-05-18',NULL,NULL),
('9','Fern Rippin','2009-01-25',NULL,NULL),
('10','Eleonore Blick','2000-01-22',NULL,NULL),
('11','Albert Adams','2003-12-15',NULL,NULL),
('12','Ericka Hickle','1999-09-30',NULL,NULL),
('13','Mr. Stanford Reichert I','1992-03-18',NULL,NULL),
('14','Miss Sally Dickinson I','2002-02-07',NULL,NULL),
('15','Mrs. Janis Ratke III','2004-04-04',NULL,NULL),
('16','Ralph Johnson Sr.','2004-03-02',NULL,NULL),
('17','Hipolito McClure MD','2001-12-09',NULL,NULL),
('18','Cecilia Muller','2001-04-12',NULL,NULL),
('19','Mr. Lambert Christiansen III','1995-08-15',NULL,NULL),
('20','Cordell Streich','1997-07-08',NULL,NULL),
('21','Vallie Dicki','2003-05-15',NULL,NULL),
('22','Angeline Stark V','1999-03-08',NULL,NULL),
('23','Brianne Moore','2001-03-19',NULL,NULL),
('24','Joshuah Becker','2007-05-18',NULL,NULL),
('25','Laurence Stracke','1998-06-20',NULL,NULL),
('26','Karina Shanahan','2009-01-06',NULL,NULL),
('27','Miss Yolanda Ryan DVM','2001-04-19',NULL,NULL),
('28','Pamela Pagac','2003-06-12',NULL,NULL),
('29','Dr. Oswald Heidenreich IV','1998-07-18',NULL,NULL),
('30','Queenie Schroeder II','1994-11-19',NULL,NULL),
('31','Korbin D\'Amore','2002-10-16',NULL,NULL),
('32','Fanny Spencer','2005-03-26',NULL,NULL),
('33','Ethan Wisoky Sr.','2007-04-15',NULL,NULL),
('34','Dr. Tod Wisozk IV','1996-11-28',NULL,NULL),
('35','Devyn Cartwright','2002-01-18',NULL,NULL),
('36','Marlin Will','1992-01-01',NULL,NULL),
('37','Josefa Kris','1989-12-27',NULL,NULL),
('38','Prof. Maxwell Bartoletti Sr.','1991-07-14',NULL,NULL),
('39','Aimee Hauck','1996-03-27',NULL,NULL),
('40','Major Grady','2006-11-11',NULL,NULL),
('41','Janelle Kuhn','2009-10-04',NULL,NULL),
('42','Creola Deckow','2005-11-27',NULL,NULL),
('43','Furman Mraz II','2002-12-08',NULL,NULL),
('44','Idell VonRueden Jr.','2005-02-06',NULL,NULL),
('45','Maymie Reinger','1999-06-07',NULL,NULL),
('46','Jordan VonRueden','2002-02-19',NULL,NULL),
('47','Germaine Barton II','2009-06-26',NULL,NULL),
('48','Mrs. Rae Cormier','1999-06-01',NULL,NULL),
('49','Joe Mills','1991-03-06',NULL,NULL),
('50','Maude Borer','2005-07-09',NULL,NULL),
('51','Prof. Anna Heathcote','2003-10-05',NULL,NULL),
('52','Royal Windler','1995-01-11',NULL,NULL),
('53','Myrl Mayer','1994-10-12',NULL,NULL),
('54','Maynard Turcotte V','1995-10-03',NULL,NULL),
('55','Vena Koepp','1997-11-09',NULL,NULL),
('56','Jayme Mitchell','2007-05-28',NULL,NULL),
('57','Ms. Wilhelmine Prohaska','1997-03-31',NULL,NULL),
('58','Jedidiah Hayes III','1991-09-30',NULL,NULL),
('59','Wilber Turcotte','1995-05-30',NULL,NULL),
('60','Prof. Melisa Marks IV','2004-05-15',NULL,NULL),
('61','Edmond West','1994-08-07',NULL,NULL),
('62','Efren Swaniawski','2000-06-21',NULL,NULL),
('63','Marcus Stehr','1999-08-25',NULL,NULL),
('64','Ms. Lea Pagac','1990-01-07',NULL,NULL),
('65','Dr. Lucas Little PhD','2006-07-31',NULL,NULL),
('66','Moises Witting III','2005-04-30',NULL,NULL),
('67','Jordane Hilll','1992-12-01',NULL,NULL),
('68','Elliott McKenzie','1998-09-22',NULL,NULL),
('69','Prof. Tristian Yost','1998-05-18',NULL,NULL),
('70','Jazmyne Wilkinson','1994-04-10',NULL,NULL),
('71','Mrs. Madilyn McKenzie DVM','1995-03-25',NULL,NULL),
('72','Mrs. Kiara Rowe','1996-09-14',NULL,NULL),
('73','Althea Toy','1994-09-04',NULL,NULL),
('74','Robyn Cremin II','1991-11-30',NULL,NULL),
('75','Prof. Hilton Feest','2001-08-15',NULL,NULL),
('76','Jordi Gleason Sr.','2008-02-07',NULL,NULL),
('77','Raul Swaniawski','1992-02-29',NULL,NULL),
('78','Prof. Elmo Mosciski II','1996-10-21',NULL,NULL),
('79','Buddy Morissette Sr.','1990-11-27',NULL,NULL),
('80','Savanah Bergstrom','1996-08-16',NULL,NULL),
('81','Orie Heathcote','2002-10-29',NULL,NULL),
('82','Terrell Wolf','2007-12-05',NULL,NULL),
('83','Marley Lynch','1995-02-27',NULL,NULL),
('84','Richie Mitchell','1999-05-08',NULL,NULL),
('85','Dillon Hintz','1989-11-15',NULL,NULL),
('86','Mr. Rey Conroy Jr.','1990-04-29',NULL,NULL),
('87','Prof. Mellie Kihn','1989-12-01',NULL,NULL),
('88','Eldridge Jast','1998-06-17',NULL,NULL),
('89','Dr. Mathias Koelpin','1990-07-20',NULL,NULL),
('90','Emmanuel Murphy','1998-06-23',NULL,NULL),
('91','Ruthe Douglas V','2007-12-08',NULL,NULL),
('92','Cleve Braun IV','2002-11-01',NULL,NULL),('93','Aric Hoeger','2007-06-13',NULL,NULL),('94','Yolanda Ortiz II','1992-03-06',NULL,NULL),('95','Juliet Feest','2009-07-03',NULL,NULL),('96','Dr. Alexzander Satterfield','1990-05-22',NULL,NULL),('97','Prof. Cory Lehner Jr.','1992-05-10',NULL,NULL),('98','Jacinto Abshire','2000-08-21',NULL,NULL),('99','Loyal Bernhard Jr.','1990-10-02',NULL,NULL),('100','Jordyn Schuppe','1993-03-20',NULL,NULL); 

# Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем
UPDATE users SET created_at=NOW(), updated_at=NOW() 



# =======================================================================================
# 2. Таблица users была неудачно спроектирована. 
# Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". 
# Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
DROP TABLE IF EXISTS users_bad;

CREATE TABLE users_bad (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	birthday DATE NOT NULL,
	created_at VARCHAR(16),
	updated_at VARCHAR(16)
);

# Заполним тестовыми данными
INSERT INTO `users_bad` VALUES ('1','Prof. Florine Huels','1973-11-07','1988-01-19 01:01','1988-02-18 12:02'),
('2','Dan Runolfsdottir MD','1995-03-02','1981-09-18 05:09','2014-10-14 21:10'),
('3','Winston Schoen','1990-05-02','1972-09-14 20:09','1973-08-19 01:08'),
('4','Onie Pollich','1999-01-19','2002-04-16 08:04','1990-11-02 08:11'),
('5','Ms. Zita Abshire PhD','1996-12-01','2003-09-16 20:09','1983-06-30 05:06'),
('6','Kayley Stoltenberg','1986-06-03','1976-06-26 22:06','1985-06-12 21:06'),
('7','Glenna Zulauf MD','1972-01-13','1976-05-30 02:05','1995-05-31 23:05'),
('8','Nils Tremblay DVM','2005-06-03','1977-02-15 16:02','1976-12-22 11:12'),
('9','Chelsey Bashirian','1978-07-18','1980-08-25 01:08','1973-07-13 21:07'),
('10','Dortha Prohaska','2002-03-02','1983-09-15 05:09','1999-04-03 23:04'),
('11','Dr. Alessandra Beahan','2008-05-20','1989-10-24 17:10','1978-12-05 04:12'),
('12','Charlene Hodkiewicz','2015-10-23','2015-02-24 01:02','2012-02-24 13:02'),
('13','Lambert Waelchi V','1996-02-13','2002-10-16 20:10','1980-12-04 10:12'),
('14','Icie Wisozk','1995-06-12','1979-08-31 22:08','1981-06-30 15:06'),
('15','Antonia Schinner','1978-09-02','1978-12-03 10:12','1997-11-28 00:11'),
('16','Makenna Emmerich','1988-03-15','2011-02-27 20:02','1971-09-01 13:09'),
('17','Glenna Hintz','1970-10-29','2001-06-30 16:06','1999-05-23 19:05'),
('18','Aditya Hessel','1970-02-19','1973-06-18 20:06','2009-03-10 22:03'),
('19','Gwendolyn Ritchie','1983-03-06','2011-08-21 21:08','1982-06-19 23:06'),
('20','Camden Nicolas','2011-04-27','2005-10-16 00:10','1981-05-05 06:05'),
('21','Aaron Thiel','2015-04-25','2017-08-14 18:08','2003-01-23 08:01'),
('22','Arlo Greenfelder','2003-11-16','1980-09-04 02:09','1991-02-20 16:02'),
('23','Dolly Effertz V','1992-04-07','2017-08-16 15:08','1978-05-24 18:05'),
('24','Ole Lehner','1982-08-15','2003-05-07 14:05','1984-10-11 21:10'),
('25','Joesph Crooks V','1981-11-01','1990-10-17 15:10','2011-08-19 06:08'),
('26','Dr. Sammy Schowalter MD','1972-07-04','1971-11-03 09:11','2018-06-03 19:06'),
('27','Benton Bergstrom Sr.','1980-03-25','1973-08-11 12:08','2002-11-26 10:11'),
('28','Dereck Wiegand IV','1995-04-24','1979-01-09 17:01','2019-09-26 11:09'),
('29','Liliana Turcotte Jr.','1986-07-24','2012-04-18 02:04','1972-05-21 14:05'),
('30','Benton Sipes','1977-08-07','1972-03-06 18:03','1986-09-23 23:09'),
('31','Dr. Marilyne Baumbach DDS','1990-02-02','1979-10-14 09:10','1982-10-24 21:10'),
('32','Jermey Nienow','1976-04-15','1983-12-22 18:12','1997-07-09 22:07'),
('33','Dorthy Koepp','1973-06-04','1999-04-12 09:04','1985-02-25 18:02'),
('34','Monique Denesik','1997-05-30','2003-08-09 08:08','1988-02-05 10:02'),
('35','Sandy Hyatt','1994-11-27','1990-10-29 09:10','1970-07-20 05:07'),
('36','Malinda Rutherford','1999-12-08','1989-03-09 15:03','2001-01-09 10:01'),
('37','Prof. Tyrese Block','2014-05-17','2009-01-09 16:01','1981-12-31 23:12'),
('38','Grace Reichert PhD','1970-04-14','2007-12-19 16:12','2017-11-10 00:11'),
('39','Dr. Ewell McLaughlin','1988-12-02','1995-05-21 18:05','2006-08-31 13:08'),
('40','Joaquin Feil MD','1996-11-21','1973-01-21 14:01','2009-05-18 20:05'),
('41','Marcel Russel','1981-09-29','2014-04-10 15:04','2007-03-18 11:03'),
('42','Dave Jast','2009-04-08','1998-06-17 04:06','1978-09-06 17:09'),
('43','Dr. Geraldine Trantow','1971-03-27','1987-04-30 03:04','1996-01-11 09:01'),
('44','Laura Boyer','1974-11-12','1971-05-08 16:05','1974-11-26 00:11'),
('45','Prof. Alexanne Wiegand PhD','1984-01-06','1978-04-17 08:04','1993-06-16 11:06'),
('46','Casimir Nolan','2016-10-02','1992-04-14 16:04','1986-09-16 06:09'),
('47','Bud Wintheiser','1992-11-30','1980-05-17 23:05','2019-02-27 08:02'),
('48','Rylan Grant','1972-09-20','1979-08-21 15:08','2010-06-17 19:06'),
('49','Christ Brekke','2014-07-25','2017-01-03 04:01','1984-03-11 10:03'),
('50','Felipa Flatley','1988-09-21','1994-06-21 20:06','2007-10-15 05:10'); 

# Создадим новые поля для даты и времени 
# Просто меняем тип у уже существующих колонок 
ALTER TABLE users_bad MODIFY created_at DATETIME,MODIFY updated_at DATETIME;


# =======================================================================================
# 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, 
# если товар закончился и выше нуля, если на складе имеются запасы. 
# Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
# Однако, нулевые запасы должны выводиться в конце, после всех записей.
DROP TABLE IF EXISTS storehouses_products;
#  для простоты только одно поле дедаем чтобы не генерить лишнего
CREATE TABLE storehouses_products (
	value INT NOT NULL
);
INSERT INTO storehouses_products VALUES (0),(2500),(0),(30),(500),(1)

# А теперь выведем
SELECT * FROM storehouses_products ORDER BY value>0 DESC, value; 
# Крутая задача! ) первый раз применял услуоия в сортировке

# =====================================================================================
# 4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
# Месяцы заданы в виде списка английских названий ('may', 'august')
#
# В это случае использовал предоставленную таблицу, из материалов к уроку
SELECT *,LOWER(DATE_FORMAT(birthday_at,'%M')) as birthday_m 
FROM shop.users 
HAVING birthday_m IN ('may','august');


# =======================================================================================
# 5. Из таблицы catalogs извлекаются записи при помощи запроса. 
# SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
# Отсортируйте записи в порядке, заданном в списке IN.

# Нашел вот такой интересный вариант
SELECT * FROM shop.catalogs WHERE id IN (5, 1, 2)
ORDER BY
CASE id
    WHEN 5 THEN 1
    WHEN 1 THEN 2
    WHEN 2 THEN 3
    ELSE 4
END ASC
;

#  и вот такой, который подойдет только для MYSQL
#  он может быть интерсннее, так как в приложении проще будет формировать такой запрос
SELECT * FROM shop.catalogs WHERE id IN (5, 1, 2)
ORDER BY FIELD(id, 5, 1, 2)
;


# =======================================================================================
# 6 Подсчитайте средний возраст пользователей в таблице users
# Будем использовать тоже таблицу из shop, там меньше данных
# Сначала так сделал средний ворзрат, но потом подумал что есть же люди которые родились раньше 1970 года
# и доавил такого для теста в базу. И тогда метод не правильно будет работать
SELECT *,(UNIX_TIMESTAMP(NOW())-UNIX_TIMESTAMP(birthday_at))/(3600*24*365.25) as user_old FROM shop.users;

# Переписал вот так
SELECT *,(TO_DAYS(NOW())-TO_DAYS(birthday_at))/365.25 as user_old FROM shop.users;

# и финальный 
SELECT AVG((TO_DAYS(NOW())-TO_DAYS(birthday_at))/365.25) as user_old FROM shop.users;


# ========================================================================================================
# 7.
# Подсчитайте количество дней рождения, которые приходятся на каждую из дней недели. 
# Следует учесть, что необходимы дни недели текущего года, а не года рождения.
# делал на своих данных из 
SELECT count(*), DATE_FORMAT(CONCAT(DATE_FORMAT(now(),"%Y-"),DATE_FORMAT(birthday,"%m-%d")),"%a") as day_week_then 
FROM test.users 
GROUP BY day_week_then
ORDER BY day_week_then
;

# По предыдущему результату оказалось есть знаение с NULL это значит что есть ДР 29 февраля, которого нет в теущем году
# провреили и нашли такую запись
SELECT * FROM test.users WHERE birthday LIKE "%02-29"

# ============================================================================================================
# 8.
# Подсчитайте произведение чисел в столбце таблицы
# Создадим таблицу 
DROP TABLE IF EXISTS test_value;

CREATE TABLE test_value (
	value INT
);

# Заполнили тестовыми данными 
INSERT INTO `test_value` VALUES (1),(2),(3),(4),(5)

# Нашел вообщем такой метод :)
SELECT ROUND(EXP(SUM(LN(value))),0) from test.test_value
