use VK;

# Переписываем наши запросы на JOIN
# ==============================================================================================================================
# 1. Пусть задан некоторый пользователь.
#    Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим
#    пользоваетелем.
#

# Делаем запрос чтобы узнать ID человека у кого больше всего друзей, для массы :) и в переменную
SET @my_user_id = (SELECT friend_id FROM friendship GROUP BY friend_id ORDER BY COUNT(*) DESC LIMIT 0,1);


# Да, не обратил внимание что сортировку забыл так как смотрел, чтобы у меня ID были правильные
# и у меня оказался порядок правильным случайно 
# Добавил сортировку, это то уже не сложно

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
GROUP by user_id
ORDER BY total_msg DESC
;


# ========================================================================================================
# 2.
# Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.


# Переделал с COUNT, да действительно так же. Я его редко использовал для подсчета чего-то кроме числа строк count(*)
# потому не часто вспоминаю, что он считает собсвтенно то, что передают :(  
SELECT SUM(liked) as total_liked FROM (
	SELECT COUNT(tt.id) as liked 
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

# А вот вариант с JOIN (у меня там есть ещё не определившиеся - потому есть условие с IN 
# ДА У меня там F,M,U
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


# Вариант на чистом JOIN. Да действительно не сложно оказалось совсем
# Добавил ещё данные по своей таблице posts
SELECT users.id,
	COUNT(DISTINCT media.id) +
	COUNT(DISTINCT messages.to_user_id) +
	COUNT(DISTINCT posts.id) +
	COUNT(DISTINCT likes.target_id) AS activity
FROM users
	LEFT JOIN media ON users.id = media.user_id
	LEFT JOIN messages ON users.id = messages.from_user_id
	LEFT JOIN posts ON users.id = posts.user_id
	LEFT JOIN likes ON users.id = likes.user_id	
GROUP BY users.id
ORDER BY activity
LIMIT 10;

