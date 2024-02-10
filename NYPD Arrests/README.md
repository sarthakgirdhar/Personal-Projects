## NYPD Arrests

In this project, I build an ETL Pipeline for [NYPD Arrest Data](https://data.cityofnewyork.us/Public-Safety/NYPD-Arrest-Data-Year-to-Date-/uip8-fykc/about_data) using Python, Snowflake, and Power BI.

I start with extracting the data from NYC Open Data API, then perform some transformations, do data validation, and then, finally load it into Snowflake. 

In Snowflake, I perform some Exploratory Data Analysis (EDA) to answer some questions. Finally, I also connect Snowflake to Power BI to gather some further detailed insights.

### About the data

There are about 227,000 rows present for the 2023 arrest data. Each record represents an arrest effected in NYC by the NYPD and includes information about the type of crime, the location, time of enforcement, suspect demographics, etc.

### Skills demonstrated

 - Understanding dataset and reading supporting documentation.
 - Writing code in Python to extract data from NYC Open Data API.
 - Checking for data quality and transformations.
 - Creating a data warehouse in Snowflake so that it's easier for the downstream users to perform data analysis.
 - Data analysis - answering stakeholder’s questions.
 - Visualizations in Power BI.
