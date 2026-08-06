# This example showcases:
# 1. Using Snowpark to create and process data on Snowflake.
# 2. Executing a standalone Python script with a `main()` entry point.
# 3. Using standard Python libraries (matplotlib) to visualize results.
# 4. Rendering the chart inline in your session when you run the script.

from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col, sum as sum_, avg, count
import matplotlib.pyplot as plt


def main():
    session = get_active_session()

    print("Generating synthetic sales report on Snowflake compute...")

    sales_data = [
        ("North", "Software", 1200),
        ("North", "Services", 800),
        ("South", "Software", 1500),
        ("South", "Services", 700),
        ("West", "Software", 2200),
        ("West", "Services", 1300),
        ("East", "Software", 900),
        ("East", "Services", 600),
    ]

    df = session.create_dataframe(
        sales_data,
        schema=["REGION", "PRODUCT", "REVENUE"],
    )

    report = (
        df.group_by(col("REGION"))
        .agg(
            sum_("REVENUE").alias("TOTAL_REVENUE"),
            avg("REVENUE").alias("AVG_DEAL_SIZE"),
            count("*").alias("NUM_DEALS"),
        )
        .sort(col("TOTAL_REVENUE").desc())
    )

    report.show()

    # Pure Python / matplotlib section
    pdf = report.to_pandas()

    plt.figure(figsize=(8, 4))
    plt.bar(pdf["REGION"], pdf["TOTAL_REVENUE"])
    plt.title("Total Revenue by Region")
    plt.xlabel("Region")
    plt.ylabel("Total Revenue")
    plt.tight_layout()
    plt.show()

    print("Done.")


if __name__ == "__main__":
    main()
