use zomato;
-- 1 what is the total amount each customer spent on zomato?

SELECT 
    s.userid, SUM(p.price) AS total_amount
FROM
    sales s
        JOIN
    product p ON s.product_id = p.product_id
GROUP BY s.userid;

-- 2 how many days has each customer visit zomato?

select userid,count(visited) from(select userid,rank() over(partition by userid order by created_date)  visited from sales)a group by userid;

-- another method

SELECT 
    userid, COUNT(DISTINCT created_date) as visited
FROM
    sales
GROUP BY userid;

-- 3 what was the first product purchased by the each customer?

select a.* from
(select *,rank() over(partition by userid order by created_date) first_product from sales)a 
where first_product=1;

-- 4 what is the most item purchased in the menu and how many times its purchased by the  customers?

select product_id, count(product_id) from sales  group by product_id order by count(product_id) desc ;

-- 5 which item was the popular for each customer?

select *from
(select *,rank() over(partition by userid order by cnt desc) rnk from 
(
select userid,product_id, count(product_id) cnt from sales  group by product_id ,userid)a)b
where rnk=1;

-- 6 which first item purchased by user after becoming member?

select *from
(select a.*,rank() over(partition by userid order by created_date) rnk from
(SELECT 
    s.userid, s.product_id, s.userid, g.gold_signup_date
FROM
    sales s
        JOIN
    goldusers_signup g ON s.userid = g.userid
        AND s.created_date >= g.gold_signup_date)a)b where rnk=1;
        
-- 7 which item purchased by user before just become member?

select *from
(select a.*,rank() over(partition by userid order by created_date) rnk from
(SELECT 
    s.userid, s.product_id, s.userid, g.gold_signup_date
FROM
    sales s
        JOIN
    goldusers_signup g ON s.userid = g.userid
        AND s.created_date = g.gold_signup_date)a)b where rnk=1;
        
-- 8 what is the total order and amount spend on each member before they became member?

select c.*,d.price from
(select a.userid, a.created_date, a product_id,b.gold_signup_date from sales a join goldusers_signup 
			b on a.uerid=b.userid and created_date<= gold_signup_date) c join product d on c. product_id=d.product_id;
            
-- 9 If buying each product generates points for eg 5rs=2 zomato point and each product has different purchasing points
-- for eg for p1 5rs-1 zomato point for p2 10rs=5 zomato point and p3 5rs=1 zomato point 2rs= 1zomato point
-- calculate points collected by each customers and for which product must points have been given till now        

select userid, sum (total_points) * 2.5 total_point_earned from

(select e.*, amt/points total_points from (select case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from

(select c.userid,c.product_id,sum(price) amt from 

(select a.*,b. price from sales a inner join product b on a.product_id=b.product_id) c

group by userid, product_id)d)e)f  group by product_id;   


-- 10 In the first one year after a customer joins the gold program (including their join date) irrespective
-- of what the customer has purchased they earns 5 zonato points for every 10 rs spent who earned more more 1 or 3
-- and what was their paints earnings in thier first yr?

select  c.*, d.price *.5 total_points_earned from

(select a.userid, a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and created_date <= date_add(gold_signup_date,interval 1 year))c
 Inner join product d on c.product_id=d.product_id;

            

        