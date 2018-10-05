# CSCI 585 - Homework 2

## Creating the tables

Below is the script for creating tables as specified in the assignment. 
The name of the database is `movie_review_app`. 

```sql
-- -----------------------------------------------------
-- Database movie_review_app
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS `movie_review_app` DEFAULT CHARACTER SET utf8 ;
USE `movie_review_app` ;

-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `users` ;

CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NULL,
  `date_of_birth` DATE NULL,
  PRIMARY KEY (`id`))
COLLATE = 'utf8_general_ci'
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `movies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies` ;

CREATE TABLE IF NOT EXISTS `movies` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `genre` VARCHAR(100) NULL,
  `release_date` DATE NULL,
  PRIMARY KEY (`id`))
COLLATE = 'utf8_general_ci'
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `actors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `actors` ;

CREATE TABLE IF NOT EXISTS `actors` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `gender` VARCHAR(100) NULL,
  `date_of_birth` DATE NULL,
  PRIMARY KEY (`id`))
COLLATE = 'utf8_general_ci'
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `reviews`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `reviews` ;

CREATE TABLE IF NOT EXISTS `reviews` (
  `user_id` INT UNSIGNED NOT NULL,
  `movie_id` INT UNSIGNED NOT NULL,
  `rating` INT UNSIGNED NOT NULL,
  `comment` TEXT(5000) NULL,
  PRIMARY KEY (`user_id`, `movie_id`),
  INDEX `fk_reviews_movies1_idx` (`movie_id` ASC),
  CONSTRAINT `fk_reviews_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_movies1`
    FOREIGN KEY (`movie_id`)
    REFERENCES `movies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
COLLATE = 'utf8_general_ci'
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `lead`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lead` ;

CREATE TABLE IF NOT EXISTS `lead` (
  `movie_id` INT UNSIGNED NOT NULL,
  `actor_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`movie_id`, `actor_id`),
  INDEX `fk_lead_actors1_idx` (`actor_id` ASC),
  CONSTRAINT `fk_lead_movies1`
    FOREIGN KEY (`movie_id`)
    REFERENCES `movies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_lead_actors1`
    FOREIGN KEY (`actor_id`)
    REFERENCES `actors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
COLLATE = 'utf8_general_ci'
ENGINE = InnoDB;
```

## Question 1
Name(s) of the user(s) born in April who rated at most 8 for the movie `Notebook`

### Query
```sql
SELECT u.name as 'Actor'
FROM `users` u
INNER JOIN `reviews` r ON r.user_id = u.id
INNER JOIN `movies` m ON r.movie_id = m.id
WHERE MONTH(u.date_of_birth) = '4' 
	AND m.name = 'Notebook'
	AND r.rating <= 8
ORDER BY u.name DESC;
```

### Result

| Actor           | 
|-----------------| 
| "Moyna Acutt"   | 
| "John Doe"      | 
| "Heda Pittford" | 



## Question 2
Find user `John Doe`'s favorite type of movie genre(s) based on his movie ratings

### Query
```sql
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
```

### Result

| Movie                      | Genre  | 
|----------------------------|--------| 
| Doomsday                   | Action | 
| "Pebble and the Penguin"   | Action | 
| "Sentimental Swordsman"    | Action | 
| "Shepherd: Border Patrol"  | Action | 
| "Sons of Katie Elder"      | Action | 
| "Listen to Britain"        | Comedy | 
| "Lot Like Love"            | Comedy | 
| "Nina's Heavenly Delights" | Comedy | 
| "Ninjas vs. Zombies"       | Comedy | 
| "Police Story"             | Comedy | 
| "Repo Man"                 | Comedy | 



## Question 3
List the movie ID(s) with most male lead

### Query
```sql
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
```

### Result

| Movie ID | 
|----------| 
| 4        | 
| 3        | 



## Question 4
List the movie ID(s) with most male lead

### Query
```sql
SELECT m.name as 'Movie'
FROM `reviews` r
INNER JOIN `movies` m ON m.id = r.movie_id
WHERE YEAR(m.release_date) < 2006
	AND m.genre = 'Comedy'
GROUP BY m.id
HAVING AVG(r.rating) > (
	SELECT AVG(average_movie_rating.average)
	FROM
		(SELECT AVG(r.rating) as average
		FROM `reviews` r
		INNER JOIN `movies` m ON m.id = r.movie_id
		GROUP BY m.id) average_movie_rating
)
ORDER BY m.name ASC;
```

### Result

| Movie                | 
|----------------------| 
| "Listen to Britain"  | 
| "Ninjas vs. Zombies" | 
| "Repo Man"           | 



## Question 5
List the movie ID(s) with most male lead

### Query
```sql
SELECT m.id as 'Movie ID', AVG(r.rating) as 'Average Rating'
FROM `movies` m
INNER JOIN `reviews` r ON r.movie_id = m.id
INNER JOIN `lead` l ON l.movie_id = m.id
INNER JOIN `actors` a ON l.actor_id = a.id
WHERE a.name = 'Mark Clarkson'
GROUP BY m.id
HAVING AVG(r.rating) > 9
ORDER BY 'Average Rating' DESC, m.id ASC; 
```

### Result

| "Movie ID" | "Average Rating" | 
|------------|------------------| 
| 3          | 10.0000          | 
| 18         | 9.3333           | 
| 19         | 9.5000           | 
| 20         | 9.5000           | 



## Question 6
List the movie ID(s) with most male lead

### Query
```sql
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
```

### Result

| Actor1          | Actor2       | count | 
|-----------------|--------------|-------| 
| "Mark Clarkson" | "Jack Drake" | 3     | 

