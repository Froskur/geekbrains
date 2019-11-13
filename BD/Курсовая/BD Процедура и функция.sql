use kinopoisk;

#Создание функции, так как результат функции можно использовать в новых запросах, то сделаем что-то именно такое,
#что можно вставить в запрос

#Получает ID фильмов заданного жанра, отсортированных по уровню положительных отзывов и дате выхода сначала более старые
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

#Проверяем 
SELECT top_films_viewpoint_user(5,'Боевик');

SELECT top_films_viewpoint_user(5,'%Мульт%');

#я, кстати, подумал, что так сработает, но нет. Только по первому ID выдает. 
#А можно кстати чтобы сработало?
SELECT * FROM films WHERE id IN (top_films_viewpoint_user(5,'Боевик'));


# Вот из-за вечных проблем то так не могу то этак я лично никогда не сталкивался с процедурами и функциями
# вечно с ними какие-то проблемы, только разве что для оптимизации и реиндексация в MSSQL

# Потому процедура совсем простенькая, посчитаем количество мало бюджетных и высокобюджетных фильмов
# Я сделал через переменную, а не просто через вывод результата запроса 
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

# Кол-во фильмов с бюджетом меньше 1М
CALL films_budgets_counts(@my_count,1000000,'s');
SELECT @my_count;

# Кол-во фильмов с бюджетом больше 60М
CALL films_budgets_counts(@my_count,60000000,'h');
SELECT @my_count;

#Ошибка 
CALL films_budgets_counts(@my_count,60000000,'r');

