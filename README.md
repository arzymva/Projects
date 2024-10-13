# SqlProjects
# Project 1: Popular Arts.
This is a project about the analysis of popular arts dataset, containing 7 tables. I made analysis with the use of queries containing joins, CTEs, window functions, grouping sets etc.
Here is the sample query from my project, that i wrote to find relationship between artists, their nationalaties and works with the use of grouping sets.

```sql
select
    nationality, 
    full_name, 
    count(work_id) as total_works
from works
join artists on works.artist_id = artists.artist_id
group by
grouping sets (
    (nationality),         -- total works by nationality
    (full_name),         -- total works by artist name
    (nationality, full_name) -- total works by nationality and artist
	)
order by total_works desc;

# Project 2 : Spotify data analysis.
This project contains analysis of a spotify dataset. I made analysis with the use of queries containing case statements, CTEs, window functions etc.
Here is the sample query from my project, that i wrote for finding top 5 most-viewed tracks for each artist with the use of window functions.

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

# Project 3 : Covid dataset analysis.
This is a project i made during the early period of covid-19 pandemic, analyzing the covid dataset. I made analysis with the use of queries containing, CTEs, window functions, views, temporary tables etc. Here is the sample query from my project, that i wrote for ceating view for storing data for later visualizations.

CREATE VIEW PercentPopVaccinated AS 
SELECT death.continent, 
       death.location, 
       death.date, 
       death.population, 
       vac.new_vaccinations, 
       sum(vac.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL; 

