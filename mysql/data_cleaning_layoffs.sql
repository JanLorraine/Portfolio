-- DATA CLEANING

-- 1. Remove Duplicates
-- 2. Standardize Data (check for wrong spellings, categorization?)
-- 3. Null values or blank values
-- 4. Remove irrelevant columns 
  
  
-- Create a duplicate table to not modify the original table which will be used as a reference

CREATE TABLE layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- 1. Remove Duplicates
-- Finding duplicates by adding row numbers and looking at row numbers that are greater than one.

SELECT *, row_number() over(order by company)
FROM layoffs_staging;

WITH duplicate_cte AS(
SELECT *, row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE company like '%casper%'
;
-- Delete the duplicated rows
WITH duplicate_cte AS(
SELECT *,
row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- Create a new table
DROP TABLE IF EXISTS `layoffs_staging2`;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2 
SELECT *,
row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing data by finding mispelling using distict in every column 
SELECT *
FROM layoffs_staging2;

SELECT distinct industry
FROM layoffs_staging2
order by 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States_';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%crypto%';

SELECT distinct country
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States_';

SELECT *
FROM layoffs_staging2;

-- setting the date column from text to date
SELECT date,
str_to_date(date, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = str_to_date(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- 3. Null values or blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- finding null in industry column and joining the table to itself where table 1 industry column has null values and table 2 does not, since there are companies that are the same but some rows does not indicate the industry it is in

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ' ';

SELECT *
FROM layoffs_staging2
WHERE company = 'airbnb';

SELECT t1.industry , t2.industry, t1.company ,t2.company
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- 4. Remove irrelevant columns 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off	IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off	IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN	 row_num;