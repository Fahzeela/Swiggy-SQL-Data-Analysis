use swiggy_analysis
-----------------------
----import the data into the database
---- view the table 
select*from swiggy;
-------------------------
-- insight no 1 
-- how many cyties is swiggy operating in
select 
distinct(city) as city_present
from swiggy;
---------------------------
select 
count(distinct(city)) as city_count
from swiggy;
---------------------------
--insight no 2
--how many restaurents are registered with swiggy
select 
count(distinct(restaurant)) as restaurant_count
from swiggy;
----------------------------------------
--insight no 3
---avg price overall
select
round(avg(price),2) as avg_price
from swiggy;
------------------------------------
---insight no 4
--avg price for each restaurant
select restaurant,avg(price)as avg_price
from swiggy group by restaurant;
-----------------------------
---insight no 5
---top 20 highest avg_priced restaurants 
select top(20)* from (select restaurant,avg(price)as avg_price
from swiggy group by restaurant) a order by avg_price desc;
-------------------------------------
-- insight no 6
--- count of restaurant in each city
select city,count(restaurant)as citywise_count
from swiggy group by city order by citywise_count desc;
----------------------------------
--insight no 7 
--top 5 cities with hight no of restaurant
select top(5)* from (select city,count(restaurant)as citywise_count
from swiggy group by city ) a order by citywise_count desc;
------------------------------------------
---insight no 8
---which city has the highest avg restaurant rating
select top(1)* from (select city,round (avg(avg_ratings),2) as citywise_rating
from swiggy group by city) a order by citywise_rating desc;
--------------------------------------------------------
--9
-----------its city wise restaurant based on rating
select city,round(avg(avg_ratings),2) as citywise_rating
from swiggy group by city,restaurant order by citywise_rating desc;
--------------------------------------------
--10
----top 10 restaurant in each city based on avg ratings
---dense rank/partision by
with cte as (select city,restaurant, avg_ratings as citywise_rating,
dense_rank () over (partition by city order by avg_ratings desc)as dr from swiggy)
select*from cte where dr<=5;
--------------------------------------------------------------------------
--11
--which city has the fastest avg delivery time 
-- top 10 hights -rated restaurant with at least 1000 rating
select restaurant,total_ratings from swiggy where total_ratings >=1000
order by avg_ratings desc;
--------------------------------------------------
--12
-- top 10 most expensive restaurant
-- top 5 most expensive restaurant in each city
with 
cte1 as(select restaurant,price, dense_rank ()
over(order by price desc)as dr from swiggy), 
cte2 as (select city,restaurant, price,dense_rank() 
over (partition by city order by price desc) as dr from swiggy)
--- select*from ctel where dr <= 10
select*from cte2 where dr<=5;
----------------------------------------------------------
--13
--restaurant with the highest popularity
--popularity score=avg_rating*total rating
select top(10)* from (select restaurant, avg_ratings*total_ratings as 
popularity_score from swiggy) a order by popularity_score desc;
------------------------------------------------------
--14
--over rated restaurant
--high rating but very low revenue counts
--avg_rating>4 and total_rating < 100
select restaurant, avg_ratings, total_ratings from swiggy
where avg_ratings >=4.5 and total_ratings < 100
order by avg_ratings desc, total_ratings;
--------------------------------------------------
--15
-- restaurant with above average ratings but below average review count
select restaurant, avg_ratings, total_ratings from swiggy where avg_ratings>
        (select avg(avg_ratings) from swiggy) and
        total_ratings < (select avg (total_ratings) from swiggy);
------------------------------------------------------------
--16
---under rated above average rating and above average review count
--- price bands
--- < 200 budget | < 200- 500 mid range | > 500 - preniun
select case when price<= 200 then 'budget' 
when price <= 500 then 'mid range'
else 'premiun'
end as price_band, round(avg(avg_ratings),2)as avg_ratings, 
count(*) as testaurant_count
from swiggy group by case when price <= 200 then 'budget'
when price <= 500 then 'mid range'
else 'premiun' end order by avg_ratings desc;
--17
-- Premium restaurants with poor ratings
-- high priced not meeting expectations
-- price > avg price and avg ratings > overall avg rating 
-- high demand ares ???
select city, area, sum(total_ratings) as total_review from swiggy 
group by city, area order by city, total_review desc; 

--17
--city contribution to total reviews
with cityreview as (select city, sum(total_ratings) reviews from swiggy
group by city) select city, reviews, round( reviews*100.0/sum(reviews) over(), 2) as per_con 
from cityreview;

--18
--top 20% restaurants by popularity 
with ctel as ( select *, ntile (5) over
(order by total_ratings desc) as popularity_group from swiggy)
select*from ctel where popularity_group=1;


