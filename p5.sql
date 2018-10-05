SELECT m.id as movie_id, AVG(r.rating) as average_reviews
FROM `movies` m
INNER JOIN `reviews` r ON r.movie_id = m.id
INNER JOIN `lead` l ON l.movie_id = m.id
INNER JOIN `actors` a ON l.actor_id = a.id
WHERE a.name = 'Mark Clarkson'
GROUP BY m.id
HAVING AVG(r.rating) > 9
ORDER BY average_reviews DESC, m.id ASC; 