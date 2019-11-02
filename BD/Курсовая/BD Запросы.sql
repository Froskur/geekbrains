use kinopoisk;

# Так, для затравки смотрим филмы с жанрама и сортирвкой оп бюджету 
SELECT films.id, GROUP_CONCAT(genre.name) as ganres,films.budget FROM films_genres 
	JOIN films ON (films.id = films_genres.film_id)
	JOIN genre ON (genre.id = films_genres.genre_id)
GROUP by films.id
ORDER BY films.budget desc
;

# Получаем самые рейтинговые фильмы cо средним рейтингом вышедшие в этом году  
SELECT ratings.film_id, films.original_name, (SUM(rating)/COUNT(user_id)) as final_reting FROM ratings
	JOIN films ON (films.id = ratings.film_id)
WHERE films.release_of LIKE '2019%'	
GROUP BY film_id
ORDER BY (SUM(rating)/COUNT(user_id)) DESC
;

# тоже рейтинг, но ограничиваемся жанром    
SELECT ratings.film_id, films.original_name, (SUM(rating)/COUNT(user_id)) as final_reting 
FROM ratings
	JOIN films ON (films.id = ratings.film_id)
	JOIN films_genres ON (films_genres.film_id = films.id)
	JOIN genre ON (genre.id = films_genres.genre_id && genre.name="Триллер")
WHERE films.release_of LIKE '2019%'	
GROUP BY film_id
ORDER BY (SUM(rating)/COUNT(user_id)) DESC
;

# Делаем запрос по людям (число фильмов у всех два, так как у меня так заполнилась таблица)
# собираем только актореров которые играли главные роли и выводим кого они играли в фильмах за 90-эх годов 
# и считаем сколько ролей у них было в фильме
  
SELECT CONCAT(people.first_name," ",people.last_name) as acter, people.birthday, count(DISTINCT films_people.film_id) as count_films, 
       GROUP_CONCAT(DISTINCT roles.name), count(who_plays.title) 
FROM films_people 
	JOIN people ON (people.id = films_people.people_id)
	JOIN roles ON (roles.id = films_people.role_id AND roles.name="Актер")
	JOIN people_who_plays ON (people_who_plays.films_people_id = films_people.id AND people_who_plays.type_role='main')
	JOIN who_plays ON (people_who_plays.who_plays_id = who_plays.id)
	JOIN films ON (films.id = films_people.film_id AND films.release_of>='1990-01-01' and films.release_of<='1999-12-31')
GROUP by films_people.people_id
order by people.birthday DESC
;