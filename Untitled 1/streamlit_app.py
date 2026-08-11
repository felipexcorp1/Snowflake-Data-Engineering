import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session
import altair as alt

# Get current credentials session
session = get_active_session()

# Streamlit app 
st.title(":snowflake: Tastybytes streamlit app :snowflake:")

st.write("""This this ths description of the app in Snowflake""")

st.divider()

@st.cache_data
def get_city_sales_data(city_names:list, start_year: int = 2020, end_year: int = 2023):
    sql = f"""
            SELECT 
                DATE,
                PRIMARY_CITY,
                SUM(ORDER_TOTAL) AS  SUM_ORDERS
            FROM 
                TASTY_BYTES.ANALYTICS.ORDERS_V
            WHERE 
                PRIMARY_CITY IN ({city_names})
                AND YEAR(DATE) BETWEEN {start_year}  AND {end_year}
            GROUP BY 
                DATE,
                PRIMARY_CITY
            ORDER BY
                DATE DESC
    """
    sales_data = session.sql(sql).to_pandas()
    return sales_data, sql

@st.cache_data
def get_unique_cities():
    sql = f"""
            SELECT 
                distinct PRIMARY_CITY
            FROM 
                TASTY_BYTES.ANALYTICS.ORDERS_V
            ORDER BY
                PRIMARY_CITY
    """
    city_data = session.sql(sql).to_pandas()
    return city_data

def get_city_sales_chart(sales_data: pd.DataFrame):
    sales_data["SUM_ORDERS"] = pd.to_numeric(sales_data["SUM_ORDERS"])
    sales_data["DATE"] = pd.to_datetime(sales_data["DATE"])
    
    # Create an altarir chart project

    chart = (
            alt.Chart(sales_data)
            .mark_line(point=False, tooltip = True)
            .encode(
                alt.X("DATE", title = "Date"),
                alt.Y("SUM_ORDERS", title = "Total sum orders"),
                color = "PRIMARY_CITY",
            )
    )
    return chart

def format_sql(sql):
    # Remove padded space for visual purposes
    return sql.replace("\n         ", "\n")

first_col, second_col = st.columns(2, gap="large")

with first_col:
    start_year, end_year = st.select_slider(
    "Select date range",
    options=range(2020,2024),
    value=(2020,2023),
    )

with second_col:
    selected_city = st.multiselect(
    "Select cities",
    options=get_unique_cities()["PRIMARY_CITY"].tolist(),
    default="Boston",
    )
if len(selected_city) ==0:
    city_selection = ""
else:
    city_selection = selected_city
city_selection_list = ("'" + "','".join(city_selection) + "'" ) if city_selection else ""

sales_data, sales_sql = get_city_sales_data(city_selection_list, start_year, end_year)
sales_fig = get_city_sales_chart(sales_data)

chart_tab, dataframe_tab, query_tab = st.tabs(["Chart", "Raw data", "Sql Query"])
chart_tab.altair_chart(sales_fig, use_container_width=True)
dataframe_tab.dataframe(sales_data,use_container_width=True)
query_tab.code(format_sql(sales_sql), "sql")
