-- Создание БД для социальной сети ВКонтакте

-- Создаём БД--


-- Делаем её текущей
USE vk;

-- Создаём таблицу пользователей
-- 1. Для меня кажется странным разделять сейчас пользователя и профиль особенно с учетом того,
--    что внизу идет жесткая привязка строк 1 к 1
-- 2. Если исходить из предположения что у одного человека может быть несколько профилей 
--    и на интерфейс это будет тоже поддерживать в понятном виде то для меня странно что пол помещен в профиль, а
--    почта и телефон в пользователя. Кажется, должно быть наоборот. Телефон и почта не связаны с человеком,
--    а вот пол атрибут именно этой сущности. А телефон и почта должны стать колонками профилей 

CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,  
  firstname VARCHAR(100) NOT NULL,
  lastname VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

-- Таблица профилей
-- Если исходим из 1. (что выше) то таблицы этой не должно быть
-- Если из 2. то user_id должен перестать быть первичным ключем и не должен быть уникальым
-- ну и должно появится id. сделал именно так
CREATE TABLE profiles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  sex CHAR(1) NOT NULL,
  birthday DATE,
  hometown VARCHAR(100),
  photo_id INT UNSIGNED NOT NULL
);

-- Таблица сообщений
-- Так как у нас везде дальше идут именно ссылки на пользователя, а не на профиль
-- тогда, не вижу смысла в таблице профилей. Все её колонки с данными должны быть в пользователях
-- А в эту таблицу я бы добавил ещё дату доставки
CREATE TABLE messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  from_user_id INT UNSIGNED NOT NULL,
  to_user_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  important BOOLEAN,
  delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW(),
  delivere_at DATETIME DEFAULT NULL
);

-- Таблица дружбы
-- Добавил в confirmed_at значение по умолчанию, так удобнее  
CREATE TABLE friendship (
  user_id INT UNSIGNED NOT NULL,
  friend_id INT UNSIGNED NOT NULL,
  status_id INT UNSIGNED NOT NULL,
  requested_at DATETIME DEFAULT NOW(),
  confirmed_at DATETIME DEFAULT NULL,
  PRIMARY KEY (user_id, friend_id)
);

-- Таблица статусов дружеских отношений
CREATE TABLE friendship_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);


-- Таблица групп
-- мне кажется, что тут должна быть ещё информация об авторе и дате создания группы
-- при этом, я сделал связями по ID чтобы нормальность была :) однако, формально, нужно либо
-- добавляет ещё текстовое поле, так как например если человек скажет чтобы мы прекратили обрабатывать его персональные данные
-- то нам нужно удалить!! его из базы и значить целостность нарушится. Как вариант сделать эти поля возможными NULL
-- что в итоге и сделал
-- 
-- Уникальное название группы мне кажется странным. Если оно уникальное, то пусть и будет вместо ID, зачем тогда id... 
-- но это не критично. Хочется сделать с id цифровым всё же в силу удобства и некого стандарта
CREATE TABLE communities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  author_id INT UNSIGNED DEFAULT NULL,
  created_at DATETIME DEFAULT NOW()
);


-- Таблица связи пользователей и групп
-- Ну а здесь просто просится поле с типом этой связи, и с датой, когда эта связь изменилась
-- можно ещё добавить и создание, для интереса, но можно и без неё
CREATE TABLE communities_users (
  community_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  status_id INT UNSIGNED NOT NULL,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (community_id, user_id)
);

-- Таблица статусов в группах
-- Добавил эту таблицу самих статусов 
CREATE TABLE communities_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);


-- Таблица медиафайлов
CREATE TABLE media (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  media_type_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  filename VARCHAR(255) NOT NULL,
  size INT NOT NULL,
  metadata JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица типов медиафайлов
CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

-- Рекомендуемый стиль написания кода SQL
-- https://www.sqlstyle.guide/ru/

-- Заполняем таблицы с учётом отношений 
-- на http://filldb.info
