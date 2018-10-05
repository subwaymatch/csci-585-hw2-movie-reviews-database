SELECT l1.actor_name as Actor1, l2.actor_name as Actor2, COUNT(l1.actor_id) as 'count'
FROM 
	(
		SELECT l.movie_id, l.actor_id, a.name as actor_name
        FROM `lead` l
        INNER JOIN `actors` a ON l.actor_id = a.id
    ) l1
INNER JOIN
	(
		SELECT l.movie_id, l.actor_id, a.name as actor_name
        FROM `lead` l
        INNER JOIN `actors` a ON l.actor_id = a.id
    ) l2 ON l1.movie_id = l2.movie_id
INNER JOIN `actors` a ON l1.actor_id = a.id
WHERE l1.actor_id < l2.actor_id
GROUP BY l1.actor_id, l2.actor_id
HAVING COUNT(l1.actor_id) = (
	SELECT COUNT(l1.actor_id) as 'count'
	FROM `lead` l1
	INNER JOIN `lead` l2 ON l1.movie_id = l2.movie_id
	INNER JOIN `actors` a ON l1.actor_id = a.id
	WHERE l1.actor_id < l2.actor_id
	GROUP BY l1.actor_id, l2.actor_id
	ORDER BY 'count' DESC
	LIMIT 1
)