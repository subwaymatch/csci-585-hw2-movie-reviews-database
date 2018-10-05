SELECT DISTINCT m.id as 'Movie ID'
FROM `movies` m
INNER JOIN `lead` l ON l.movie_id = m.id
INNER JOIN `actors` a ON l.actor_id = a.id
INNER JOIN 
	(SELECT m.name as name, COUNT(gender) as count
			FROM `movies` m 
			INNER JOIN `lead` l ON l.movie_id = m.id
			INNER JOIN `actors` a ON l.actor_id = a.id
			WHERE a.gender = 'Male'
			GROUP BY m.id
	) movie_male_lead_count
    ON movie_male_lead_count.name = m.name
WHERE movie_male_lead_count.count = 
	(SELECT MAX(male_lead_count.count)
	FROM
		(SELECT m.name, COUNT(gender) as count
			FROM `movies` m 
			INNER JOIN `lead` l ON l.movie_id = m.id
			INNER JOIN `actors` a ON l.actor_id = a.id
			WHERE a.gender = 'Male'
			GROUP BY m.id) male_lead_count)
ORDER BY m.id DESC;