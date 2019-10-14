use VK;

# Переписываем наши запросы на JOIN
# ==============================================================================================================================
# 1. Пусть задан некоторый пользователь.
#    Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим
#    пользоваетелем.
#
# Тут проверку по статусу дружбы убрал, так как она там 

# Делаем запрос чтобы узнать ID человека у кого больше всего друзей, для массы :) и в переменную
SET @my_user_id = (SELECT friend_id FROM friendship GROUP BY friend_id ORDER BY COUNT(*) DESC LIMIT 1);


# Запрос прикольный вышел, пришлось конечно попотеть и пописать разные варианты с дружбой
# дальше было проще
# И что интересно порядок JOIN тоже важен, так как у меня JOIN users as u ON (user_id = u.id) если его первым поставить не применялся
# хотя вроде все для JOIN там есть. Но с другой стороны хорошо что JOIN этот ниже, так как JOIN-нит только уже нужные нам строки 
 
SELECT IF(m.from_user_id != @my_user_id,m.from_user_id,m.to_user_id) as user_id, 
       CONCAT(u.first_name," ",u.last_name) as name, 
	   COUNT(IF(m.from_user_id != @my_user_id,m.from_user_id,m.to_user_id)) as total_msg
FROM messages as m 	
	JOIN friendship as f 
		ON (((m.from_user_id = f.user_id   && f.friend_id = @my_user_id) || 
		    (m.from_user_id = f.friend_id && f.user_id   = @my_user_id) ||
			(m.to_user_id   = f.user_id   && f.friend_id = @my_user_id) || 
			(m.to_user_id   = f.friend_id && f.user_id   = @my_user_id)
		))
	JOIN friendship_statuses as fs ON (f.status_id = fs.id)
	JOIN users as u ON (user_id = u.id)
	WHERE (from_user_id = @my_user_id || to_user_id = @my_user_id) && fs.name != 'block'
	GROUP BY user_id
	LIMIT 1
;



# ========================================================================================================
# 2.
# Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
#
# Вот так запрос на SELCET просто будет, пришлось написать иначе мне не проверить свои
# данные. сделал без суммы, чтобы было видно какие ID
SELECT target_id,COUNT(*) FROM likes as l
	WHERE target_type_id = 3 && target_id IN (SELECT * FROM(
		SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
	) as sort_prof )
GROUP BY target_id
;

# сначала начал делать так но понял что не поссчитать мне итог, и к тому же пропустил пользователей молодых, которые не получили лайки
# Вообщем понял что не с того конца пошел, но может и тут можно было дожать... 
# наверное через правое объединение таблицы profiles
SELECT l.target_id as id, 
	   #CONCAT(u.first_name," ",u.last_name) as name,
	   COUNT(*),
	   p.birthday
    FROM likes as l 
		JOIN target_types as tt ON (tt.id = l.target_type_id && tt.name='user')
		#JOIN users as u ON (l.target_id = u.id)
		JOIN profiles as p ON (l.target_id = p.id)
	GROUP BY l.target_id
	ORDER BY p.birthday DESC
	LIMIT 10
;

# правильный вариант... но я сломал всю голову как сложить строки без вложенного селекта, может есть способ - буду рад узнать :)
# может будет в разборе ДЗ  
SELECT SUM(liked) as total_liked FROM (
	SELECT SUM(IF(tt.id IS NULL,0,1)) as liked 
	FROM profiles as p
		LEFT JOIN likes as l ON (p.id=l.target_id)
		LEFT JOIN target_types as tt ON (tt.id=l.target_type_id && tt.name='user')
	#WHERE tt.id IS NOT NULL
	GROUP by p.id
	ORDER BY p.birthday DESC
	LIMIT 10
) as tmp_table
;


# =========================================================================================================
# 3 
# Определить кто больше поставил лайков (всего) - мужчины или женщины?
# тут стало по проще уже писать после первых запросов :)
SELECT sex,total FROM (
	SELECT "M" as sex, COUNT(*) as total FROM likes WHERE user_id IN (SELECT user_id FROM profiles as p WHERE sex='M')
	UNION
	SELECT "F" as sex, COUNT(*) as total FROM likes WHERE user_id IN (SELECT user_id FROM profiles as p WHERE sex='F')
) as my_sort
ORDER BY total DESC
;

# А вот вариант с JOIN (у меня там есть ещё не поределившиеся - потому есть условие с IN 
SELECT p.sex, COUNT(p.sex) as total FROM likes as l 
	JOIN profiles as p ON (p.id = l.user_id && p.sex IN ('F','M'))
GROUP by p.sex
ORDER BY total DESC
;



# ============================================================================================================
# 4.
# Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной
# сети.

# По активностью мы будем понимать следующее:
# - у кого меньше всего файлов закгружено
# - меньше всего пишут сообщений другим пользователям
# - меньше всего общаются в группах (сообщений в группах)
# - кто не ставит лайки
# 
# будем считать что каждое сообщение, какждый файл - это 1 счетчику активности и определять самых не активных по сумме
# всех показателей. Помним, что у пользователя может вообще не быть файлов, сообщений или ещё чего-то.
#
SELECT id, SUM(activite) as total_activite FROM (
	SELECT * FROM (
		(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM media GROUP by user_id))
		UNION
		(SELECT user_id as id, COUNT(*) as activite FROM media as m GROUP by user_id)
	) as tmp_media
	UNION ALL
	SELECT * FROM (
		(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT from_user_id FROM messages GROUP by from_user_id))
		UNION
		(SELECT from_user_id as id, COUNT(*) as activite FROM messages GROUP by from_user_id)
	) as tmp_messages
	UNION ALL
	SELECT * FROM (
		(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM posts GROUP by user_id))
		UNION
		(SELECT user_id as id, COUNT(*) as activite FROM posts GROUP by user_id)	
	) as tmp_posts
	UNION ALL
	SELECT * FROM (
		(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM likes GROUP by user_id))
		UNION
		(SELECT user_id as id, COUNT(*) as activite FROM likes GROUP by user_id)
	) as tmp_likes	
) as tmp_table
GROUP by id
ORDER by total_activite
LIMIT 10
;


# А теперь на JOIN. Я честно говоря не вижу как сделать это чисто на JOIN так, как всегд идет перемножение строк после второго JOIN
# потому посидел, и мне показалось что эту чисто JOIN-нами не сделать, с какого конца не иди
# Концовка отличается, так как тут другая немного сортировка строк получается после activite
# Это заметно по последнй записи 
SELECT id, SUM(activite) as total_activite FROM (
	(SELECT u.id, COUNT(m.user_id) as activite 
		FROM users as u LEFT JOIN media as m ON (m.user_id=u.id) GROUP BY u.id)
	UNION ALL 
	(SELECT u.id, COUNT(m.from_user_id) as activite 
		FROM users as u LEFT JOIN messages as m ON (m.from_user_id=u.id) GROUP BY u.id)
	UNION ALL
	(SELECT u.id, COUNT(p.user_id) as activite 
		FROM users as u LEFT JOIN posts as p ON (p.user_id=u.id) GROUP BY u.id)
	UNION ALL
	(SELECT u.id, COUNT(l.user_id) as activite 
		FROM users as u LEFT JOIN likes as l ON (l.user_id=u.id) GROUP BY u.id)	
) as temp_tbl
GROUP by id
ORDER by total_activite
LIMIT 10
;

# А это второй вариант, чтобы какждый раз не тянуть 0-ых пользователей, а проставить их в конце, если они есть
# вдруг. Это хорошо видно если заремарить половину запросов 
# думаю что на больших выборках может быть змаетна производительность

SELECT IF(temp_tbl2.id IS NULL,users.id,temp_tbl2.id) as id,
	   CONCAT(users.first_name," ",users.last_name) as name,
	   IF(temp_tbl2.total_activite IS NULL,0,temp_tbl2.total_activite) as total_activite	
FROM (
	SELECT id, SUM(activite) as total_activite FROM (
		(SELECT u.id, COUNT(m.user_id) as activite 
			FROM users as u JOIN media as m ON (m.user_id=u.id) GROUP BY u.id)
		UNION ALL 
		(SELECT u.id, COUNT(m.from_user_id) as activite 
			FROM users as u JOIN messages as m ON (m.from_user_id=u.id) GROUP BY u.id)
		UNION ALL
		(SELECT u.id, COUNT(p.user_id) as activite 
			FROM users as u JOIN posts as p ON (p.user_id=u.id) GROUP BY u.id)
		UNION ALL
		(SELECT u.id, COUNT(l.user_id) as activite 
			FROM users as u JOIN likes as l ON (l.user_id=u.id) GROUP BY u.id)	
	) as temp_tbl
	GROUP by id
) as temp_tbl2
RIGHT JOIN users ON (users.id=temp_tbl2.id)
ORDER by total_activite
LIMIT 10
;
