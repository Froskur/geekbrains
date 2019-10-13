use VK;

# �������� ������� �� ����� �� ����� ���� ��� �������� ����������� ID �� ����, ��� ��� � ���� ��� ����� 300 �������
UPDATE profiles SET photo_id = FLOOR(1 + (RAND() * 301));

# ��� ��������� ������� � ���� ���������� ������, � ���������� �������� �� ������� ��� ��� � ���� ��� �� ������
# 

# ==============================================================================================================================
# 1. ����� ����� ��������� ������������.
#    �� ���� ������ ����� ������������ ������� ��������, ������� ������ ���� ������� � �����
#    ��������������.

# ������ ������ ����� ������ ID �������� � ���� ������ ����� ������, ��� ����� :) � � ����������
SET @my_user_id = (SELECT friend_id FROM friendship GROUP BY friend_id ORDER BY COUNT(*) DESC LIMIT 1);

# � ��� �� ������ ������ ������ ��������� �� ������� ������, ��� ��� � ��� �� ����� ��� � ���� �����-�� ��� �� ����� �� ������ ��� NULL
SET @my_status1  = 'frends';
SET @my_status2  = 'family';
SET @my_status3  = NULL;     #'block';

# 1.1
# ��� ������ ����� ������ � ����� �� �������������� ��� ������� ������ �����, ��� �������� � ������  
SELECT user_id FROM (
	(SELECT to_user_id as user_id, COUNT(*) as message_total FROM messages WHERE from_user_id = @my_user_id GROUP BY to_user_id)
	UNION ALL
	(SELECT from_user_id as user_id, COUNT(*) as message_total FROM messages WHERE to_user_id = @my_user_id GROUP BY from_user_id)
) as my_tmp_table
GROUP by user_id
ORDER BY SUM(message_total) DESC
;

# 1.2 � ��� ��� ������ ��� ���� ����� ���������� ��� ID �������������, ������� �� ������ ���������
# � �������� ���������� ��� ������������� � �� ������������ ������� ������� ������ �������
(SELECT user_id FROM friendship 
	WHERE friend_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
)			
UNION
(SELECT friend_id FROM friendship 
	WHERE user_id = @my_user_id && status_id IN (SELECT id FROM friendship_statuses WHERE (name = @my_status1 || name = @my_status2 || name = @my_status3))
);

#
# ������ ���������� � ��������� ������...
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

#� ��� ����� ��������� � ����������, � ��� �� ��� ������ � ����� ������, � ��� ���� ������� �����-�� ����� � �������
# � �������� ����� ���� ����� ������� �� �� ���� ����� ���� ������ ���, ��� ��� ���������� ����� ��� ������ ������ ��� � SQL

# �� ��� ������ �������, ��� �� ������� ����-�� ����� ����� � ������� ������������ ��� ������������� � ���-�� �� ��� ������ 
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
# ���������� ����� ���������� ������, ������� �������� 10 ����� ������� �������������.
#

# 2.1 ��� �� �������� ��� �����, ������� ���� � 10 ����� ������� �������������
# �������� ��� ������ ������� ������ � ������ - �� ����, ����� �������� �����  
SELECT * FROM media 
	WHERE user_id IN (
		SELECT * FROM (
			SELECT user_id FROM profiles ORDER by birthday DESC LIMIT 10
		) as user_id		
	)
;

# ���������� ��������� ������ ��� ����� ����������, ��� ��� ��� �� �� ����� 
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
# ���������� ��� ������ �������� ������ (�����) - ������� ��� �������?
# ��� ����� �� ����� ��� ������ ����� ������ �������� :)
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

# 4.1 ��� ��������� ���������� �� ���� ������. ��� ����������, ����� �� ������� ��� �� �� ����� ��� ���������� � ������������ �������
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM media GROUP by user_id))
UNION
(SELECT user_id as id, COUNT(*) as activite FROM media as m GROUP by user_id)
;

# 4.2 ��� ����� ���������. ��� ����� ������ ����������. ��� ��� �����, � �� ���� ������
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT from_user_id FROM messages GROUP by from_user_id))
UNION
(SELECT from_user_id as id, COUNT(*) as activite FROM messages GROUP by from_user_id)
;

# 4.3 ������ ��������� � �������
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM posts GROUP by user_id))
UNION
(SELECT user_id as id, COUNT(*) as activite FROM posts GROUP by user_id)
;

# 4.4 � ��� �� ������ ����� 
(SELECT id,0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM likes GROUP by user_id))
UNION
(SELECT user_id as id, COUNT(*) as activite FROM likes GROUP by user_id)
;

#
# ���������� �������� ������, ������� ���������� ��� ������ � ��������� 
# � �� ���� ����������� ��� ������������, ����� �� ������ ��� ��� ����������� ��� � ���� ����� ����� �������
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

