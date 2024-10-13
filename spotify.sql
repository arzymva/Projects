DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- Exploratory Data Analysis(EDA)

Select count(*) from spotify;

Select count(distinct artist) from spotify;

select distinct album_type from spotify;

select avg(danceability) from spotify;

select max(duration_min) from spotify;

select min(duration_min) from spotify;    --it returns 0 and the song can't last 0 minutes. So i go further and check it.

select * from spotify 
where duration_min = 0;

delete from spotify
where duration_min = 0;     --now these songs are deleted.

----- Basic data analysis on dataset.

select * from spotify
where stream > 1000000000;

select distinct album, artist
from spotify
order by 1;

select sum(comments) as total_comments
from spotify
where licensed  = 'true';

select * from spotify
where album_type ILIKE 'single';

select artist, count(*) as total_songs
from spotify
group by artist 
order by 2;

select album, avg(danceability)
from spotify
group by album
order by 2 desc;

select track from spotify
order by energy 
limit 10;

select 
	track, 
	sum(views) as total_views, 
	sum(likes) as total_likes
from spotify
where official_video ='true'
group by 1
order by 2 desc;

select album, track, sum(views)
from spotify
group by 1, 2
order by 3 desc;

--medium level data analysis on dataset.

--finding tracks, that streamed more in spotify than youtube.

select * from (select 
	track,
    coalesce(sum(case when most_played_on = 'Youtube' then stream end), 0) as streamed_on_youtube,
    coalesce(sum(case when most_played_on = 'Spotify' then stream end), 0) as streamed_on_spotify
    from spotify
    group by track) as streams_table
where 
	streamed_on_spotify > streamed_on_youtube
    and 
    streamed_on_youtube <> 0;

--advanced data analysis on dataset.

-- 1. Finding top 5 most-viewed tracks for each artist with the use of window functions.

with artist_ranking as
(select 
	track, 
	artist, 
	sum(views) as total_views,  
    dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1, 2
order by 2, 3 desc
)
select * from artist_ranking
where rank <= 5;

--2.finding tracks where liveness is above the average.

select artist, track, liveness
from spotify
where liveness > ( select avg(liveness) from spotify);

--3.finding difference between highest and lowest energy values for tracks in each album.

with energy_levels as
(select album, 
		max(energy) as highest_energy,        
		min(energy) as lowest_energy
from spotify
group by album
)
select album, 
       highest_energy - lowest_energy as difference
from energy_levels 
order by 2 desc;
