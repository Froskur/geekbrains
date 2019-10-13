use shop;

#Вставим данные чтобы было что смотреть
INSERT INTO orders (user_id) VALUES (3),(5),(3),(2);

# 1.
# Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

# Вот вариант с вложенным селектом
SELECT *,(SELECT count(*) FROM orders WHERE user_id=u.id) as count_orders 
FROM users as u
HAVING count_orders > 0;

# Вот ваирант с join
SELECT users.id,users.name FROM orders
	LEFT JOIN users ON (users.id=orders.user_id)
GROUP by user_id;


# 2.
# Выведите список товаров products и разделов catalogs, который соответствует товару.

# Делаю только с JOIN. Если я правильно понял то что надо вывести.
SELECT p.name,c.name FROM products as p
	LEFT JOIN catalogs as c ON (p.catalog_id=c.id)
;

use test;
# 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label 
# содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

# Готовим таблицы 
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS cities;

CREATE TABLE flights (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `from` VARCHAR(255) NOT NULL,
  `to` VARCHAR(255) NOT NULL
);
CREATE TABLE cities (
  label VARCHAR(255) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);


INSERT INTO flights VALUES 
	(1,'moscow','omsk'),
	(2,'novgorod','kazan'),
	(3,'irkutsk','moscow'),
	(4,'omsk','irkutsk'),
	(5,'moscow','kazan')
;

INSERT INTO cities VALUES 
	('moscow','Москва'),
	('novgorod','Новгород'),
	('irkutsk','Иркутск'),
	('omsk','Омск'),
	('kazan','Казань')
;

# А вот и сам запрос
SELECT f.id, c1.name as `from`, c2.name as `to` FROM flights as f
	LEFT JOIN cities as c1 ON (c1.label = f.`from`)
	LEFT JOIN cities as c2 ON (c2.label = f.`to`)
;
