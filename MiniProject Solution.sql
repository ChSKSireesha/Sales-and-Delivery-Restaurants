create database MiniProject;
use MiniProject;

#1) Find the top 3 customers who have the maximum number of orders
select cd.customer_name, count(mf.ord_id) as order_count
from cust_dimen as cd
join market_fact as mf
on cd.cust_id = mf.cust_id
join orders_dimen as od
on mf.ord_id = od.ord_id
group by cd.customer_name
order by order_count desc
limit 3 ;

#2) Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select order_date, ship_date, abs(order_date - ship_date) as DaysTakenForDelivery
from shipping_dimen as sd
join market_fact as mf
on sd.ship_id = mf.ship_id
join orders_dimen as od
on mf.ord_id = od.ord_id;

#3)  Find the customer whose order took the maximum time to get delivered.
select customer_name, max(abs(order_date - ship_date)) as maxDaysTakenForDelivery
from cust_dimen as cd
join market_fact as mf
on cd.cust_id = mf.cust_id
join orders_dimen as od
on mf.ord_id = od.ord_id
join shipping_dimen as sd
on mf.ship_id = sd.ship_id
group by cd.customer_name
order by maxDaysTakenForDelivery desc;


#4) Retrieve total sales made by each product from the data (use Windows function)

select product_category,
sum(sales) over(partition by product_category) as total_sales
from prod_dimen as pd
left join market_fact as mf
on pd.prod_id = mf.prod_id;

select product_category,
sum(sales) as total_sales
from prod_dimen as pd
left join market_fact as mf
on pd.prod_id = mf.prod_id
group by product_category;

#5) Retrieve the total profit made from each product from the data (use windows function)
select product_category,
sum(profit) over(partition by product_category) as total_profit
from prod_dimen as pd
left join market_fact as mf
on pd.prod_id = mf.prod_id;

#6) Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
select count(distinct cd.cust_id) as total_customers_in_january
from cust_dimen as cd
join market_fact as mf
on cd.cust_id = mf.cust_id
join orders_dimen as od
on mf.ord_id = od.ord_id
where (year(STR_TO_DATE(od.order_date, '%Y-%m-%d'))) = 2011 and (month(STR_TO_DATE(od.order_date, '%Y-%m-%d'))) = 1;

select count(distinct cd.cust_id) as total_customers_came_back_every_month
from cust_dimen as cd
join market_fact as mf
on cd.cust_id = mf.cust_id
join orders_dimen as od
on mf.ord_id = od.ord_id
where year(STR_TO_DATE(od.order_date, '%Y-%m-%d')) = 2011
having count(distinct month(STR_TO_DATE(od.order_date, '%Y-%m-%d'))) = 12;

# 7)  We need to find out the total visits to all restaurants under all alcohol categories available.
select count(upayment) as total_visits,alcohol
from geoplaces2 as g
join rating_final as rf
on g.placeid = rf.placeid
join userpayment as up
on rf.userid = up.userid
group by alcohol;


#8) Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

SELECT g.Alcohol, g.Price, AVG(r.Rating) AS avg_rating
FROM geoplaces2 AS g
JOIN rating_final AS r 
ON g.placeid = r.placeid
WHERE g.Alcohol IS NOT NULL
GROUP BY g.Alcohol, g.Price;

#9) Let’s write a query to quantify that what are the parking availability as well in different alcohol categories 
#along with the total number of restaurants.
SELECT g.Alcohol,cp.parking_lot AS Parking_Lot_Availability,COUNT(g.placeid) AS Total_Restaurants
FROM geoplaces2 AS g
JOIN Chefmozparking AS cp ON g.placeid = cp.placeid
WHERE g.Alcohol IS NOT NULL
GROUP BY g.Alcohol, cp.parking_lot;

#10) Also take out the percentage of different cuisine in each alcohol type.
SELECT g.Alcohol,cp.parking_lot AS Parking_Lot_Availability,COUNT(g.placeid) AS Total_Restaurants,cm.Rcuisine AS Cuisine_Type,
COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY g.Alcohol) AS Cuisine_Percentage
FROM geoplaces2 AS g
JOIN Chefmozparking AS cp ON g.placeid= cp.placeid
JOIN Chefmozcuisine AS cm ON g.placeid = cm.placeid
WHERE g.Alcohol IS NOT NULL
GROUP BY g.Alcohol, cp.parking_lot, cm.Rcuisine;

#11) let’s take out the average rating of each state.
SELECT g.State,AVG(r.Rating) AS Average_Rating
FROM geoplaces2 AS g
JOIN rating_final AS r 
ON g.placeid = r.placeid
GROUP BY g.State;

#12) Tamaulipas' Is the lowest average rated state. 
#Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.
SELECT g.State,g.Alcohol,cm.Rcuisine AS Cuisine_Type,AVG(r.Rating) AS Average_Rating,COUNT(g.placeid) AS Total_Restaurants
FROM geoplaces2 AS g
JOIN rating_final AS r ON g.placeid = r.placeid
JOIN Chefmozcuisine AS cm ON g.placeid = cm.placeid
WHERE g.State = 'Tamaulipas'
GROUP BY g.State, g.Alcohol, cm.Rcuisine
ORDER BY Average_Rating;

# 13) Find the average weight, food rating, and service rating of the customers who have visited KFC and 
#tried Mexican or Italian types of cuisine, and also their budget level is low.
#We encourage you to give it a try by not using joins.    
    SELECT AVG(up.Weight) AS Average_Weight,AVG(rf.Food_Rating) AS Average_Food_Rating,AVG(rf.Service_Rating) AS Average_Service_Rating
FROM Userprofile AS up
JOIN rating_final AS rf 
ON up.userid = rf.userid
WHERE up.Budget = 'low'AND up.userid IN (
        SELECT uc.userid FROM Usercuisine AS uc WHERE uc.Rcuisine IN ('Mexican', 'Italian')
    )
    AND rf.placeid IN (
        SELECT g.placeid
        FROM geoplaces2 AS g
        WHERE g.Name = 'KFC'
    );

SELECT
    (SELECT AVG(Weight) FROM Userprofile WHERE userid IN (
        SELECT userid FROM Usercuisine WHERE Rcuisine IN ('Mexican', 'Italian')
    ) AND Budget = 'low') AS Average_Weight,
    
    (SELECT AVG(Food_Rating) FROM rating_final WHERE userid IN (
        SELECT userid FROM Usercuisine WHERE Rcuisine IN ('Mexican', 'Italian')
    ) AND placeid IN (
        SELECT placeid FROM geoplaces2 WHERE Name = 'KFC'
    )) AS Average_Food_Rating,
    
    (SELECT AVG(Service_Rating) FROM rating_final WHERE userid IN (
        SELECT userid FROM Usercuisine WHERE Rcuisine IN ('Mexican', 'Italian')
    ) AND placeid IN (
        SELECT placeid FROM geoplaces2 WHERE Name = 'KFC'
    )) AS Average_Service_Rating;
    
    
    
 #14) Create two called Student_details and Student_details_backup.   
DELIMITER //

CREATE TRIGGER before_delete_student
BEFORE DELETE ON Student_details
FOR EACH ROW
BEGIN
    INSERT INTO Student_details_backup (Student_id, Student_name, mail_id, mobile_no)
    VALUES (OLD.Student_id, OLD.Student_name, OLD.mail_id, OLD.mobile_no);
END;

//

DELIMITER ;





