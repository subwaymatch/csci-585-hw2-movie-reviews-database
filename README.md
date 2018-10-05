# CSCI 585 - Homework 2
**Submitter:** Ye Joo Park (USC# 1128685151)<br>
**USCID:** yejoopar@usc.edu<br><br>
This report was written in Github-flavored markdown. 

## Sample Data / Assumptions

- For sample data used in this homework, please refer to **Appendix A**. 
- For genders, strings 'Male' and 'Female' are used (in PascalCase, not lowercase). 
- For string types (user name, actor name, movie title, movie genre, and etc..), we assume that it is at maximum 100 characters in length. Therefore, a `VARCHAR(100)` type is used. 


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
- List movie ID(s) and average review(s) where the average is higher than 9
- On of the leading actor is 'Mark Clarkson'
- Sort output by average reviews and then movie IDs.
** I've assumed that average reviews are shown in a descending order (since we normally want to show movies with highest ratings first). On the contrary, movie IDs are ordered in ascending order. 

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

### Explanation
- First, we join `movies`, `reviews`, `lead`, and `actors` tables and calculate averages using `AVG(r.rating)` function. 
- We want to get the averages of each movie. `GROUP BY m.id` is used to group our joined result by movie IDs. Running an aggregate function (`AVG()` in this case) will be applied to each group individually. 
- Since we only want movies where 'Mark Clarkson' appeared, a `WHERE a.name = 'Mark Clarkson'` clause is used to filter the results. 
- We need to find movies with average rating higher than 9. Since we are comparing an aggregated value (average), `HAVING` clause is used. 
- Finally, `ORDER BY 'Average Rating' DESC, m.id ASC` is used to sort the results by average rating first (in a descending order since we usually want to show higher ratings first), and then by movie id in an ascending order. 





## Question 6
- Find the actors who played the lead together the most
- Display their names and the number of times they played the lead together

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

### Explanation 
- To make the explanation simple, please take a look at the simplified query to find count of all occurences of playing together in a movie between two actors. 
```sql
SELECT l1.actor_id as 'Actor ID 1', l2.actor_id as 'Actor ID 2', COUNT(l1.actor_id) as 'count'
FROM `lead` l1
INNER JOIN `lead` l2 ON l1.movie_id = l2.movie_id
WHERE l1.actor_id < l2.actor_id
GROUP BY l1.actor_id, l2.actor_id
```
The `lead` table is inner joined with itself, and grouped by actor 1 and actor 2. The result format of this simplified query is shown below. 

| "Actor ID 1" | "Actor ID 2" | count | 
|--------------|--------------|-------| 
| 1            | 2            | 3     | 
| 1            | 3            | 1     | 
| 2            | 3            | 2     | 
| 2            | 4            | 1     | 

- Since the desired result requires actors' names, `lead` tables are joined with `actors` table. 
```sql
SELECT l.movie_id, l.actor_id, a.name as actor_name
FROM `lead` l
INNER JOIN `actors` a ON l.actor_id = a.id
```
This will result in a `lead` table with actor names appended to the right. 

| movie_id | actor_id | actor_name      | 
|----------|----------|-----------------| 
| 3        | 1        | "Mark Clarkson" | 
| 16       | 1        | "Mark Clarkson" | 


- We only need the actors who played the lead together the most. To find the pair that has appeared the most, we first need to find the max value of co-appearances. 
```sql
SELECT COUNT(l1.actor_id) as 'count'
FROM `lead` l1
INNER JOIN `lead` l2 ON l1.movie_id = l2.movie_id
INNER JOIN `actors` a ON l1.actor_id = a.id
WHERE l1.actor_id < l2.actor_id
GROUP BY l1.actor_id, l2.actor_id
ORDER BY 'count' DESC
LIMIT 1
```
This returns 3 in our example. 

- The max co-appearance count calculated above is used in `HAVING` clause to filter aggregated results. 
- In this query, we need to group first by actor 1, and actor 2 (`GROUP BY l1.actor_id, l2.actor_id`). 
- Grouping without a `WHERE` constraint will result in duplicate values (where actor1 and actor2 are simply swapped), and have values where actor1 = actor2. To avoid this redundancies, a `WHERE l1.actor_id < l2.actor_id` filter is added. 
- The results will show actor names that are grabbed from the `INNER JOIN`ed `lead` tables. 





## Appendix A - Sample Data used for queries above

## Users

| id | name                  | date_of_birth | 
|----|-----------------------|---------------| 
| 1  | "John Doe"            | 1991-04-16    | 
| 2  | "Heda Pittford"       | 1989-04-07    | 
| 3  | "Charmian Tackell"    | 1999-04-29    | 
| 4  | "Moyna Acutt"         | 1985-04-20    | 
| 5  | "Barrett Asplin"      | 1978-06-20    | 
| 6  | "Sher Buzine"         | 1951-05-18    | 
| 7  | "Dre Mumm"            | 1996-01-25    | 
| 8  | "Valentina Tough"     | 1941-07-20    | 
| 9  | "Dalston Gornall"     | 1987-09-17    | 
| 10 | "Bibbie Leffek"       | 1982-11-30    | 
| 11 | "Daile Lynthal"       | 2001-01-11    | 
| 12 | "De Stranaghan"       | 1985-10-20    | 
| 13 | "Beniamino Oakenfall" | 1971-02-14    | 
| 14 | "Skell Bull"          | 1984-02-19    | 
| 15 | "Kassey Murkitt"      | 1991-11-27    | 
| 16 | "Hermione Kalkofen"   | 1968-03-26    | 
| 17 | "Almeria MacKaig"     | 2000-03-25    | 
| 18 | "Rufe Tidey"          | 1981-10-29    | 
| 19 | "Raimondo Gardiner"   | 1984-06-07    | 
| 20 | "Barbee Brozek"       | 1985-10-13    | 




### Movies

| id | name                                               | genre   | release_date | 
|----|----------------------------------------------------|---------|--------------| 
| 1  | Notebook                                           | Romance | 2004-08-11   | 
| 2  | Cherrybomb                                         | Drama   | 2007-09-23   | 
| 3  | "Shepherd: Border Patrol"                          | Action  | 2006-03-22   | 
| 4  | "Ninjas vs. Zombies"                               | Comedy  | 2004-04-03   | 
| 5  | "Pebble and the Penguin"                           | Action  | 1984-04-23   | 
| 6  | "Think Fast, Mr. Moto"                             | Drama   | 1975-08-08   | 
| 7  | "Sentimental Swordsman"                            | Action  | 2018-03-13   | 
| 8  | "Baby-Sitters Club, The"                           | Drama   | 1971-03-19   | 
| 9  | "Mystic Masseur"                                   | Drama   | 1974-06-20   | 
| 10 | "Sons of Katie Elder"                              | Action  | 1990-06-13   | 
| 11 | Doomsday                                           | Action  | 2006-12-08   | 
| 12 | "Listen to Britain"                                | Comedy  | 1990-10-29   | 
| 13 | "Lot Like Love"                                    | Comedy  | 2017-03-09   | 
| 14 | "Sunset Strip"                                     | Romance | 2010-06-01   | 
| 15 | "Friday the 13th Part VIII: Jason Takes Manhattan" | Drama   | 1957-11-17   | 
| 16 | "Police Story"                                     | Comedy  | 2016-08-23   | 
| 17 | "Prodigal Son"                                     | Drama   | 1943-07-14   | 
| 18 | "Nina's Heavenly Delights"                         | Comedy  | 2006-08-14   | 
| 19 | "Repo Man"                                         | Comedy  | 2000-08-18   | 
| 20 | "Walking on Sunshine"                              | Romance | 1968-01-25   | 



### Reviews

| user_id | movie_id | rating | comment                                                              | 
|---------|----------|--------|----------------------------------------------------------------------| 
| 1       | 1        | 1      | "I hate romance"                                                     | 
| 1       | 2        | 2      | "Drama is okay"                                                      | 
| 1       | 3        | 10     | "I like actions, and this is perfect"                                | 
| 1       | 4        | 8      | "Very funny"                                                         | 
| 1       | 5        | 6      | "Too bollywoodish"                                                   | 
| 2       | 1        | 8      | "Pretty good"                                                        | 
| 2       | 2        | 3      | "Typical drama, wouldn't watch again"                                | 
| 3       | 1        | 9      | "Very nice"                                                          | 
| 3       | 3        | 10     | "I would consider to be the best action in the history of mankind. " | 
| 4       | 1        | 4      | Perfecto!!                                                           | 
| 4       | 3        | 10     | "NOW I KNOW WHY PEOPLE ARE CRAZY ABOUT THIS"                         | 
| 5       | 1        | 3      | "One of the worst"                                                   | 
| 6       | 12       | 8      | "a British comedy that makes all of us laugh.  "                     | 
| 6       | 14       | 2      | "Why is this even made?"                                             | 
| 10      | 17       | 5      | "Overhyped. Overpriced. "                                            | 
| 11      | 17       | 8      | "Not as good as the anticipation, but not bad at all. "              | 
| 12      | 18       | 10     | "Would watch a 100 times"                                            | 
| 15      | 18       | 9      | "Laughed all night long"                                             | 
| 16      | 18       | 9      | "One of the most memorable comedies of 2006"                         | 
| 17      | 19       | 9      | "Almost perfect"                                                     | 
| 17      | 20       | 10     | Perfect                                                              | 
| 18      | 19       | 10     | "THE MASTERPIECE of all times"                                       | 
| 18      | 20       | 9      | "Better lovestory than twilight"                                     | 



### Actors

| id | name              | gender | date_of_birth | 
|----|-------------------|--------|---------------| 
| 1  | "Mark Clarkson"   | Male   | 1958-01-11    | 
| 2  | "Jack Drake"      | Male   | 2004-04-20    | 
| 3  | "Micheal Ballham" | Male   | 1999-09-25    | 
| 4  | "Belford Durling" | Male   | 1998-04-26    | 
| 5  | "Ben Coulthard"   | Male   | 1996-03-17    | 
| 6  | "Erl Adamczyk"    | Male   | 1964-10-01    | 
| 7  | "Pavel Pigot"     | Male   | 1942-05-03    | 
| 8  | "Rufe Normadell"  | Male   | 1991-05-10    | 
| 9  | "Toby Tregenza"   | Male   | 1959-07-28    | 
| 10 | "Leonard Levy"    | Male   | 2007-11-01    | 
| 11 | "Fishay Winkell"  | Female | 1941-03-06    | 
| 12 | "Delcina Rapsey"  | Female | 1956-02-09    | 
| 13 | "Chasey Meekan"   | Female | 1960-05-05    | 
| 14 | "Tracey Radbone"  | Female | 1955-08-16    | 
| 15 | "Angela Towler"   | Female | 1989-01-20    | 
| 16 | "Idelle Upham"    | Female | 1968-11-26    | 
| 17 | "Shelba Smyley"   | Female | 2008-03-09    | 
| 18 | "Nicolle Poel"    | Female | 2003-03-21    | 
| 19 | "Lorrie Brodie"   | Female | 1948-10-21    | 
| 20 | "Helaine Itzig"   | Female | 1957-02-26    | 



### Lead

| movie_id | actor_id | 
|----------|----------| 
| 1        | 14       | 
| 1        | 16       | 
| 1        | 18       | 
| 1        | 20       | 
| 2        | 4        | 
| 2        | 6        | 
| 2        | 8        | 
| 2        | 10       | 
| 3        | 1        | 
| 3        | 2        | 
| 3        | 3        | 
| 3        | 5        | 
| 3        | 7        | 
| 3        | 9        | 
| 4        | 2        | 
| 4        | 3        | 
| 4        | 4        | 
| 4        | 5        | 
| 4        | 6        | 
| 4        | 7        | 
| 16       | 1        | 
| 16       | 2        | 
| 17       | 1        | 
| 17       | 2        | 
| 18       | 1        | 
| 19       | 1        | 
| 20       | 1        | 
