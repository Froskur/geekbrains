use kinopoisk;

#�������� �������, ��� ��� ��������� ������� ����� ������������ � ����� ��������, �� ������� ���-�� ������ �����,
#��� ����� �������� � ������

#�������� ID ������� ��������� �����, ��������������� �� ������ ������������� ������� � ���� ������ ������� ����� ������
DROP FUNCTION IF EXISTS top_films_viewpoint_user;

DELIMITER //

CREATE FUNCTION top_films_viewpoint_user (count_top INT, genre_name VARCHAR(255))
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN	
	RETURN (
		SELECT GROUP_CONCAT(id) FROM (
			SELECT films.id,films.premiere_world,SUM(IF(reviews.rhesus="+",1,IF(reviews.rhesus="-",-1,0))) as user_raitings 
				FROM films
				JOIN reviews ON (films.id=reviews.film_id)
				JOIN films_genres ON (films.id=films_genres.film_id)
				JOIN genre ON (films_genres.genre_id=genre.id && genre.name LIKE genre_name)
			GROUP BY id
			ORDER BY user_raitings DESC, premiere_world
			LIMIT count_top
		) as tmp)
	;
END//

DELIMITER ;

#��������� 
SELECT top_films_viewpoint_user(5,'������');

SELECT top_films_viewpoint_user(5,'%�����%');

#�, ������, �������, ��� ��� ���������, �� ���. ������ �� ������� ID ������. 
#� ����� ������ ����� ���������?
SELECT * FROM films WHERE id IN (top_films_viewpoint_user(5,'������'));


# ��� ��-�� ������ ������� �� ��� �� ���� �� ���� � ����� ������� �� ����������� � ����������� � ���������
# ����� � ���� �����-�� ��������, ������ ����� ��� ��� ����������� � ������������ � MSSQL

# ������ ��������� ������ �����������, ��������� ���������� ���� ��������� � ��������������� �������
# � ������ ����� ����������, � �� ������ ����� ����� ���������� ������� 
DROP PROCEDURE IF EXISTS films_budgets_counts;

DELIMITER //

CREATE PROCEDURE films_budgets_counts (INOUT number_films INT, IN film_budget INT, IN small_or_high CHAR(1))
BEGIN
CASE small_or_high
WHEN 's' THEN
	SELECT COUNT(id) INTO number_films FROM films WHERE budget<=film_budget;		
WHEN 'h' THEN  
	SELECT COUNT(id) INTO number_films FROM films WHERE budget>=film_budget;		
ELSE 
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Last parametr need set 's' or 'h'";
END CASE;
END//

DELIMITER ;

# ���-�� ������� � �������� ������ 1�
CALL films_budgets_counts(@my_count,1000000,'s');
SELECT @my_count;

# ���-�� ������� � �������� ������ 60�
CALL films_budgets_counts(@my_count,60000000,'h');
SELECT @my_count;

#������ 
CALL films_budgets_counts(@my_count,60000000,'r');

