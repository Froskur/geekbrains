# 1. ������� ����� ��� ����� ���� ��

# �������, ������� �� ����� �������������� �����
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

# ��� ��� ��� �������� ����������� 

# ����� ������� ������������ ����� �� ������ �� ����� � ���� ����� 
# �������� � ������������ ���� ����� ���� ��������� ��� ����� � ����������
CREATE INDEX idx_emoji_name ON emoji(name);

# media
# ��� ��� ����� ���� �������� �� ������ �� ����, ������� ��� ���������� �������� �����
# ��� ������������. �� � ��� ������ ��� ) 
# �� ����� ����� ����������� �� ����� (��� ��� ��� �� ����� ���������� �� UID �����-����

# profiles
# ��� ��� ����� ������ �����������

# � �� ������ ��� �����, ����������� ��� ���� �� ���� ��������, � �������� ����
# � ����� �������� � ������ �� ����, ��� ��� ��� ������
# �� ������, ��� ��� ������� ��� ������ ����� �������...
CREATE INDEX idx_profiles_birthday_sex ON profiles(birthday,sex);

# � ��������� ������ �� ������, ��� ��� ��� ������� 
CREATE INDEX idx_profiles_hometown ON profiles(hometown);


# users
# ������ ���, ��� ��� �� ������� ���� �������� ����� ������ � �����������
CREATE INDEX idx_users_last_name_first_name ON users(last_name,first_name);
# �� � ��������� �� ��� ����
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);

# ��� ������� ��� ������ ������ ����� ��� ������� �� ��� ��������, ��� ������� ��� ��������� ��������
# � ���� � ������� ���� ���� ���������� ���� �������� � ������� �� � �������� �� ���������� ������� 
# �� ��� ������ ��� ���� ������ c MSSQL � ����� � 36Gb

# ===============================================================================================================
# 2 ������� �� ��������������
# ����������� ��� �������� � �������� ��������� ������: ������ ����������� ������������ � ����������� ������
# ���������-�� �� ��������?
# ����� ���������, ������� ��������������, ����� ������ � ��������� ��
# ����� ����������� �������� �������� ������ ����� �������?

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

# ������� �������� ��� JOIN likes ON media.id = likes.target_id �� �������� ����� ��� ��� 
# ������� ������ ���� ���� �� ���� ����� RIGHT JOIN ����� �������� ��� ��� �� inner ����� 
# ����� � ��� ����� ����, � ����� �� � ��� �������� target_types � users. ������� ���, ������� ����� ������ 
# 
# �� �� ������ ������ �������� )

# ������� ������������ �����, � ������������ ������������� � ����� ������� ���-��� ������  
SELECT media.id,media.user_id,count(*) as total FROM likes 
	JOIN media ON (media.id=likes.target_id) 
WHERE target_type_id=1
GROUP by target_id
ORDER BY total DESC
;

# � ���� ��� ������������ 65 � 5 �������, ��������
# ���������
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

#�Ѹ �� �� ������ �������

# �� ��������������... 
# � ������, �� ���� ����� ��� ����� ��� �������� � ����� ����� ����� ENUM
# �� � ������� �� ����� ������ ��� ��� ��� � Mysql, � ���� �� ���� ������ ����������� ��������
# ��� ������ enum ������� ������� ��� ����� ������ �� 3-4 ������� � ����� � JOIN-��

# �� ��� ������� ����� ������� �� ����� ��� ����� ����� �� ��� ������ ������� � ���, ��� �� ������� ������ ��� ������ ����������
# � ���-�� ��� ����������� ��� ��� ���� �� ����� ������ � ������������� ����� ����� ������ ���������
# ���� ������� ��� ���, �������� �� ������� ���-��� ����� ��� ����� ����� �������

#��� ��� ����� ��� ������� ������� ����� �������� ������. 
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
  
# � �� ��� �������� ���������� ���� ������ �� ��� �� ������� ����� ������ ����� ���������...
# � �������� ���� ��� ���� ������ �� �� ��� ����, � �� ���� ��� ������� ���� target � ����� ���� JSON ���� ������ ����� � ���� {<media.id>:<total_likes>,<media.id>:<total_likes>}
#  � �� ���� ������ ����� �������������
# ��� ��� ��� ������ ������������ ����������� � �����������

# ===================================================================================
# 3. ������� �� ������� �������
# ��������� ������, ������� ����� �������� ��������� �������:
# ��� ������
# ������� ���������� ������������� � �������
# ����� ������� ������������ � ������
# ����� ������� ������������ � ������
# ����� ���������� ������������� � ������
# ����� ������������� � �������
# ��������� � ��������� (����� ���������� ������������� � ������ / ����� ������������� � �������) * 100

# 3.1 ������ ������� �������� (id ��� ��������)
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

# 3.2 ���, ��� ���-�� ����������
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

# 3.3 ���� ������, ������ ����� �������������, � �� ����� ���� ��� ������� ��� ������� ��������
# ����� ��� ���� 
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

# 3.4 � ���������� ������...
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

# 3.5 ������ ������� ����������� � ������������ �������
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


# 3.6 � ����� �������� ��� ���� ������������ � �� ��� �������...
# ������ � ����� ��� ����� ������� ���� ���� ��� �������� � ��������� ������� FIRST_VALUE � LAST_VALUE, ������ ���� ����� ������ ���������� � ����
# �� � ���� ��� �� �����, � �� ����� ����� ������ (

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

# ���� � ������� ��������� �� �������� �������� 
SELECT communities_users.*, profiles.birthday FROM communities_users 
	JOIN profiles ON (profiles.id = communities_users.user_id)
WHERE community_id=1;


# 3.7 � ������� ���-�� ��������������� � ������� 
# � ���� �� ������� ��� ��� ���������, ���� ������ ��������������� � ����, ��� ������ ��� �� ������� ���� ��������
# ������ ����� ������� ������ ����� � �� ��������...

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

# 3.7 ������ ���� ��� �����������, ����� �������� � 2-�� �������� �� ��� ��� ������� ����� ���������� �������� �� ��� �� ������������������  
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


