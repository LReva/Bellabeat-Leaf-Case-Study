# Bellabeat Leaf Case Study

## Overview

This project analyzes wearable activity data to identify daily routines,
hourly movement rhythms, and feature adoption patterns to inform product
strategy for the Bellabeat Leaf wellness device.

## Business Question

How can Bellabeat use passive activity data to encourage consistent,
sustainable wellness habits among users?

## Data & Methodology

- Fitbit activity, sleep, and weight data
- Two independent 31-day observation windows
- Data cleaned and modeled in BigQuery
- Analysis validated in R
- Visualized in Tableau Public

## Analysis Report (R Markdown)

The full analytical workflow, data validation, and statistical summaries are documented in an R Markdown report.
Due to file size limitations, the rendered HTML is hosted via GitHub Pages rather than previewed directly in the repository.

📄 View the [report](https://lreva.github.io/Bellabeat-Leaf-Case-Study/)

# Tableau Dashboards (Interactive)

The Tableau workbook is structured as a **question-driven analysis** rather than a linear presentation.

The landing dashboard presents a set of business questions that Bellabeat might ask about user behavior. Each question links to a focused dashboard that answers it using the underlying data. Additional dashboards support validation, deeper exploration, and data quality checks.

This structure allows reviewers to explore insights non-linearly while maintaining a clear analytical narrative.

### Core Questions & Dashboards

- **How active are users day to day?** Daily movement patterns, weekday vs weekend differences, and sedentary behavior: [Daily Movement Patterns](https://public.tableau.com/views/LeafAnalysis/ActiveHoursVSSedentaryHours?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- **When during the day does activity happen?** Hourly activity rhythms, intensity patterns, and time-of-day engagement: [Hourly Activity Rhythm](https://public.tableau.com/views/LeafAnalysis/HourlyActivityandCalories?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- **How consistent are users over time?** User-level consistency, active days distribution, and behavioral variability: [Consistency &amp;&amp; Feature Adoption](https://public.tableau.com/views/LeafAnalysis/LogActivity?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### Tableau Public Link

🔗 [Leaf Analysis](https://public.tableau.com/app/profile/olena.reva/viz/LeafAnalysis/Contents)

## Key Insights

- Users are predominantly sedentary, with activity concentrated in short daily windows
- Hourly activity follows stable diurnal patterns across weekdays and weekends
- Engagement varies widely; consistency is a stronger signal than intensity
- Sleep and weight tracking show uneven adoption, indicating onboarding opportunities

## Recommendations

- Introduce time-based nudges during consistent low-activity hours
- Emphasize habit consistency rather than performance goals
- Position sleep insights as optional but high-value for engaged users

## Tools

- SQL (BigQuery)
- Tableau Public
- R (R Markdown)
