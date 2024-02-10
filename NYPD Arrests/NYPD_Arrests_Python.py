""" Extract data from NYC Open Data API """

# import libraries
import requests
import pandas as pd
import json

# API endpoint
nyc_open_data_api_key = 'XXXXXXX'
headers={'X-App-Token': nyc_open_data_api_key}

nyc_arrests = pd.DataFrame()

# 'GET' request
for offset in range(0, 230000, 50000):
    url = 'https://data.cityofnewyork.us/resource/uip8-fykc.json?$limit=50000&$offset='+str(offset)
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        temp_df = pd.DataFrame()
        temp_df = pd.json_normalize(data)
    
    nyc_arrests = nyc_arrests.append(temp_df, ignore_index=True)


""" Transformation """

# check number of rows and columns in the dataframe
nyc_arrests.shape

nyc_arrests.tail(5)

# print column names
print(nyc_arrests.columns.tolist())

nyc_arrests['geocoded_column.type'].unique()

# Drop redundant columns from the dataframe
nyc_arrests.drop(nyc_arrests.loc[:, ':@computed_region_f5dn_yrer':'geocoded_column.coordinates'].columns, inplace=True, axis=1)

nyc_arrests.shape


""" Data Validation """

""" 1 ARREST_KEY """

# return indices for empty entries/values
nyc_arrests[nyc_arrests['arrest_key'] == ''].index

# check for NULL values
import numpy as np
np.where(pd.isnull(nyc_arrests['arrest_key']))

# check if all the values are numeric
pd.to_numeric(nyc_arrests['arrest_key'], errors='coerce').notnull().all()

# check if all the values are 9 digits long
nyc_arrests[nyc_arrests['arrest_key'].apply(lambda x: len(str(x)) != 9)]

""" 2 ARREST_DATE """

# check for NULL values
import numpy as np
np.where(pd.isnull(nyc_arrests['arrest_date']))

# check if all values are datetime
nyc_arrests['arrest_date'].astype(str).apply(lambda x: pd.to_datetime(x, errors='coerce')).notna().all()

""" 3 PD_CD """

# check if all the values are numeric
pd.to_numeric(nyc_arrests['pd_cd'], errors='coerce').notnull().all()

# find unique values
nyc_arrests['pd_cd'].unique()

# find number of rows with 'nan' entries 
nyc_arrests['pd_cd'].isnull().sum()

# check if all the values are 3 digits long
temp = nyc_arrests[nyc_arrests['pd_cd'].apply(lambda x: len(str(x)) != 3)]

temp['pd_cd'].value_counts()

temp.loc[temp['pd_cd'] == '12']

""" 4 PD_DESC """

# find unique values
nyc_arrests['pd_desc'].unique()

""" 5 KY_CD """

# check if all the values are numeric
pd.to_numeric(nyc_arrests['ky_cd'], errors='coerce').notnull().all()

# find unique values
nyc_arrests['ky_cd'].unique()

nyc_arrests['ky_cd'].isnull().sum()

nyc_arrests.loc[nyc_arrests['ky_cd'].isnull()]

# check if all the values are 3 digits long
nyc_arrests[nyc_arrests['ky_cd'].apply(lambda x: len(str(x)) != 3)]

""" 6 OFNS_DESC """

# find unique values
nyc_arrests['ofns_desc'].unique()

""" 7 LAW_CAT_CD """

# find unique values
nyc_arrests['law_cat_cd'].unique()

nyc_arrests.loc[nyc_arrests['law_cat_cd'] == '9']

nyc_arrests.loc[nyc_arrests['law_cat_cd'] == 'I']

""" 8 ARREST_BORO """

# find unique values
nyc_arrests['arrest_boro'].unique()

""" 9 ARREST_PRECINCT """

# check if all the values are numeric
pd.to_numeric(nyc_arrests['arrest_precinct'], errors='coerce').notnull().all()

""" 10 JURISDICTION_CODE """

# check if all the values are numeric
pd.to_numeric(nyc_arrests['jurisdiction_code'], errors='coerce').notnull().all()

""" 11 AGE_GROUP """

# find unique values
nyc_arrests['age_group'].unique()

""" 12 PERP_SEX """

# find unique values
nyc_arrests['perp_sex'].unique()

""" 13 PERP_RACE """

# find unique values
nyc_arrests['perp_race'].unique()

""" 14 LATITUDE AND LONGITUDE """

# calculate min & max on 'latitude'
print(nyc_arrests['latitude'].agg(['min', 'max']))

# calculate min & max on 'longitude'
print(nyc_arrests['longitude'].agg(['min', 'max']))

# locate rows with longitude value equal to 0
nyc_arrests.loc[nyc_arrests['longitude'] == '0.0']

temp = nyc_arrests.drop(69643)

print(temp['latitude'].agg(['min', 'max']))

print(temp['longitude'].agg(['min', 'max']))


""" Loading into Snowflake """

# install Snowflake connector
pip install snowflake-connector-python

import snowflake.connector
from snowflake.connector.pandas_tools import pd_writer
from snowflake.connector.pandas_tools import write_pandas

# create a function to upload the data into a table in Snowflake
def upload_to_snowflake(ACCOUNT, USER, PASSWORD, WAREHOUSE, DATABASE, SCHEMA):
    
    # connect to Snowflake
    conn = snowflake.connector.connect(
    user=USER,
    password=PASSWORD,
    account=ACCOUNT,
    warehouse=WAREHOUSE,
    database=DATABASE,
    schema=SCHEMA
    )
    
    # create a cursor
    cur = conn.cursor()
    
    # create the warehouse
    cur.execute(f'CREATE WAREHOUSE IF NOT EXISTS {WAREHOUSE} WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 300')
    
    # use the warehouse
    cur.execute(f'USE WAREHOUSE {WAREHOUSE}')
    
    # create the database
    cur.execute(f'CREATE DATABASE IF NOT EXISTS {DATABASE}')
    
    # use the database
    cur.execute(f'USE DATABASE {DATABASE}')
    
    # create the schema
    cur.execute(f'CREATE SCHEMA IF NOT EXISTS {SCHEMA}')
    
    # use the schema
    cur.execute(f'USE SCHEMA {SCHEMA}')
    
    # create the table
    cur.execute("""
    CREATE OR REPLACE TABLE nypd_arrests (
        "arrest_key" STRING,
        "arrest_date" TIMESTAMP,
        "pd_cd" INTEGER,
        "pd_desc" STRING,
        "ky_cd" INTEGER,
        "ofns_desc" STRING,
        "law_code" STRING,
        "law_cat_cd" STRING,
        "arrest_boro" STRING,
        "arrest_precinct" INTEGER,
        "jurisdiction_code" INTEGER,
        "age_group" STRING,
        "perp_sex" STRING,
        "perp_race" STRING,
        "x_coord_cd" INTEGER,
        "y_coord_cd" INTEGER,
        "latitude" FLOAT,
        "longitude" FLOAT
        ) 
    """)
    
    # load the data from 'nyc_arrests' dataframe into 'nypd_arrests' Snowflake table
    
    cur.execute('TRUNCATE TABLE nypd_arrests')  # clear existing data if needed
    
    write_pandas(conn, nyc_arrests, 'NYPD_ARRESTS')
    
    
    # close the cursor and Snowflake connection
    cur.close()
    conn.close()
    
# call the function
upload_to_snowflake('E*****Z-J*****5', 'sarthakgirdhar', 'XXXXXXXX', 'COMPUTE_WH','NewYorkPoliceDepartment', 'ArrestsRawData')
