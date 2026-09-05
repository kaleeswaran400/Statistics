# Digital Marketing Analysis

This folder contains a statistical analysis of digital advertising campaign performance using Python.

## Customer Shopping Behaviour Project

- [Project report](PROJECT_REPORT.md)
- [Customer shopping behaviour notebook](Customer_shopping%20_behaviour.ipynb)
- [Customer Behaviour Power BI dashboard](Customer%20Behavior%20Dashboard.pbix)

## Notebook

- [Digital Marketing Analysis using Python](Digital%20Marketing%20Analysis%20using%20Python.ipynb)

## Analysis Included

- Data quality checks and duplicate-value summaries
- Campaign-name, location, and device cleaning
- Cost-per-click (CPC), cost-per-acquisition (CPA), and return-on-ad-spend (ROAS)
- One-sample and independent-sample t-tests
- One-way ANOVA and two-way ANOVA
- Tukey HSD post-hoc comparisons
- Combined statistical findings and interpretation

## Main Conclusion

The analysis indicates that the advertising platform significantly affects ROAS, CPC, CPA, CTR, and revenue. Tukey HSD comparisons identify significant differences between Google Ads, Meta Ads, and TikTok Ads for these metrics. Impressions do not show a statistically significant difference between platforms.

## Requirements

The notebook uses Python with pandas, NumPy, SciPy, and statsmodels.

The input CSV files are loaded from local paths in the notebook. Update those paths before running the notebook on another machine.
