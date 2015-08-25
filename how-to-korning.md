###How to: korning
- If you found korning a bit tricky and would like some extra practice with using SQL to create tables and writing an import script come check out my clinic where I will do a live coding of how I tackled the korning challenge.

- We all know at this point there are many ways to solve a problem. For this clinic what I want to do is walk through and share my thought process for solving the korning challenge and I'd love for you to get some practice with schema design, and normalizing data so I'll ask you to help me write the schema and script along the way.

####What are we looking to accomplish?
- Create a schema for our database that normalizes our data and link tables together using primary and foreign keys(to define a one-to-many relationship)
- Create a database for this project and add the schema to our database to create our tables
- Write a script that will parse data from a CSV file, that currently holds our data, into our relational database structure

####Where to start? Look at our data!
- What does a row represent? (Sale)(Copy the header row to create tables/whiteboard)
- Where can we normalize/ What tables should we create? (employee, customer, product, order_frequency, sales)
(explain one to many relationships so where do foreign keys go? sales table)

####Create the schema.sql
(Ok let's go a head and create some of these tables keeping in mind our data)
- Write CREATE TABLE SQL statement with the expected datatypes for product, frequency, employee, customer, sales
(Importance of primary keys. Datatypes)
- What happens when we run this file in our database?
(The tables are created.  So let's add a drop if exists)
- Add DROP TABLE sql statement so that if we want to change anything we can drop and re create the tables in one script
DROP TABLE IF EXISTS sales, employee, frequency, product, customer;

####Make the database
What's the command to create? It's typical to have one database per project with many tables
- createdb korning *Makes the database for this project*
- psql < schema.sql *run all of our create tables SQL with one command*
Now we want to be able to run `ruby import.rb` to pull all of our data from CSV file

####Writing our import script
- We want to create a variable to access our data from our csv file.
  `sales_data = CSV.readlines('sales.csv', headers: true)`

- So what do we want to do?
- For each line of data on our CSV file we are looking at a sale, we want to populate our 5 tables with the right information from each sale.
- So first let's set up a loop of each row of our data.  

Ok now how do we get it into our database? We can use the pg gem to make the connection to our database and we have this method here that securely connects to the database.

- So for each row we will open up the connection to the db `db_connection do |conn|`
- Now that we have an open connection, we can loop through each sale transaction (or row of our file) and pull out and insert what we need.
- Let's add a pry and look at what our row looks like and our connection. What is this data structure? What are we working with?
- We can add a pry and take a look. (Array of CSV objects.)
- How can we call them? (row[0] row['employee'])
(if you didn't know what methods you could call. We could include a pry and conn.methods, show them .db .class, .entries, close out)

- We can use exec_params allows us to write sql statements for querying to our db tables. Sends SQL query request specified by sql to PostgreSQL using placeholders for parameters.
Format for the exec_params("", []), $1 stands as a placeholder, then you pass in the data in the form of an array.

#####Start populating tables
Ok so let's start with one of the simpler tables, product table that just has a product_name column.
Let's think about our table. From looking at our CSV file we can see repetition in the products being sold right?
So we only want to add into our table if the product is not already there.
- For each loop through lets first check our table for the product_name. How could we write that select statement, and check to see if that product name is in our table.
* What does this return? A count of how many times the product name matches the given product name of that row.
So let's write our conditional
- If product_match.count < 1 (is not there)
- Let's add it to our table. What is the SQL statement to add something in? INSERT INTO
** We can do the same for the frequency table.

######Employee and Customer Tables
When looking at employee and customer we want to separate the data into a few columns for our table. So let's first look at what we have in our row again and what we decided we wanted in our table.
- PRY - string with name and email and we want to save each one separately.
- How can we delete those parenthesis and split up our data? '.delete().split()'
- Let's again check to make sure one of these things isn't - email will likely always be unique~
Finally we want to populate our sales table with foreign keys to our other tables.
What is the SQL call for that.

######Sales Table
- To create our sales table we want to add some of the rest of these columns in our CSV file. So let's start to build our insert statement... Insert into sales (columns)
- How to get our foreign keys? While we are looping we can query our db table for frequency and if it matches we can save the id for that query into a variable to insert into our table.
- Insert pry here to see what we are returning and make sure it's the number we are looking for.

And finally if we run `ruby import.rb` we should be populating our tables. Because we used select statements to check data against what is already in the database we have created an idempotent script, meaning if we run it again we should see the same result and nothing would be added as a duplicate.

Because we are querying before inserting into the db tables. When I run this script again - what will happen?
Nothing is added.
