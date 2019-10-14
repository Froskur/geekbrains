use VK;

# ������������ ���� ������� �� JOIN
# ==============================================================================================================================
# 1. ����� ����� ��������� ������������.
#    �� ���� ������ ����� ������������ ������� ��������, ������� ������ ���� ������� � �����
#    ��������������.
#
# ��� �������� �� ������� ������ �����, ��� ��� ��� ��� 

# ������ ������ ����� ������ ID �������� � ���� ������ ����� ������, ��� ����� :) � � ����������
SET @my_user_id = (SELECT friend_id FROM friendship GROUP BY friend_id ORDER BY COUNT(*) DESC LIMIT 1);


# ������ ���������� �����, �������� ������� �������� � �������� ������ �������� � �������
# ������ ���� �����
# � ��� ��������� ������� JOIN ���� �����, ��� ��� � ���� JOIN users as u ON (user_id = u.id) ���� ��� ������ ��������� �� ����������
# ���� ����� ��� ��� JOIN ��� ����. �� � ������ ������� ������ ��� JOIN ���� ����, ��� ��� JOIN-��� ������ ��� ������ ��� ������ 
 
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
# ���������� ����� ���������� ������, ������� �������� 10 ����� ������� �������������.
#
# ��� ��� ������ �� SELCET ������ �����, �������� �������� ����� ��� �� ��������� ����
# ������. ������ ��� �����, ����� ���� ����� ����� ID
SELECT target_id,COUNT(*) FROM likes as l
	WHERE target_type_id = 3 && target_id IN (SELECT * FROM(
		SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
	) as sort_prof )
GROUP BY target_id
;

# ������� ����� ������ ��� �� ����� ��� �� ���������� ��� ����, � � ���� �� ��������� ������������� �������, ������� �� �������� �����
# ������� ����� ��� �� � ���� ����� �����, �� ����� � ��� ����� ���� ������... 
# �������� ����� ������ ����������� ������� profiles
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

# ���������� �������... �� � ������ ��� ������ ��� ������� ������ ��� ���������� �������, ����� ���� ������ - ���� ��� ������ :)
# ����� ����� � ������� ��  
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
# ���������� ��� ������ �������� ������ (�����) - ������� ��� �������?
# ��� ����� �� ����� ��� ������ ����� ������ �������� :)
SELECT sex,total FROM (
	SELECT "M" as sex, COUNT(*) as total FROM likes WHERE user_id IN (SELECT user_id FROM profiles as p WHERE sex='M')
	UNION
	SELECT "F" as sex, COUNT(*) as total FROM likes WHERE user_id IN (SELECT user_id FROM profiles as p WHERE sex='F')
) as my_sort
ORDER BY total DESC
;

# � ��� ������� � JOIN (� ���� ��� ���� ��� �� �������������� - ������ ���� ������� � IN 
SELECT p.sex, COUNT(p.sex) as total FROM likes as l 
	JOIN profiles as p ON (p.id = l.user_id && p.sex IN ('F','M'))
GROUP by p.sex
ORDER BY total DESC
;



# ============================================================================================================
# 4.
# ����� 10 �������������, ������� ��������� ���������� ���������� � ������������� ����������
# ����.

# �� ����������� �� ����� �������� ���������:
# - � ���� ������ ����� ������ ����������
# - ������ ����� ����� ��������� ������ �������������
# - ������ ����� �������� � ������� (��������� � �������)
# - ��� �� ������ �����
# 
# ����� ������� ��� ������ ���������, ������� ���� - ��� 1 �������� ���������� � ���������� ����� �� �������� �� �����
# ���� �����������. ������, ��� � ������������ ����� ������ �� ���� ������, ��������� ��� ��� ����-��.
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


# � ������ �� JOIN. � ������ ������ �� ���� ��� ������� ��� ����� �� JOIN ���, ��� ����� ���� ������������ ����� ����� ������� JOIN
# ������ �������, � ��� ���������� ��� ��� ����� JOIN-���� �� �������, � ������ ����� �� ���
# �������� ����������, ��� ��� ��� ������ ������� ���������� ����� ���������� ����� activite
# ��� ������� �� �������� ������ 
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

# � ��� ������ �������, ����� ������� ��� �� ������ 0-�� �������������, � ���������� �� � �����, ���� ��� ����
# �����. ��� ������ ����� ���� ���������� �������� �������� 
# ����� ��� �� ������� �������� ����� ���� ������� ������������������

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
