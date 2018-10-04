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
  `movies_id` INT UNSIGNED NOT NULL,
  `actors_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`movies_id`, `actors_id`),
  INDEX `fk_lead_actors1_idx` (`actors_id` ASC),
  CONSTRAINT `fk_lead_movies1`
    FOREIGN KEY (`movies_id`)
    REFERENCES `movies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_lead_actors1`
    FOREIGN KEY (`actors_id`)
    REFERENCES `actors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
COLLATE = 'utf8_general_ci'
ENGINE = InnoDB;