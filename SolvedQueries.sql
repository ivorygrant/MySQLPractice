-- Homework Assignment
--  1a. Display the first and last names of all actors from the table `actor`.

        SELECT first_name, last_name FROM sakila.actor;

--  1b. Display the first and last name of each actor in a single column
--      in upper case letters. Name the column `Actor Name`.

        SELECT CONCAT(first_name, ' ', last_name) AS "Actor Name" from sakila.actor;

--  2a. You need to find the ID number, first name, and last name of an actor,
--      of whom you know only the first name, "Joe."
--      What is one query would you use to obtain this information?

        select * from sakila.actor where first_name = "joe";

--  2b. Find all actors whose last name contain the letters `GEN`:

        select * from sakila.actor where last_name like "%gen%";

--  2c. Find all actors whose last names contain the letters `LI`.
--      This time, order the rows by last name and first name, in that order:

        select * from sakila.actor where last_name like "%li%" order by last_name,first_name;

--  2d. Using `IN`, display the `country_id` and `country` columns of the
--      following countries: Afghanistan, Bangladesh, and China:

        SELECT country, country_id FROM country WHERE country IN ('Afghanistan', 'China', 'Bangladesh');

--  3a. You want to keep a description of each actor. You don't think you will
--      be performing queries on a description, so create a column in the table
--      `actor` named `description` and use the data type `BLOB` (Make sure to
--      research the type `BLOB`, as the difference between it and `VARCHAR`
--      are significant).

        alter table actor add description blob;

--  3b. Very quickly you realize that entering descriptions for each actor is
--      too much effort. Delete the `description` column.

        ALTER TABLE sakila.actor DROP COLUMN description;

--  4a. List the last names of actors, as well as how many actors have that last name.

        SELECT last_name from actor;

        SELECT
        last_name,
        COUNT(last_name)
        FROM
        actor
        GROUP BY last_name;

--  4b. List last names of actors and the number of actors who have that last name,
--      but only for names that are shared by at least two actors

        SELECT
        last_name,
        COUNT(last_name)
        FROM
        actor
        GROUP BY last_name
        HAVING COUNT(last_name) > 1;

--  4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor`
--      table as `GROUCHO WILLIAMS`. Write a query to fix the record.

        set sql_safe_updates = 0;

        update actor
        set first_name = "Harpo"
        where first_name = "Groucho";

--  4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out
--      that `GROUCHO` was the correct name after all! In a single query,
--      if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

        set sql_safe_updates = 0;

        update actor
        set first_name = "Groucho"
        where first_name = "Harpo";

--  5a. You cannot locate the schema of the `address` table.
--      Which query would you use to re-create it?
--      * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

        show create table address;

        -- shows how the table was created, what columns, data types, etc.

--  6a. Use `JOIN` to display the first and last names, as well as the address,
--      of each staff member. Use the tables `staff` and `address`:

        SELECT first_name, last_name, address.address
        FROM staff
        LEFT JOIN address ON staff.address_id = address.address_id;

--  6b. Use `JOIN` to display the total amount rung up by each staff member
--      in August of 2005. Use tables `staff` and `payment`.

        SELECT
        staff.staff_id,first_name, last_name, SUM(payment.amount)
        FROM
        staff
        LEFT JOIN
        payment ON staff.staff_id = payment.staff_id where payment.payment_date like "2005-08%"
        GROUP BY staff_id;

        -- code for single column check in payment

        SELECT SUM(amount)
        FROM payment
        WHERE payment_date like '2005-08%';

--  6c. List each film and the number of actors who are listed for that film.
--      Use tables `film_actor` and `film`. Use inner join.

        select title, count(film_actor.actor_id)
        from film_actor
        inner join film on film.film_id = film_actor.film_id
        group by film.film_id;

        -- review this query

--  6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

        select count(film_id) from inventory where film_id=439;

--  6e. Using the tables `payment` and `customer` and the `JOIN` command,
--      list the total paid by each customer. List the customers alphabetically
--      by last name:

        select customer.first_name,customer.last_name,payment.customer_id, sum(payment.amount)
        from customer
        left join payment on payment.customer_id = customer.customer_id
        group by payment.customer_id, customer.first_name,customer.last_name order by last_name;

-- ```
-- 	![Total amount paid](Images/total_payment.png)
-- ```
--  7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
--      As an unintended consequence, films starting with the letters `K` and `Q`
--      have also soared in popularity. Use subqueries to display the titles of
--      movies starting with the letters `K` and `Q` whose language is English.

        select * from film where (title like 'Q%') or (title like 'K%') and language_id=1;

--  7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

        select first_name, last_name from actor where actor_id in
        (
        select actor_id from film_actor where film_id in

        (
        select film_id from film where title = "alone trip"
        )
        );

--  7c. You want to run an email marketing campaign in Canada, for which you
--      will need the names and email addresses of all Canadian customers.
--      Use joins to retrieve this information.

        select customer.first_name as "First Name", customer.last_name as "Last Name",
               customer.email as "Email", country.country as "Country"
        from customer
        join address on customer.address_id = address.address_id
        join city on address.city_id = city.city_id
        join country on city.country_id = country.country_id
        where country.country = "canada";

--  7d. Sales have been lagging among young families, and you wish to target all
--      family movies for a promotion. Identify all movies categorized as family films.

        select film.film_id as "Film ID", film.title as "Title",
               film.description as "Description", film.rating as "Rating",
               category.category_id as "Category #"
        from film
        join film_category on film.film_id = film_category.film_id
        join category on category.category_id = film_category.category_id
        where category.category_id = 8;

--  7e. Display the most frequently rented movies in descending order.

        select inventory.film_id as "Film ID", count(rental.rental_id) as "Times Rented"
        from rental
        join inventory on inventory.inventory_id = rental.inventory_id
        group by inventory.film_id order by count(rental.rental_id) desc;

--  7f. Write a query to display how much business, in dollars, each store brought in.

        select payment.staff_id as "Store Number", sum(payment.amount) as "Store Sales"
        from payment
        join staff on payment.staff_id = staff.staff_id
        group by payment.staff_id;

--  7g. Write a query to display for each store its store ID, city, and country.

        select store.store_id as "Store ID", city.city as "City",country.country as "Country"
        from store
        join address on store.address_id = address.address_id
        join city on address.city_id = city.city_id
        join country on city.country_id = country.country_id;

--  7h. List the top five genres in gross revenue in descending order.
--      (**Hint**: you may need to use the following tables: category,
--      film_category, inventory, payment, and rental.)

        select category.category_id as "Category ID", category.name as "Genre",
               sum(payment.amount) as "Total Sales"
        from category
        join film_category on category.category_id = film_category.category_id
        join inventory on film_category.film_id = inventory.film_id
        join rental on inventory.inventory_id = rental.inventory_id
        join payment on rental.rental_id = payment.rental_id
        group by category.category_id order by sum(payment.amount) desc limit 5;

--  8a. In your new role as an executive, you would like to have an easy way of
--      viewing the Top five genres by gross revenue. Use the solution from
--      the problem above to create a view. If you haven't solved 7h, you can
--      substitute another query to create a view.

        create view `Top 5 Genres by Gross Revenue` as
        select category.category_id as "Category ID", category.name as "Genre",
               sum(payment.amount) as "Total Sales"
        from category
        join film_category on category.category_id = film_category.category_id
        join inventory on film_category.film_id = inventory.film_id
        join rental on inventory.inventory_id = rental.inventory_id
        join payment on rental.rental_id = payment.rental_id
        group by category.category_id order by sum(payment.amount) desc limit 5;

--  8b. How would you display the view that you created in 8a?

        show create view `Top 5 Genres by Gross Revenue`;
        select * from `Top 5 Genres by Gross Revenue`;

--  8c. You find that you no longer need the view `top_five_genres`.
--      Write a query to delete it.

        drop view `Top 5 Genres by Gross Revenue`;
        
