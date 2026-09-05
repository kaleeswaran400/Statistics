# Customer Shopping Behaviour Analysis

## 1. Executive Summary

This project turns customer shopping records into an analysis-ready dataset and a business dashboard. The workflow covers data quality checks, column standardization, missing-value treatment, feature engineering in Python, loading the transformed data into MySQL, and visual analysis in Power BI with DAX measures.

The analysis is designed to answer practical questions about product demand, customer value, purchasing frequency, discounts, loyalty, demographics, and payment behaviour.

## 2. Project Objectives

- Prepare a reliable customer shopping dataset for analysis.
- Standardize column names and correct inconsistent field names.
- Treat missing review ratings using category-level averages.
- Create customer age, purchase-frequency, and loyalty segments.
- Store the cleaned data in MySQL for reusable SQL analysis.
- Present business KPIs and customer segments in Power BI.
- Convert the analysis into decisions for merchandising, retention, and promotion planning.

## 3. Repository Contents

| File | Purpose |
| --- | --- |
| [Customer_shopping _behaviour.ipynb](Customer_shopping%20_behaviour.ipynb) | Python cleaning, transformation, and MySQL loading workflow |
| [customer_shopping_behavior.csv](customer_shopping_behavior.csv) | Source customer shopping data |
| [Customer Behavior Dashboard.pbix](Customer%20Behavior%20Dashboard.pbix) | Power BI dashboard |
| [Digital Marketing Analysis using Python.ipynb](Digital%20Marketing%20Analysis%20using%20Python.ipynb) | Separate digital marketing statistical analysis in the repository |

## 4. Dataset and Data Quality

The source file contains 3,905 CSV rows and 18 columns. It contains 3,900 customer records followed by five trailing summary or artifact rows. The artifact rows must be excluded before analysis; otherwise they distort category totals, averages, and dashboard visuals.

The customer records describe:

- Customer demographics: age, gender, and location
- Product information: item, category, size, colour, and season
- Transaction information: purchase amount, discount, promo code, payment method, and shipping type
- Behavioural information: previous purchases, purchase frequency, subscription status, and review rating

The notebook checks duplicate rows, standardizes column names, inspects null values, and reviews descriptive statistics. The raw import contains no duplicate customer rows in the 3,900-record portion. The source also contains missing values, so null handling should be verified after artifact-row removal and before the SQL load.

## 5. Data Preparation Workflow

### 5.1 Import and validation

The notebook uses pandas to load the CSV and checks the first records, duplicate rows, data types, descriptive statistics, and null counts.

Before production use, the import should apply a record filter such as `Customer ID.notna()` and validate that the identifier is numeric. This removes the trailing summary rows without relying on their text.

### 5.2 Naming and field correction

Column names are converted to lowercase and spaces are replaced with underscores. The misspelled field `purchase_amunt_(usd)` is renamed to `purchase_amount_(usd)` so downstream SQL and dashboard references are consistent.

### 5.3 Missing review ratings

Missing `review_rating` values are filled with the mean review rating for the same product category:

```python
campaign_data["review_rating"] = (
    campaign_data.groupby("category")["review_rating"]
    .transform(lambda values: values.fillna(values.mean()))
)
```

This preserves category differences better than replacing every missing rating with one global average. A final null check is still required because a category with no valid ratings would remain unresolved.

### 5.4 Feature engineering

The notebook creates the following analysis fields:

| Feature | Derivation | Business use |
| --- | --- | --- |
| `age_group` | Age bands: Young Adults, Adults, Middle Aged, Seniors | Compare customer value and demand by life stage |
| `purchase_frequency` | Frequency labels converted to approximate days | Compare purchase cadence numerically |
| `previous_purchases_category` | New: fewer than 10, Returning: 10-49, Loyal: 50 or more previous purchases | Support retention and loyalty analysis |

The `promo_code_used` column is removed after the notebook checks it against `discount_applied`, because the two fields are treated as redundant for the transformed dataset. This assumption should be confirmed with the source-data owner before removing the field in a production pipeline.

## 6. MySQL Data Load

The transformed DataFrame is loaded into:

- Database: `campaign_analysis_db`
- Table: `cleaned_campaign_reports`
- Load method: SQLAlchemy with the PyMySQL driver
- Write mode: `replace`
- DataFrame index: excluded from the SQL table

The `replace` mode is suitable for a repeatable development refresh, but it drops and recreates the table on every run. A production process should use a controlled staging table, validation checks, and an explicit refresh strategy.

Database credentials must never be committed to GitHub. The notebook currently contains a hard-coded password and should be changed to environment variables or a local secrets file excluded by `.gitignore` before publication.

Example connection pattern:

```python
import os
from sqlalchemy import create_engine

engine = create_engine(
    "mysql+pymysql://{user}:{password}@{host}/{database}".format(
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        host=os.environ.get("MYSQL_HOST", "localhost"),
        database="campaign_analysis_db",
    )
)
```

## 7. Business Questions

The project supports the following questions:

1. Which product categories and items generate the greatest purchase value?
2. Which age groups and customer segments contribute most to revenue?
3. How does purchase frequency differ between new, returning, and loyal customers?
4. Do subscribers behave differently from non-subscribers?
5. Are discounts associated with higher purchase activity or purchase value?
6. Which locations, seasons, sizes, and colours show the strongest demand?
7. Which payment methods and shipping types are most commonly used?
8. Are review ratings different across product categories?
9. Where should the business focus retention, cross-sell, and promotional activity?

## 8. Power BI Dashboard and DAX

The Power BI file provides the presentation layer for the cleaned customer data. Recommended dashboard views include:

- KPI cards for total revenue, orders, average order value, average rating, and customers
- Category and item performance
- Customer segments by age group and loyalty category
- Purchase frequency and subscription analysis
- Discount, payment, shipping, season, and location breakdowns

Representative DAX measures for the model are:

```DAX
Total Revenue = SUM(cleaned_campaign_reports[purchase_amount_(usd)])

Order Count = COUNTROWS(cleaned_campaign_reports)

Average Order Value = DIVIDE([Total Revenue], [Order Count])

Average Rating = AVERAGE(cleaned_campaign_reports[review_rating])

Loyal Customer Orders =
CALCULATE(
    [Order Count],
    cleaned_campaign_reports[previous_purchases_category] = "Loyal"
)
```

The exact measure names and visual configuration should be reviewed inside the `.pbix` file because Power BI report metadata and DAX definitions are not represented as readable text in this repository.

## 9. Findings and Interpretation

The supplied customer records provide the following reliable baseline observations after excluding the five trailing artifact rows:

- Clothing is the largest category with 1,737 records, followed by Accessories with 1,240, Footwear with 599, and Outerwear with 324.
- The source is male-skewed: 2,652 male records and 1,248 female records are present in the customer portion.
- Subscription status is split between 1,053 subscribers and 2,847 non-subscribers.
- The most common purchase-frequency labels are Every 3 Months, Annually, Quarterly, Monthly, Bi-Weekly, Fortnightly, and Weekly.
- Discount usage is present in 1,677 records and absent in 2,223 records.
- Purchase amount has a strong high-value outlier in the raw source, so totals and averages should be checked with appropriate filters and, where useful, median or percentile views.

These observations describe the available data and should not be interpreted as causal effects. The dashboard should be used to compare segments and identify opportunities, while any pricing, discount, or retention decision should be validated with controlled experiments or additional time-series data.

## 10. Recommendations

1. Prioritize Clothing and Accessories in assortment and cross-sell analysis because they contain the largest customer volumes.
2. Investigate subscriber benefits and conversion opportunities for the large non-subscriber group.
3. Use the loyalty segment to design differentiated retention offers instead of applying one discount to every customer.
4. Review extreme purchase amounts before presenting revenue KPIs so a small number of records cannot dominate the interpretation.
5. Compare discount users with a suitable control group before concluding that discounts improve customer value.
6. Add a repeatable data-quality gate that rejects artifact rows, validates numeric ranges, and confirms that transformed columns contain no unexpected nulls.

## 11. Reproducibility and Limitations

- Update the notebook's local CSV path before running it on another machine.
- Install pandas, NumPy, SQLAlchemy, and PyMySQL for the cleaning and database workflow.
- A running MySQL instance and a database user with permission to create or write to `campaign_analysis_db` are required.
- Do not commit passwords, connection strings, or local machine paths.
- The notebook does not store its execution outputs, so dashboard-specific totals and DAX results must be verified by opening the Power BI file and refreshing the model.
- The dataset appears to be a snapshot rather than a dated transaction history; trend and retention conclusions are therefore limited.

## 12. Conclusion

This project demonstrates an end-to-end customer analytics workflow: raw CSV data is validated and transformed with Python, stored in MySQL, and delivered through a Power BI dashboard. The resulting model supports practical segmentation and merchandising questions while making the data-quality risks visible. The next production improvements are to remove credentials from the notebook, filter source artifacts before transformation, add automated validation, and record the final DAX measures and dashboard refresh results.