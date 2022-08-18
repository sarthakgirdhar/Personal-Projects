## StackOverflow Data

In this project, I analyze the posts of https://stats.stackexchange.com/ from 2011 to 2021. The XML dataset can be downloaded from <https://archive.org/details/stackexchange>. 

### CreateDatabase.sql

In this file, we simply create a database with all the requisite tables and then import the XML files into the respective tables.

### QueriesOnDatabase.sql

We run queries just to ensure that our database and tables have been set properly. We can also get some interesting results from these queries. 

### Stats1 - Connect MySQL and Python.ipynb

This time we connect the MySQL database to Python. We also run SQL queries in Python and display the results in an appropriate format.

### Stats2 - Importing database tables into Pandas dataframes.ipynb

This is the end file where, most of the EDA is performed on the StackOverflow dataset. 
