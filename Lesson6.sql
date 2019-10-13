use VK;

# Проверяя запросы из урока на всоей базе мне пришлось пересоздать ID на фото, так как у меня там всего 300 записей
UPDATE profiles SET photo_id = FLOOR(1 + (RAND() * 301));

# Все остальные запросы у меня отработали хорошо, с небольшими правками по статусу так как у меня там их больше
# 

# ==============================================================================================================================
# 1. Пусть задан некоторый пользователь.
#    Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим
#    пользоваетелем.

# Делаем запрос чтобы узнать ID человека у кого больше всего друзей, для массы :) и в переменную
SET @my_user_id = (SELECT friend_id FROM friendship GROUP BY friend_id ORDER BY COUNT(*) DESC LIMIT 1);

# А так мы быстро сможем менять параметры по стаутсу дружбы, так как у нас их всего три и если какой-то нам не важен мы ставим ему NULL
SET @my_status1  = 'frends';
SET @my_status2  = 'family';
SET @my_status3  = NULL;     #'block';

# 1.1
# Это запрос чтобы понять с каким из пользотвателей наш общался больше всего, без привязки к дружбе  
SELECT user_id FROM (
	(SELECT to_user_id as user_id, COUNT(*) as message_total FROM messages WHERE from_user_id = @my_user_id GROUP BY to_user_id)
	UNION ALL
	(SELECT from_user_id as user_id, COUNT(*) as message_total FROM messages WHERE to_user_id = @my_user_id GROUP BY from_user_id)
) as my_tmp_table
GROUP by user_id
ORDER BY SUM(message_total) DESC
;

# 1.2 А это наш запрос для того чтобы посмотреть все ID пользователей, которых мы должны проверять
# С котороми подружился сам пользователей и те пользователи которые позвали нашего дружить
(SELECT user_id FROM friendship 
	WHERE friend_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
)			
UNION
(SELECT friend_id FROM friendship 
	WHERE user_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
);

#
# Теперь объеденяем в финальный запрос...
#
SELECT user_id FROM (
	(SELECT to_user_id as user_id, COUNT(*) as message_total FROM messages WHERE from_user_id = @my_user_id GROUP BY to_user_id)
	UNION ALL
	(SELECT from_user_id as user_id, COUNT(*) as message_total FROM messages WHERE to_user_id = @my_user_id GROUP BY from_user_id)
) as my_tmp_table
WHERE user_id IN (
	(SELECT user_id FROM friendship 
		WHERE friend_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
	)			
	UNION
	(SELECT friend_id FROM friendship 
		WHERE user_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
	)
)
GROUP by user_id
ORDER BY SUM(message_total) DESC
LIMIT 1
;

#Я ещё думал усложнить и посмотреть, а кто из них входит в общие группы, и это тоже считать каким-то весом в общении
# и взаимные лайки тоже можно считать но не стал этого пока делать так, так мне показалось через чур сложно делать это в SQL

# Но вот пример запроса, где мы смотрим колл-во общих групп в которых присутсвуюет наш пользователей и кто-то из его друзей 
SELECT *,SUM(IF(user_id=@my_user_id,0,1)) as common_communites FROM communities_users 
WHERE community_id IN (SELECT community_id FROM communities_users as cu WHERE user_id = @my_user_id) && 
	  user_id IN (		
		(SELECT user_id
		FROM friendship 
		WHERE friend_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
		)			
		UNION
		(SELECT friend_id
			FROM friendship 
			WHERE user_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
		)
		UNION
		(SELECT @my_user_id)
	  )
GROUP BY user_id ORDER BY common_communites DESC	  
;

# ========================================================================================================
# 2.
# Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
#

# 2.1 Так мы получили все медиа, которые есть у 10 самых мололых пользователей
# прочитал про хитрую обертку селект в селект - не знал, чтобы сработал лимит  
SELECT * FROM media 
	WHERE user_id IN (
		SELECT * FROM (
			SELECT user_id FROM profiles ORDER by birthday DESC LIMIT 10
		) as user_id		
	)
;

# собственно финальный запрос тип медиа игнорируем, так как нам он не важен 
SELECT count(*) as total_likes FROM media as m WHERE id IN (
	SELECT id FROM media 
	WHERE user_id IN (
		SELECT * FROM (
			SELECT user_id FROM profiles ORDER by birthday DESC LIMIT 10
		) as user_id		
	)
)
;


# =========================================================================================================
# 3 
# Определить кто больше поставил лайков (всего) - мужчины или женщины?
# тут стало по проще уже писать после первых запросов :)
SELECT sex FROM (
	SELECT "M" as sex, COUNT(*) as total FROM likes WHERE user_id IN (SELECT user_id FROM profiles as p WHERE sex='M')
	UNION
	SELECT "F" as sex, COUNT(*) as total FROM likes WHERE user_id IN (SELECT user_id FROM profiles as p WHERE sex='F')
) as my_sort
ORDER BY total DESC
LIMIT 1
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

# 4.1 Так посчитали активность по меди файлом. Без сортировки, чтобы не тратить тут на неё время вся сортировка в объеденяющем запросе
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM media GROUP by user_id))
UNION
(SELECT user_id as id, COUNT(*) as activite FROM media as m GROUP by user_id)
;

# 4.2 кто писал сообщения. Нам нужны только инициаторы. Кто сам писал, а не кому писали
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT from_user_id FROM messages GROUP by from_user_id))
UNION
(SELECT from_user_id as id, COUNT(*) as activite FROM messages GROUP by from_user_id)
;

# 4.3 Теперь сообщения в группах
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM posts GROUP by user_id))
UNION
(SELECT user_id as id, COUNT(*) as activite FROM posts GROUP by user_id)
;

# 4.4 И кто не ставит лайки 
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM likes GROUP by user_id))
UNION
(SELECT user_id as id, COUNT(*) as activite FROM likes GROUP by user_id)
;

#
# Собсвтенно итоговый запрос, который объеденяет все данные и сортирует 
# я не стал вытаскивать фио пользователя, чтобы не пихать всю эту конструкцию ещё в один селек через обертку
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

