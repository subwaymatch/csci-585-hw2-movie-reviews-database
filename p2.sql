# Select movies under favorite genre(s)
SELECT m.name as 'Movie', m.genre as 'Genre'
FROM `movies` m
WHERE m.genre IN (
	# Select top genres
	SELECT DISTINCT m.genre
	FROM `movies` m
	INNER JOIN `reviews` r ON r.movie_id = m.id
	INNER JOIN 
		(
			SELECT m.genre as genre, AVG(rating) as average_rating
			FROM `users` u 
			INNER JOIN `reviews` r ON r.user_id = u.id
			INNER JOIN `movies` m ON r.movie_id = m.id
			WHERE u.name = 'John Doe'
			GROUP BY m.genre
		) genre_ratings 
		ON genre_ratings.genre = m.genre
	WHERE genre_ratings.average_rating = (
		SELECT MAX(genre_ratings.average_rating) 
		FROM
			(SELECT m.genre, AVG(rating) as average_rating
				FROM `users` u 
				INNER JOIN `reviews` r ON r.user_id = u.id
				INNER JOIN `movies` m ON r.movie_id = m.id
				WHERE u.name = 'John Doe'
				GROUP BY m.genre) genre_ratings)
			)
	ORDER BY m.genre, m.name ASC;