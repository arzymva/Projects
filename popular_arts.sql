-- basic data analysis. artists and their works.

select works.name, 
	   artists.full_name from artists
inner join works on works.artist_id = artists.artist_id;

--ranking artists by their works using window functions.

select full_name, count(work_id) as total_works,
       rank() over (order by count(work_id) desc) as artist_rank
from artists
inner join works on works.artist_id = artists.artist_id
group by full_name;

--relationship between artists, their nationalaties and works with the use of grouping sets.

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

--artists, their lifespan and the number of works with the use of CTE.

with artist_life as (
select
	    artist_id,
        full_name,
        birth,
        death,
        (death-birth) as lifespan
from artists
where death is not null
and birth is not null
), 
artist_works as (
select 
        artist_id,
        count(work_id) as total_works
from works
group by artist_id
)
select
    al.full_name,
    al.birth,
    al.death,
    al.lifespan,
    aw.total_works
from artist_life al
left join artist_works aw on al.artist_id = aw.artist_id
order by al.lifespan desc;


-- Works by art stiles.

select count(works.name),
       works.style,
       artists.full_name
from artists
inner join works on works.artist_id = artists.artist_id
where works.style is not null
group by works.style, artists.full_name
order by 1, 3;

--size & sales relationship.
with size_revenue as (
select 
        cs.size_id,
        avg(ps.sale_price) as average_sale_price
from canvas_size cs
join product_size ps on cs.size_id = ps.size_id
group by cs.size_id
),
work_revenue as (
select
        ps.work_id,
        avg(ps.sale_price) as average_sales,               
        avg(ps.regular_price) as average_regular_price,   
        (avg(ps.regular_price) - avg(ps.sale_price)) as price_difference 
from product_size ps
group by ps.work_id
)
select
    sr.size_id,
    sr.average_sale_price,
    wr.work_id,
    wr.average_sales,
    wr.price_difference
from size_revenue sr
join product_size ps on sr.size_id = ps.size_id
join work_revenue wr on ps.work_id = wr.work_id 
order by sr.size_id, wr.average_sales desc;

--museums and operating hours.

select distinct(name), open, close
from museums 
join museum_hours on museums.museum_id = museum_hours. museum_id
order by 1;

--average opening hours for each museum by day of the week.

with daily_hours as (
select 
        mh.museum_id,
        mh.day,
        avg(extract(hour from (mh.close - mh.open))) as avg_open_hours 
from museum_hours mh
group by mh.museum_id, mh.day
)
select
    m.name,
    dh.day,
    dh.avg_open_hours
from daily_hours dh
join museums m on dh.museum_id = m.museum_id
order by m.name, dh.avg_open_hours desc; 

--subject popularity.

select 
    s.subject,
    count(w.work_id) as work_count
from subjects s
join works w on s.work_id = w.work_id
group by s.subject
order by work_count desc;

--average sale prices by subject.

select
    s.subject,
    avg(ps.sale_price) as avg_sale_price
from subjects s
join works w on s.work_id = w.work_id
join product_size ps on w.work_id = ps.work_id
group by s.subject
order by avg_sale_price desc;













