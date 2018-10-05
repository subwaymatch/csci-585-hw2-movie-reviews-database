SELECT DISTINCT m.id
FROM `movies` m
LEFT JOIN `lead` l ON l.movie_id = m.id
LEFT JOIN `actors` a ON l.actor_id = a.id
LEFT JOIN 
	(SELECT m.name as name, COUNT(gender) as count
			FROM `movies` m 
			LEFT JOIN `lead` l ON l.movie_id = m.id
			LEFT JOIN `actors` a ON l.actor_id = a.id
			WHERE a.gender = 'Male'
			GROUP BY m.name
	) movie_male_lead_count
    ON movie_male_lead_count.name = m.name
WHERE movie_male_lead_count.count = 
	(SELECT MAX(male_lead_count.count)
	FROM
		(SELECT m.name, COUNT(gender) as count
			FROM `movies` m 
			LEFT JOIN `lead` l ON l.movie_id = m.id
			LEFT JOIN `actors` a ON l.actor_id = a.id
			WHERE a.gender = 'Male'
			GROUP BY m.name) male_lead_count)
ORDER BY m.id DESC;