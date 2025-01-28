-- data clearning
SELECT *
FROM layoffs;
CREATE TABLE layoffs_staging
like layoffs;
Insert layoffs_staging
SELECT *
FROM layoffs;
SELECT *
FROM layoffs_staging;

-- remove duplicates
WITH duplicates_cte AS
(
SELECT *,
ROW_NUMBER() over(partition by company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
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
ROW_NUMBER() over(partition by company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- standarize data
SELECT company, trim(company)
FROM layoffs_staging2;
UPDATE layoffs_staging2
SET company = trim(company);
SELECT company 
FROM layoffs_staging2;
SELECT *
FROM layoffs_staging2
WHERE industry like 'Crypto%';

Update layoffs_staging2
SET industry='Crypto'
Where industry like 'Crypto%';
SELECT distinct country, trim(trailing '.' from country)
FROM layoffs_staging2
order by 1;
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';
Select distinct country
from layoffs_staging2
order by 1;
SELECT `date`, str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_staging2;
update layoffs_staging2
set `date`= str_to_date(`date`,'%m/%d/%Y');
select *
from layoffs_staging2;
alter table layoffs_staging2
modify column `date` DATE;

-- NULL or blank values
select *
FROM layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry is NULL or t1.industry ='')
AND (t2.industry IS NOT NULL and t2.industry != '');
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is NULL or t1.industry ='')
AND (t2.industry IS NOT NULL and t2.industry != '');
SET SQL_SAFE_UPDATES = 0;

-- Remove some rows
SELECT *
FROM layoffs_staging2;
ALter table layoffs_staging2
DROP COLUMN row_num;
