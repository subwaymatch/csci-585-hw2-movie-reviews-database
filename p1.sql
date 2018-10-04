SELECT u.name
FROM `users` u
LEFT JOIN `reviews` r ON r.user_id = u.id
LEFT JOIN `movies` m ON r.movie_id = m.id
WHERE MONTH(u.date_of_birth) = '4' 
	AND m.name = 'Notebook'
	AND r.rating <= 8
ORDER BY u.name DESC;