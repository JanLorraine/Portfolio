-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2
order by company, date;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
group by company
order by 2 desc;

SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
group by industry
order by 2 desc;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
group by country
order by 2 desc;

SELECT *
FROM layoffs_staging2;

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
group by YEAR(date)
order by 1 desc;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
group by stage
order by 2 desc;

SELECT SUBSTRING(date, 1,7) AS MONTH, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date, 1,7) IS NOT NULL
group by MONTH
order by 1 asc;

WITH Rolling_Total AS(
SELECT SUBSTRING(date, 1,7) AS MONTH, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(date, 1,7) IS NOT NULL
group by MONTH
order by 1 asc
)

SELECT MONTH,total_off, SUM(total_off) OVER(ORDER BY MONTH) AS rolling_total
FROM Rolling_Total;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
group by company
order by 2 desc;

SELECT company,YEAR(date),  SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(date)
order by 3;

WITH Company_Year (company, years, total_laid_off) AS (
SELECT company,YEAR(date),  SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(date)
) , Company_YEAR_RANK AS
(SELECT *, dense_rank() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL

)
SELECT *
FROM Company_YEAR_RANK
where Ranking <=5;

-- rolling total by country 
SELECT company, country, total_laid_off, sum(total_laid_off) OVER (PARTITION BY country order by company) as rolling_total_by_country
FROM layoffs_staging2
;

WITH rollingTotalByCountry AS (
SELECT country, sum(total_laid_off) AS total_by_country
FROM layoffs_staging2
GROUP BY country
)

SELECT country, total_by_country, sum(total_by_country) over(order by country ) as rolling_total
FROM rollingTotalByCountry;

-- rolling total by industry
SELECT industry, sum(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- highest industry affected per country

SELECT country, industry, sum(total_laid_off) OVER (PARTITION BY country, industry)
FROM layoffs_staging2;

SELECT country, industry, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country, industry
ORDER BY country ;


WITH total_laidoff AS (
SELECT country, industry, sum(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country, industry
ORDER BY country 
), rank_by_industry AS (
SELECT *, rank() OVER (PARTITION BY country ORDER BY total_laid_off DESC) AS rank_by_industry
FROM total_laidoff
), top_5 AS (
SELECT *
FROM rank_by_industry
WHERE rank_by_industry <= 5
)

SELECT industry, count(industry)
FROM top_5
group by industry
order by 2 desc;

