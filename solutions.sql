-- Netflix Project

CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	int,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)
);

select * from netflix;


select 
	distinct type
from netflix;

-- 15 Business Problems

-- 1. Count the number of Movies vs TV Shows

select 
	type,
	count(*) as Total_Content
from netflix
group by type;


-- 2. Find the most common rating for movies and tv shows
Select
	type,
	rating
From

(select
	type,
	rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as ranking
From Netflix
Group by 1, 2
--order by 1, 3 DESC
) 	as t1
where
	ranking = 1


-- 3. List all movies released in a specific year (e.g., 2020)
-- filter 2020
-- movies

Select * From netflix
where 
	type = 'Movie'
	AND
	release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	      distinct(UNNEST(STRING_TO_ARRAY(country, ', '))) as new_COUNTRY,
		  COUNT(show_id) as Total_Contents
    FROM netflix
	GROUP BY new_COUNTRY
	ORDER BY Total_Contents DESC
	limit 5
	;

-- 5. Identify the longest movie?
select title, max(CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT)) as maximun_lenght
from netflix
where type = 'Movie' and duration is not null
group by 1
order by 2 desc

-- 6. Find content added in the last 5 years

SELECT
	*
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director like '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons

Select *
From netflix
where
	type = 'TV Show'
	AND
	Split_part(duration, ' ',1)::numeric > 5

-- 9. Count the number of content items in each genre

Select
	Unnest(string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix
group by 1

-- 10. Find each year and the average numbers of content release in America on netflix. 
-- Return top 5 year with highest avg content release!


SELECT
  EXTRACT(year FROM to_date(date_added, 'FMMonth DD, YYYY')) AS year,
  COUNT(*) AS content_count,
  COUNT(*)::numeric / SUM(COUNT(*)) OVER () * 100 AS avg_content
FROM netflix
WHERE country LIKE '%India%'
GROUP BY year
ORDER BY avg_content DESC
LIMIT 5;

-- 11. List all the movies that are documentaries

Select * from netflix
Where listed_in ILIKE '%documentaries%'
--ILIKE checks for both upper and lower case D


-- 12. Find all the content without a director 

Select * from netflix
where
	director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT * 
FROM netflix
WHERE 
    casts ILIKE '%Salman Khan%'  -- Ensures Salman Khan is in the cast list
    AND release_year > EXTRACT(YEAR FROM current_date) - 10;  -- Filters movies from the last 10 years

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
    TRIM(unnest(string_to_array(casts, ','))) AS actor,  -- Splits the 'casts' column and removes extra spaces
    COUNT(*) AS total_movies
FROM netflix
WHERE 
    country LIKE '%India%'  -- Filters movies produced in India
    AND type = 'Movie'      -- Ensures only movies are counted
GROUP BY actor
ORDER BY total_movies DESC  -- Sorts by highest number of movies
LIMIT 10;                  -- Limits to the top 10 actors


-- 15. Categorise the content based on the presence of the keywords 'kill' and 'violence' in
-- the description field. Label the content containing these keywords as 'bad' and all other content 
-- as 'good'. Count how many items fall into each category

SELECT 
    COUNT(*) FILTER (WHERE description ILIKE '%kill%' OR description ILIKE '%violence%') AS bad_content,
    COUNT(*) FILTER (WHERE description NOT ILIKE '%kill%' AND description NOT ILIKE '%violence%') AS good_content
FROM netflix;

