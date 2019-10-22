# 1. Создаем кличи для нашей базы ВК

# Таблицы, которым не нужны дополнительные ключи
# communities
# communities_statuses 
# communities_users
# friendship
# friendship_statuses
# likes
# media_types
# messages
# posts
# regions
# target_types

# Там где они возможно понадобятся 

# ВСего скороей пользователи будут их искать по имени и надо будет 
# возможно и уникальность надо будет сюда поставить для имени в дальнейшем
CREATE INDEX idx_emoji_name ON emoji(name);

# media
# Вот тут можно было добавить бы индекс на поле, которое был обозначало название файла
# для пользователя. но у нас такого нет ) 
# По имени файла никтоискать не будет (так как имя то будет переделано на UID какой-нить

# profiles
# Вот тут можно больше разгуляться

# Я ба сделал вот такой, предпологая что ищут по дате рождения, и возможно полу
# и будет работать и просто по дате, так как она первая
# не уверен, что пол полезен как вторая часть индекса...
CREATE INDEX idx_profiles_birthday_sex ON profiles(birthday,sex);

# и отдельный индекс по городу, так как мне кажется 
CREATE INDEX idx_profiles_hometown ON profiles(hometown);


# users
# именно так, так как по фамилии тоже вероятно будут искать и сортировать
CREATE INDEX idx_users_last_name_first_name ON users(last_name,first_name);
# ну и отдельные на эти поля
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);

# Мне кажется что вообще вопрос места под индексы не так актуален, как ресурсы под пересчеты индексов
# а если у проекта есть ярко выраженные пики закгруки и простоя то и пересчет не составляет проблем 
# Но это только мой опыт работы c MSSQL с базой в 36Gb

# ===============================================================================================================
# 2 Задание на денормализацию
# Разобраться как построен и работает следующий запрос: Список медиафайлов пользователя с количеством лайков
# Правильно-ли он построен?
# Какие изменения, включая денормализацию, можно внести в структуру БД
# чтобы существенно повысить скорость работы этого запроса?

SELECT media.filename,
	   target_types.name,
	   COUNT(*) AS total_likes,
	   CONCAT(first_name, ' ', last_name) AS owner
FROM media
	JOIN likes ON media.id = likes.target_id
	JOIN target_types ON likes.target_type_id = target_types.id
	JOIN users ON users.id = media.user_id
WHERE users.id = 2 AND target_types.id = 1
GROUP BY media.id;

# Сначала подумалЮ что JOIN likes ON media.id = likes.target_id не правльно будет так как 
# попадет только один лайк по идеи нужен RIGHT JOIN Потом вспомнил что это же inner потом 
# строк и так будет пять, а потом мы к ним подцепим target_types и users. Столько раз, сколько будет лайков 
# 
# Но на всякий случай проверил )

# смотрим пользователя медиа, и пользователя соответсвенно с самым большим кол-вом лайков  
SELECT media.id,media.user_id,count(*) as total FROM likes 
	JOIN media ON (media.id=likes.target_id) 
WHERE target_type_id=1
GROUP by target_id
ORDER BY total DESC
;

# У меня это пользователь 65 с 5 лайками, например
# проверяем
SELECT media.filename,
	   target_types.name,
	   COUNT(*) AS total_likes,
	   CONCAT(first_name, ' ', last_name) AS owner
FROM media
	JOIN likes ON media.id = likes.target_id
	JOIN target_types ON likes.target_type_id = target_types.id
	JOIN users ON users.id = media.user_id
WHERE users.id = 65 AND target_types.id = 1
GROUP BY media.id;

#ВСё ок по самому запросу

# по денормализации... 
# я всегда, во всех базах что делал все таблички с типом делал сразу ENUM
# но я никогда не мерял быстро это или нет в Mysql, у меня не было высоко нагруженных проектов
# мне просто enum гораздо удобнее чем толпа таблиц из 3-4 строчек и потом и JOIN-ть

# То что касется этого запроса то самое его узкое место на мой взгляд состоит в том, что мы джоиним каждый раз лишнюю информацию
# и что-то мне подсказыает что тут даже не делай ничего с нормализацией можно будет сильно ускорится
# если сделать вот так, особенно на больших кол-вах строк это будет очень заметно

#Вот так будет мне кажется быстрее всего работать запрос. 
SELECT tmp_tbl.filename,
	   target_types.name,
	   tmp_tbl.total_likes,
	   CONCAT(users.first_name, ' ', users.last_name) AS owner
FROM 
		(SELECT media.filename,
				likes.target_type_id,
				media.user_id,				   
			   COUNT(*) AS total_likes			   
		FROM media
			JOIN likes ON media.id = likes.target_id
		WHERE media.user_id = 65 AND likes.target_type_id = 1
		GROUP BY media.id) as tmp_tbl
	JOIN target_types ON tmp_tbl.target_type_id = target_types.id
	JOIN users ON users.id = tmp_tbl.user_id		
;
  
# А то что касается иправления базы данных то тут их конечно много разных можно придумать...
# И отдельне поле для всех лайков на всё что есть, и по полю для каждого типа target и может поле JSON куда писать лайки в виде {<media.id>:<total_likes>,<media.id>:<total_likes>}
#  я не вижу сейчас смыла фантазировать
# так как это всегда определяется требованием к функционалу

# ===================================================================================
# 3. Задание на оконные функции
# Построить запрос, который будет выводить следующие столбцы:
# имя группы
# среднее количество пользователей в группах
# самый молодой пользователь в группе
# самый пожилой пользователь в группе
# общее количество пользователей в группе
# всего пользователей в системе
# отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

# 3.1 Первый вариант болванки (id для проверки)
SELECT DISTINCT communities.id,communities.name,
  'count' as averag_users,
  'user_id' as min_old,
  'user_id' as max_old,
  'count' as in_communities,
  'count' as users_total,
  '%%' as '%%'
FROM communities_users
	JOIN communities ON communities.id = communities_users.community_id
;

# 3.2 Вот, уже что-то получилось
SELECT DISTINCT communities.id,communities.name,
  'count' as averag_users,
  'user_id' as min_old,
  'user_id' as max_old,
  COUNT(user_id) OVER(PARTITION BY communities_users.community_id) as in_communities,
  'count' as users_total,
  '%%' as '%%'
FROM communities_users
	JOIN communities ON communities.id = communities_users.community_id
;

# 3.3 Идем дальше, теперь всего пользователей, я не нашел пока как сделать это оконной функцией
# сдела как смог 
SELECT DISTINCT communities.id, communities.name,
  'count' as averag_users,
  'user_id' as min_old,
  'user_id' as max_old,
  COUNT(user_id) OVER(PARTITION BY communities_users.community_id) as in_communities,
  (SELECT count(*) FROM users) as users_total,
  '%%' as '%%'
FROM communities_users
	JOIN communities ON communities.id = communities_users.community_id
	JOIN users ON users.id = communities_users.user_id
ORDER BY id
	;

# 3.4 С процентами просто...
SELECT DISTINCT communities.id, communities.name,
  'count' as averag_users,
  'user_id' as min_old,
  'user_id' as max_old,
  COUNT(user_id) OVER(PARTITION BY communities_users.community_id) as in_communities,
  (SELECT count(*) FROM users) as users_total,
  (COUNT(user_id) OVER(PARTITION BY communities_users.community_id) / (SELECT count(*) FROM users)*100) as '%%'
FROM communities_users
	JOIN communities ON communities.id = communities_users.community_id
	JOIN users ON users.id = communities_users.user_id
ORDER BY id
	;

# 3.5 Теперь смотрим минимальный и максимальный возраст
SELECT DISTINCT communities.id, communities.name,
  'count' as averag_users,
  MAX(profiles.birthday) OVER(PARTITION BY communities_users.community_id) as min_old,
  MIN(profiles.birthday) OVER(PARTITION BY communities_users.community_id) as max_old,
  COUNT(communities_users.user_id) OVER(PARTITION BY communities_users.community_id) as in_communities,
  (SELECT count(*) FROM users) as users_total,
  (COUNT(communities_users.user_id) OVER(PARTITION BY communities_users.community_id) / (SELECT count(*) FROM users)*100) as '%%'
FROM communities_users
	JOIN communities ON (communities.id = communities_users.community_id)
	JOIN users ON (users.id = communities_users.user_id)
	JOIN profiles ON (communities_users.user_id=profiles.user_id)
ORDER BY id
	;


# 3.6 А потом вспомнил что надо пользователя а не сам возраст...
# Причем я думал что смогу сделать одно окно для возраста и применять функции FIRST_VALUE и LAST_VALUE, вместо того чтобы делать сортировку в окне
# но у меня так не вышло, я не очень понял почему (

SELECT DISTINCT communities.id, communities.name,
  'count' as averag_users,
  FIRST_VALUE(communities_users.user_id) OVER(PARTITION BY communities_users.community_id ORDER BY profiles.birthday DESC) as min_old,
  FIRST_VALUE(communities_users.user_id) OVER(PARTITION BY communities_users.community_id ORDER BY profiles.birthday) as max_old,
  COUNT(communities_users.user_id) OVER(PARTITION BY communities_users.community_id) as in_communities,
  (SELECT count(*) FROM users) as users_total,
  (COUNT(communities_users.user_id) OVER(PARTITION BY communities_users.community_id) / (SELECT count(*) FROM users)*100) as '%%'
FROM communities_users
	JOIN communities ON (communities.id = communities_users.community_id)
	JOIN users ON (users.id = communities_users.user_id)
	JOIN profiles ON (communities_users.user_id=profiles.user_id)
ORDER by id
	;

# Этим я смотрел правильно ли попадают занчения 
SELECT communities_users.*, profiles.birthday FROM communities_users 
	JOIN profiles ON (profiles.id = communities_users.user_id)
WHERE community_id=1;


# 3.7 И среднее кол-во пользовователей в группах 
# У меня не хватило сил это посчитать, надо хорошо потринироваться с ними, уже просто так не понимаю куда тыкаться
# Только вывел сколько группу всего и то селектом...

SELECT DISTINCT communities.id, communities.name,
  (SELECT count(*) FROM communities) as averag_users,
  FIRST_VALUE(communities_users.user_id) OVER(PARTITION BY communities_users.community_id ORDER BY profiles.birthday DESC) as min_old,
  FIRST_VALUE(communities_users.user_id) OVER(PARTITION BY communities_users.community_id ORDER BY profiles.birthday) as max_old,
  COUNT(communities_users.user_id) OVER(PARTITION BY communities_users.community_id) as in_communities,
  (SELECT count(*) FROM users) as users_total,  
  (COUNT(communities_users.user_id) OVER(PARTITION BY communities_users.community_id) / (SELECT count(*) FROM users)*100) as '%%'
FROM communities_users
	JOIN communities ON (communities.id = communities_users.community_id)
	JOIN users ON (users.id = communities_users.user_id)
	JOIN profiles ON (communities_users.user_id=profiles.user_id)
ORDER by id
;

# 3.7 Обявил окна для наглядности, можно наверное и 2-мя обойтись но как раз интерно будет посмотреть скажется ли это на производительности  
SELECT DISTINCT communities.id, communities.name,
  (SELECT count(*) FROM communities) as averag_users,
  FIRST_VALUE(communities_users.user_id) OVER w1 as min_old,
  FIRST_VALUE(communities_users.user_id) OVER w2 as max_old,
  COUNT(communities_users.user_id) OVER w3 as in_communities,
  (SELECT count(*) FROM users) as users_total,  
  (COUNT(communities_users.user_id) OVER w3 / (SELECT count(*) FROM users)*100) as '%%'
FROM communities_users
	JOIN communities ON (communities.id = communities_users.community_id)
	JOIN users ON (users.id = communities_users.user_id)
	JOIN profiles ON (communities_users.user_id=profiles.user_id)
WINDOW w1 AS (PARTITION BY communities_users.community_id ORDER BY profiles.birthday DESC),
       w2 AS (PARTITION BY communities_users.community_id ORDER BY profiles.birthday),
       w3 AS (PARTITION BY communities_users.community_id)
ORDER by id
;


