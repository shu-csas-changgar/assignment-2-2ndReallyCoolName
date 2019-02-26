/* q1 */
select c.customer_id, c.first_name, c.last_name, sum(p.amount) as "total spent"  from customer c join payment p on c.customer_id = p.customer_id
group by c.customer_id order by c.last_name asc, sum(p.amount) desc;

/* q2 */
select distinct c.city_id, c.city, a.district, a.postal_code from address a join city c on c.city_id = a.city_id where a.postal_code is null or a.postal_code = "";

/* q3 */
select title from film where title like '%doctor%' or title like '%fire';

/* q4 */
select a.actor_id, a.first_name, a.last_name, count(*) as 'number of movies' from actor a join film_actor f on a.actor_id = f.actor_id group by a.actor_id
order by a.last_name asc, count(*) desc;

/* q5 */
select c.name, avg(f.length) as 'avg runtime'  from category c join film_category fc on fc.category_id = c.category_id 
join film f on fc.film_id = f.film_id group by c.name order by avg(f.length) asc; 

/* q6 */
select s.store_id, sum(p.amount) as 'revenue' from staff s join payment p on s.staff_id = p.staff_id group by s.store_id
order by sum(p.amount) desc; 

/* q7 
country_id for canada is 20
*/
select c.first_name, c.last_name, c.email, sum(p.amount) as "total spent", ct.country_id from customer c join payment p on c.customer_id = p.customer_id
join address a on a.address_id = c.customer_id join city ct on ct.city_id = a.city_id
where ct.country_id = 20
group by c.customer_id order by c.last_name asc, sum(p.amount) desc;


/* q8 
customer has two ids for the two stores because duplicate keys aren't allowed and 
the store column needs two different values. All further queries are done on the new customer_id - 600, smallest unique +id
*/

start transaction;
set @max_id = (select max(c.customer_id) from customer c)+1;
insert into customer
select @max_id, 2, c.first_name, c.last_name, c.email, c.address_id, c.active, 
"2019-02-25 16:02:20", now() from customer c where c.customer_id = 539;

set @max_rid = (select max(r.rental_id) from rental r)+1;
insert into rental 
value(@max_rid, now(), 2025, @max_id, null, 2, now());
select * from rental r where r.rental_id = @max_rid;

set @max_pid = (select max(p.payment_id) from payment p)+1;
insert into payment 
values (@max_pid, @max_id, 2, @max_rid, 2.99, now(), now());
select * from payment p where p.payment_id = @max_pid;
commit;

/*revert if things go horribly goes wrong" */
delete from  payment where customer_id >= 604;
delete from rental where customer_id >= 600;
delete from customer where customer_id >= 600;

/* select statements to see if everything worked*/
set @max_pid = (select max(p.payment_id) from payment p);
set @max_rid = (select max(r.rental_id) from rental r);
select * from customer c where c.first_name = "mathew" and c.last_name = "bolin";
select * from payment p where p.payment_id = @max_pid;
select * from rental r where r.rental_id = @max_rid;
select c.customer_id, c.first_name, c.last_name, f.title, s.first_name, s.last_name, c.store_id from rental r join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id join customer c on r.customer_id = c.customer_id join staff s on r.staff_id = s.staff_id
where r.customer_id = @max_id;

/*rollback didn't do anything so I had to use delete*/
rollback;

/*q9 
tracy's id is 108, query to get info*/
select * from customer c join rental r on c.customer_id = r.customer_id
 join inventory i on r.inventory_id = i.inventory_id join film f on f.film_id = i.film_id
 where c.customer_id= 108 and r.return_date is null;
 
 
 update rental
 set return_date = now()
 where customer_id = 108 and return_date is null;
 
 /* select statements to see if everything worked*/
select c.customer_id, c.first_name, c.last_name, r.return_date, f.title
 from customer c join rental r on c.customer_id = r.customer_id
 join inventory i on r.inventory_id = i.inventory_id join film f on f.film_id = i.film_id
 where c.customer_id= 108 and f.film_id = 13;
 
 /* q10 
 animation category_id = 2, japanese language_id = 3*/
 
 update film f 
 join film_category fc on fc.film_id = f.film_id join category c on c.category_id = fc.category_id
 set f.original_language_id = 3
 where fc.category_id = 2;
 
 /* select statements to see if everything worked*/
 select f.film_id, f.title, f.original_language_id, c.name from film f join film_category fc on fc.film_id = f.film_id join category c on c.category_id = fc.category_id 
 where c.category_id = 2;
 