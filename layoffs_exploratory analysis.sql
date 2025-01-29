-- Exploratory data analysis
-- Check the max total_laid off and percentage_laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
From layoffs_staging2;

-- Check all information when percentage_laid_off is 1, and descending the funds_raided_millions
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER by funds_raised_millions DESC;

-- Check each company the whole laid off number
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 DESC;

-- Check the laid off duration
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Check each industry the whole laid off number
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by industry
ORDER BY 2 DESC;

-- Check each country the whole laid off number
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by country
ORDER BY 2 DESC;

-- Check each year the whole laid off number
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
order by 1 DESC;

-- Check each month(not null) the whole laid off number
SELECT substring(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

-- Check each month the whole laid off number and rolling each month laid off number
WITH rolling_total_off AS
(SELECT substring(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC)
SElect `month`, total_off, SUM(total_off) over (order by `month`) AS rolling_total_off
FROM rolling_total_off;

-- Check each company the whole laid off number and show the industry
SELECT company, industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,industry
ORDER by 3 DESC;

-- Check each company and each year the total laid off number
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER by 3 DESC;

-- Check each year the top 5 laid off company.
WITH Company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_year_ranking AS
(
SELECT *,
dense_rank() over(partition by years order by total_laid_off DESC) AS Ranking
FROM Company_year
WHere years is not null
)
Select *
FROM Company_year_ranking
where ranking <= 5;

