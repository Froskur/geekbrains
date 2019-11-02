use kinopoisk;

# Ќовинки за последний год 
DROP VIEW IF EXISTS view_top_new_films;

CREATE VIEW view_top_new_films AS 
  (SELECT films.id, films.original_name, GROUP_CONCAT(genre.name) as ganres,films.premiere_world FROM films_genres 
		JOIN films ON (films.id = films_genres.film_id)
		JOIN genre ON (genre.id = films_genres.genre_id)
	WHERE TO_DAYS(NOW()) - TO_DAYS(films.premiere_world) <= 365	
	GROUP by films.id
	ORDER BY films.premiere_world desc
   );

  
# Top мультфильмов дл€ детей до 12 лет с указанием режиссера
DROP VIEW IF EXISTS view_animation_for_children;

CREATE VIEW view_animation_for_children AS 
  (SELECT films.id, films.original_name, GROUP_CONCAT(DISTINCT genre.name) as ganres, films.premiere_world, 
	   (SUM(ratings.rating)/COUNT(ratings.user_id)) as total_reting,SUM(ratings.rating), COUNT(ratings.user_id) 
		FROM films_genres 
				JOIN films ON (films.id = films_genres.film_id)
				JOIN genre ON (genre.id = films_genres.genre_id && genre.name="ћультфильм")
				JOIN ratings ON (ratings.film_id = films.id)
		WHERE films.rating_old <= 12	
		GROUP by films.id
		ORDER BY total_reting DESC
   );


# “ригеры не стал делать уже совсем скучно, так как высасываешь из пальца...
# врпочем, один сделал, дл€ рейтинга в самом фильме чтобы не тащить из базы 
  
#1 ƒобав€лем поле в фильмы
ALTER TABLE kinopoisk.films ADD rating_users FLOAT DEFAULT 0 NOT NULL COMMENT '–ейтинг фильма, обновл€етс€ через тригер';

#2. ƒобовл€ем тригер на таблицу с рейтингами 
# ” мен€ были сложности с добавлением тригера, потом € добавл€л через DBever, почему ту разедлитель не мен€лс€, но в конечном итоге € его вставил
DROP TRIGGER IF EXISTS kinopoisk.trg_ratings_insert;
DROP TRIGGER IF EXISTS kinopoisk.trg_ratings_update;
DROP TRIGGER IF EXISTS kinopoisk.trg_ratings_delete;

DELIMITER //

CREATE TRIGGER `trg_ratings_insert` AFTER INSERT ON `ratings` FOR EACH ROW BEGIN
 UPDATE films SET rating_users=(
 		SELECT SUM(ratings.rating)/COUNT(ratings.user_id) FROM ratings WHERE film_id=NEW.film_id
 	) 
 WHERE films.id=NEW.film_id;
END//


CREATE TRIGGER `trg_ratings_update` AFTER UPDATE ON `ratings` FOR EACH ROW BEGIN
 UPDATE films SET rating_users=(
 		SELECT SUM(ratings.rating)/COUNT(ratings.user_id) FROM ratings WHERE film_id=NEW.film_id
 	) 
 WHERE films.id=NEW.film_id;
END//

CREATE TRIGGER `trg_ratings_delete` AFTER DELETE ON `ratings` FOR EACH ROW BEGIN
 UPDATE films SET rating_users=(
 		SELECT SUM(ratings.rating)/COUNT(ratings.user_id) FROM ratings WHERE film_id=NEW.film_id
 	) 
 WHERE films.id=NEW.film_id;
END//


DELIMITER ;

# 3. ѕроврер€ем было значение 0 - если данные только залиты , в конце стало 7.3333, как и было
INSERT INTO ratings (id,film_id,user_id,ratings) VALUES (501,267,12,5);
SELECT rating_users FROM films WHERE id=267;

UPDATE ratings SET rating=8 WHERE id=501;

SELECT rating_users FROM films WHERE id=267;

DELETE FROM ratings WHERE id=501;

SELECT rating_users FROM films WHERE id=267;

