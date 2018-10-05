# CSCI 585 - Homework 2

## Creating the tables

- Below is the script for creating tables as specified in the assignment. 
- The name of the database is `movie_review_app`. 
- For foreign keys, the default action on `DELETE` and `Update` is `CASCADE`.

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
### Requirements
- List name(s) of the user(s) born in April who rated at most 8 for the movie `Notebook`
- Output their names sorted in descending order

### Query
```sql
SELECT u.name as 'Name'
FROM `users` u
INNER JOIN `reviews` r ON r.user_id = u.id
INNER JOIN `movies` m ON r.movie_id = m.id
WHERE MONTH(u.date_of_birth) = '4' 
	AND m.name = 'Notebook'
	AND r.rating <= 8
ORDER BY u.name DESC;
```

### Result

| Name            | 
|-----------------| 
| "Moyna Acutt"   | 
| "John Doe"      | 
| "Heda Pittford" | 

### Explanation
- First, we begin by with the `users` table since we are looking for users' names. 
- Since we need to find the ratings of users on movie *Notebook*, we first need to join tables to find related data. 
- `INNER JOIN` is used to join `reviews` since we only want the results that appear in both `users` and `reviews`. 
- `INNER JOIN` is used to join `movies` since we only want the results that appear in both `movies` and `reviews`. 
- `WHERE MONTH(u.date_of_birth) = '4'` is specified so that we only filter users who has birth month of April. 
- `WHERE m.name = 'Notebook'` is used to filter out join results which apply on movie *Notebook*. 
- `WHERE r.rating <= 8` is used to filter results that are rated at most 8 (which includes 8) by the corresponding user. 
- `ORDER BY u.name DESC` will order the results in descending order by name. 





## Question 2
### Requirements
- Find user `John Doe`'s favorite type of movie genre(s) based on his movie ratings
- List the name(s) and genre(s) of all the movie(s) under this/these movie genre(s)
- Sort the results based on the movie genre then movie name in ascending order

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

### Explanation
- Lets first look at the subquery for finding average ratings of each genre by user named 'John Doe' (towards the bottom of the whole query). 
```sql
(SELECT m.genre, AVG(rating) as average_rating
		FROM `users` u 
		INNER JOIN `reviews` r ON r.user_id = u.id
		INNER JOIN `movies` m ON r.movie_id = m.id
		WHERE u.name = 'John Doe'
		GROUP BY m.genre)
```
Note that `AVG(rating)` is used to find the averages here. This is an aggregate function that will calculate the averages of groups created by the `GROUP BY` clause. This subquery will return a result that looks as below. 

| genre   | average_rating | 
|---------|----------------| 
| Action  | 8.0000         | 
| Comedy  | 8.0000         | 
| Drama   | 2.0000         | 
| Romance | 1.0000         | 

- Then, the max average rating of any genre is calculated by using a `SELECT MAX(genre_ratings.average_rating)` statement. 
- The max value returned here will be 8.0000. The `SELECT MAX()` statement returns a single row and can be used for comparison in `WHERE` clause. 
- The maximum value is used in another subquery in `INNER JOIN` to find genre(s) with the maximum average rating. Assume that the max_rating value is saved into a mysql variable `@max_rating_value`. The `INNER JOIN` clause to find the genres with maximum average rating looks as below. 
```sql
# Partial Query, won't work on its own
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
WHERE genre_ratings.average_rating = @max_rating_value
```
- Now, this `INNER JOIN`, combined with `SELECT DISTINCT` clause will return the list of 'top genres'. In a simplified form, this will look as below: 
```sql
# Partial Query, won't work on its own
SELECT DISTINCT m.genre
	FROM `movies` m
	INNER JOIN `reviews` r ON r.movie_id = m.id
	INNER JOIN `{OUR_SUBQUERY_FROM_PREVIOUS_SECTION}` ON subquery_result.genre = m.genre 
    WHERE genre_ratings.average_rating = @max_rating_value
```
- Once we get the list of 'top genres', we use it to query movie names in those genres. 
```sql
# Partial Query, won't work on its own
SELECT m.name as 'Movie', m.genre as 'Genre'
FROM `movies` m
WHERE m.genre IN ({OUR_SUBQUERY_RESULTS_FOR_TOP_GENRES})
```
- Finally, the result is first ordered by genre, and then movie title in an ascending order. 
`ORDER BY m.genre, m.name ASC`





## Question 3
### Requirements
- List the movie ID(s) with most male lead
- Sort the IDs in descending order. 

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

### Explanation
- Let's begin with the subquery to find counts of male lead actors by each movie. This subquery is **used twice** - first for joining male lead actor count with movies, and second time for finding the max value of male lead actor count. 
```sql
SELECT m.name, COUNT(gender) as count
	FROM `movies` m 
	INNER JOIN `lead` l ON l.movie_id = m.id
	INNER JOIN `actors` a ON l.actor_id = a.id
	WHERE a.gender = 'Male'
	GROUP BY m.id
```
This returns the following result (movie name and count of male lead actors). 

| name                       | count | 
|----------------------------|-------| 
| Cherrybomb                 | 4     | 
| "Shepherd: Border Patrol"  | 6     | 
| "Ninjas vs. Zombies"       | 6     | 
| "Police Story"             | 2     | 
| "Prodigal Son"             | 2     | 
| "Nina's Heavenly Delights" | 1     | 
| "Repo Man"                 | 1     | 
| "Walking on Sunshine"      | 1     | 

- `SELECT MAX(male_lead_count.count)` clause is used to find the maximum count of male lead actors from the above subquery. This returns 6. 
- Once the movies with maximum male lead actor count are found, we select only the ID and order it in descending order. 





## Question 4
- List the name(s) of all comedy movie(s) that were released before 2006
- Those movie(s) must have review rating better than average rating of all movies
- Sort the results in ascending order
- The average rating of all movies is calculated by first finding averages of each movie, and then averaging the averages of each movie. 

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

### Explanation
- Below is the subquery to find average rating of each movie. 
```sql
SELECT AVG(r.rating) as average
	FROM `reviews` r
	INNER JOIN `movies` m ON m.id = r.movie_id
	GROUP BY m.id
```
This returns the averages for each movie as shown below. 

| average | 
|---------| 
| 5.0000  | 
| 2.5000  | 
| 10.0000 | 
| 8.0000  | 
| 6.0000  | 
| 8.0000  | 
| 2.0000  | 
| 6.5000  | 
| 9.3333  | 
| 9.5000  | 
| 9.5000  | 

- These values are once again averaged to find the average of all movies. In current example, it returns 6.9394. 
```sql
# Partial Query, won't work on its own
SELECT AVG(average_movie_rating.average)
FROM '{OUR_SUBQUERY_TO_FIND_AVERAGES_OF_EACH_MOVIE}'
```
- The average of all movies returned in the subquery above is used inside a `HAVING AVG(r.rating) > $average_rating_of_all_movies`. Note that it is not used in a `WHERE` clause. `HAVING` clause must be used here since the results are grouped by movies first. `HAVING` clause is used to filter groups. 
- `WHERE YEAR(m.release_date) < 2006` is used to filter movies that were released before 2006 (does not include 2006). 
- `WHERE m.genre = 'Comedy'` is used to filter movies that are categorized as 'Comedy'. 
- `ORDER BY m.name ASC` is for sorting the results by movie title, ascending. 


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

