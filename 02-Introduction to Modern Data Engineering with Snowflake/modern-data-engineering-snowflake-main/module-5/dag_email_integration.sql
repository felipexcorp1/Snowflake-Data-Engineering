USE ROLE accountadmin;
USE WAREHOUSE compute_wh;
USE DATABASE tasty_bytes;

-- Create an email integration 
CREATE OR REPLACE NOTIFICATION INTEGRATION email_notification_int
TYPE = EMAIL
ENABLED = TRUE
ALLOWED_RECIPIENTS = ('FELIPEXCORP@GMAIL.COM');  -- Update the recipient's email here

CREATE OR REPLACE PROCEDURE tasty_bytes.raw_pos.last_seven_days_report()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python','pandas')
HANDLER = 'send_email'
AS 
$$
import snowflake.snowpark.functions as F
from snowflake.snowpark import Session

def send_email(session: Session) -> str:
    # Query the 7 most recent entries in the DAILY_SALES_HAMBURG_T table
    recent_entries_df = session.table("RAW_POS.DAILY_SALES_HAMBURG_T") \
                               .sort(F.col("DATE_TRUNC(LITERAL(), ORDER_TS)").desc()) \
                               .limit(7) \
                               .to_pandas()
    
    # Convert the DataFrame to an HTML table with styling
    html_table = recent_entries_df.to_html(index=False, classes='styled-table')

    # Define the email content with Snowflake branding and custom styling
    email_content = f"""
    <html>
    <head>
        <style>
            body {{
                font-family: Arial, sans-serif;
            }}
            h2 {{
                color: #29B5E8;
            }}
            .styled-table {{
                border-collapse: collapse;
                margin: 25px 0;
                font-size: 0.9em;
                font-family: 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif;
                min-width: 400px;
                border-radius: 5px 5px 0 0;
                overflow: hidden;
                box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
            }}
            .styled-table thead tr {{
                background-color: #0072CE;
                color: #ffffff;
                text-align: left;
                font-weight: bold;
            }}
            .styled-table th,
            .styled-table td {{
                padding: 12px 15px;
            }}
            .styled-table tbody tr {{
                border-bottom: 1px solid #dddddd;
            }}
            .styled-table tbody tr:nth-of-type(even) {{
                background-color: #f3f3f3;
            }}
            .styled-table tbody tr:last-of-type {{
                border-bottom: 2px solid #0072CE;
            }}
        </style>
    </head>
    <body>
        <h2>Weekly Sales Report for Hamburg</h2>
        <p>Here are the last 7 entries in the <strong>DAILY_SALES_HAMBURG_T</strong> table:</p>
        {html_table}
    </body>
    </html>
    """
    
    # Send the email
    session.call("system$send_email",
                 "email_notification_int",
                 "FELIPEXCORP@GMAIL.COM",
                 "Weekly Sales Report for Hamburg",
                 email_content,
                 "text/html")
    
    # Return a success message
    return "Weekly sales report email sent successfully"
$$;

-- Create task that runs after the process_orders_header_sproc task
-- It calls the sproc above
CREATE OR REPLACE TASK tasty_bytes.raw_pos.send_last_seven_days_report
WAREHOUSE = 'COMPUTE_WH'
AFTER tasty_bytes.raw_pos.process_orders_header_sproc
AS
CALL tasty_bytes.raw_pos.last_seven_days_report();

-- Start the tasks
ALTER TASK tasty_bytes.raw_pos.send_last_seven_days_report RESUME;
ALTER TASK tasty_bytes.raw_pos.process_orders_header_sproc RESUME;

-- Start the DAG

EXECUTE TASK tasty_bytes.raw_pos.process_orders_header_sproc;

-- Stop the tasks
ALTER TASK tasty_bytes.raw_pos.process_orders_header_sproc SUSPEND;
ALTER TASK tasty_bytes.raw_pos.send_last_seven_days_report SUSPEND;


SELECT SYSTEM$RESOLVE_PYTHON_PACKAGES(
    '3.12',
    $$('pandas')$$
);


CREATE OR REPLACE PROCEDURE TEST_PANDAS()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.12'
PACKAGES = (
    'snowflake-snowpark-python',
    'pandas'
)
HANDLER = 'test_pandas'
AS
$$
import pandas as pd

def test_pandas(session):
    return 'Pandas version: ' + pd.__version__
$$;

CALL TEST_PANDAS();


CREATE OR REPLACE PROCEDURE TEST_TO_PANDAS()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.12'
PACKAGES = (
    'snowflake-snowpark-python',
    'pandas'
)
HANDLER = 'test_to_pandas'
AS
$$
def test_to_pandas(session):

    df = session.sql("""
        SELECT 1 AS ID, 'Test' AS NAME
    """)

    pdf = df.to_pandas()

    return 'Rows: ' + str(len(pdf)) + ', Pandas: ' + str(pdf.shape)
$$;

CALL TEST_TO_PANDAS();






CREATE OR REPLACE PROCEDURE tasty_bytes.raw_pos.last_seven_days_report()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send_email'
AS 
$$
import snowflake.snowpark.functions as F
from snowflake.snowpark import Session
import html

def send_email(session: Session) -> str:

    # Select the data and give the columns clean names
    recent_entries_df = (
        session.table("RAW_POS.DAILY_SALES_HAMBURG_T")
        .select(
            F.col('"DATE_TRUNC(LITERAL(), ORDER_TS)"').alias("ORDER_DATE"),
            F.col('"TOTAL_SALES"').alias("TOTAL_SALES")
        )
        .sort(F.col("ORDER_DATE").desc())
        .limit(7)
    )

    # Get column names
    columns = recent_entries_df.columns

    # Collect rows
    rows = recent_entries_df.collect()

    # Build HTML table
    html_table = """
    <table class="styled-table">
        <thead>
            <tr>
    """

    for column in columns:
        html_table += f"<th>{html.escape(column)}</th>"

    html_table += """
            </tr>
        </thead>
        <tbody>
    """

    for row in rows:

        html_table += "<tr>"

        for value in row:
            if value is None:
                value = ""

            html_table += f"<td>{html.escape(str(value))}</td>"

        html_table += "</tr>"

    html_table += """
        </tbody>
    </table>
    """

    # Email content
    email_content = f"""
    <html>
    <head>
        <style>
            body {{
                font-family: Arial, sans-serif;
            }}

            h2 {{
                color: #29B5E8;
            }}

            .styled-table {{
                border-collapse: collapse;
                margin: 25px 0;
                font-size: 0.9em;
                font-family: 'Trebuchet MS',
                             'Lucida Sans Unicode',
                             'Lucida Grande',
                             'Lucida Sans',
                             Arial,
                             sans-serif;
                min-width: 400px;
                border-radius: 5px 5px 0 0;
                overflow: hidden;
                box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
            }}

            .styled-table thead tr {{
                background-color: #0072CE;
                color: #ffffff;
                text-align: left;
                font-weight: bold;
            }}

            .styled-table th,
            .styled-table td {{
                padding: 12px 15px;
            }}

            .styled-table tbody tr {{
                border-bottom: 1px solid #dddddd;
            }}

            .styled-table tbody tr:nth-of-type(even) {{
                background-color: #f3f3f3;
            }}

            .styled-table tbody tr:last-of-type {{
                border-bottom: 2px solid #0072CE;
            }}
        </style>
    </head>

    <body>

        <h2>Weekly Sales Report for Hamburg</h2>

        <p>
            Here are the last 7 entries in
            <strong>DAILY_SALES_HAMBURG_T</strong>:
        </p>

        {html_table}

    </body>
    </html>
    """

    # Send email
    session.call(
        "system$send_email",
        "email_notification_int",
        "FELIPEXCORP@GMAIL.COM",
        "Weekly Sales Report for Hamburg",
        email_content,
        "text/html"
    )

    return "Weekly sales report email sent successfully"

$$;



DESC TABLE tasty_bytes.raw_pos.DAILY_SALES_HAMBURG_T;