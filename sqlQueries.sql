-- function to display columns

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'spotify';





--SOLVING BUSINESS  QUESTIONS

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT *
FROM spotify
WHERE stream > 1000000000

-- 2. List all albums along with their respective artists.

SELECT DISTINCT album,artist
FROM spotify
ORDER BY 1

-- 3. Get the total number of comments for tracks where `licensed = TRUE`.
SELECT SUM(comments) as total_comments
FROM spotify
WHERE licensed = 'true'

-- 4. Find all tracks that belong to the album type `single`.
SELECT track
from spotify
WHERE album_type = 'single'

-- 5. Count the total number of tracks by each artist.
SELECT artist, COUNT(track)
FROM spotify
group by 1

-- 6. Calculate the average danceability of tracks in each album.
SELECT album, avg(danceability)
FROM spotify
group by 1

-- 7. Find the top 5 tracks with the highest energy values.
SELECT DISTINCT track, AVG(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 8. List all tracks along with their views and likes where `official_video = TRUE`.
SELECT track,views,likes
FROM spotify
where official_video = TRUE

-- 9. For each album, calculate the total views of all associated tracks.
SELECT DISTINCT album,track, sum(views) 
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT track,
		--most_played_on,
		COALESCE(sum(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
		COALESCE(sum(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
group by 1) AS t1
WHERE streamed_on_spotify > streamed_on_youtube AND streamed_on_youtube <> 0

-- 11 Find the top 3 most-viewed tracks for each artist using window functions.
select * from
(
	SELECT artist,
	track,
	SUM(views) as total_views,
	DENSE_RANK() OVER(partition by artist order by SUM(views) desc) as rank
FROM spotify
Group by 1,2 
order by 1, 3 DESC
) x
where x.rank <= 3
-- 12. Write a query to find tracks where the liveness score is above the average.
SELECT track,artist,liveness ,Count(*)-- 0.1936720
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
GROUP BY 1,2,3
HAVING COUNT(*) > 1

-- 13. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
WITH diff AS (
    SELECT album,
           MAX(energy) AS highest_energy,
           MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY album
)

select album,
	(highest_energy - lowest_energy) as energy_diff
FROM diff
ORDER BY 2 DESC

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2

SELECT *
FROM tracks
WHERE (energy / liveness) > 1.2;

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
    track,
    likes,
    views,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM spotify;