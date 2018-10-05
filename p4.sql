SELECT m.name
FROM `reviews` r
LEFT JOIN `movies` m ON m.id = r.movie_id
WHERE YEAR(m.release_date) < 2006
	AND m.genre = 'Comedy'
GROUP BY m.name
HAVING AVG(r.rating) > (
	SELECT AVG(average_movie_rating.average)
	FROM
		(SELECT AVG(r.rating) as average
		FROM `reviews` r
		LEFT JOIN `movies` m ON m.id = r.movie_id
		GROUP BY m.id) average_movie_rating
)
ORDER BY m.name ASC;