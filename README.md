# Retail Sales Analysis (Synthetic Data)

An end-to-end retail analytics project on a **synthetic** dataset for a 6-outlet sports and lifestyle chain
(2 mall EBOs, 3 standalone EBOs and 1 discount outlet), covering January and February 2026.
All data is randomly generated. The brand, stores, products and customers are fictional.

**Tools:** Python (data generation), MySQL (analysis queries), Power BI (dashboards), Excel (pivot tables).

> **Status: work in progress.** Store performance, weekday vs weekend and product sales are done in SQL and Power BI.
> The Python (pandas) analysis and the customer, discount and peak-hour problems are next.

## Repository structure

```
├── README.md
├── generate_synthetic_retail.py   # builds the dataset; supports appending more months
├── requirements.txt
├── data/                          # six CSV tables
├── sql/                           # MySQL queries, one file per topic
│   ├── 00_import_checks.sql
│   ├── 01_store_performance.sql
│   ├── 02_weekday_weekend.sql
│   └── 03_product_sales.sql
└── powerbi/                       # .pbix file and dashboard screenshots (images/)
```

## Data model

| Table | Grain | Key |
|---|---|---|
| `stores` | one row per store | `store_id` |
| `product_master` | one row per product | `product_code` |
| `daily_footfall` | one row per store per day | `store_id`, `date` |
| `sales_report` | one row per bill | `bill_id` |
| `product_sales` | one row per product line on a bill | `bill_id`, `line_no` |
| `customer_details` | one row per bill | `bill_id` |

```
stores ──< sales_report >── customer_details
              │
              └──< product_sales >── product_master
stores ──< daily_footfall
```

Key definitions: `line_value = quantity x mrp x (1 - discount_pct / 100)`, `total_value` = sum of a bill's `line_value`,
conversion = bills / footfall, ATV = net sales / bills. Ratios are always calculated from totals, never averaged across days.

## What the data is built to look like

Reference store (Indiranagar, ST03): weekday footfall about 200-260 (mostly 230-245), weekend about 650 per day,
conversion 20-25% on weekdays and 20-23% on weekends, UPS between 2 and 3, ATV of 4,000-5,000 on weekdays and
5,500-6,000 on weekends. The other stores scale from it. Republic Day is treated like a weekend, and 10 Jan to
8 Feb is an end-of-season sale with deeper discounts.

## Analysis progress

| # | Problem | Status |
|---|---|---|
| 1 | Store performance ranking (footfall x conversion x ATV) | Done (SQL, Power BI) |
| 2 | Weekday vs weekend gap | Done (SQL, Power BI) |
| 3 | Conversion diagnosis | Planned |
| 4 | Impact of the end-of-season sale | Planned |
| 5 | Category mix and discount depth | In progress (product sales done) |
| 6 | Basket analysis | Planned |
| 7 | Repeat customers | Planned |
| 8 | Peak-hour planning | Planned |
| 9 | Mall vs standalone vs discount store | Planned |
| 10 | Sales target and shortfall tracking | Planned |

## Key findings so far

**Store performance** (net sales: 14.09 crore in total)
- Orbit Mall (2.94 Cr) and Galleria Mall (2.83 Cr) lead, together about 41% of net sales. They win on both footfall (9-14% above the reference store) and basket size (4-5% above).
- The discount outlet has the most footfall of any store but ranks 5th, because its ATV is about 38% below the reference store.
- Mysuru Road ranks last mainly because of low footfall (about 23% below the reference store); its conversion and ATV are close to the others.
- Conversion is nearly the same everywhere (21.9% to 22.4%), so footfall and basket size explain the ranking.

**Weekday vs weekend**
- Weekends are 18 of 59 days (31%) but bring in 59.4% of net sales.
- A weekend day has about 2.7 times the footfall of a weekday per store (667 vs 244), a higher ATV (about 5,380 vs 4,200), and slightly lower conversion (21.6% vs 22.6%).

**Products**
- Footwear is 43.5% of net sales but only 24% of units; apparel and accessories bring the volume.
- Running Shoes lead on net sales (1.15 Cr, 8.2% of the total); Crew Socks lead on units (6,423).
- The top 5 products by net sales contribute about 30% of net sales, and four of them are footwear.

## Screenshots

Add your dashboard images to `powerbi/images/` and uncomment these lines.

<!--
![Store overview](powerbi/images/store_overview.png)
![Product sales](powerbi/images/product_sales.png)
-->

## Reproduce or extend the data

Requires Python 3.9+, `pandas` and `numpy` (`pip install -r requirements.txt`).

```bash
# first load
python generate_synthetic_retail.py --start 2026-01-01 --end 2026-02-28 --seed 42 --out data

# add March later (bill ids and customers continue; existing rows are untouched)
python generate_synthetic_retail.py --start 2026-03-01 --end 2026-03-31 --seed 42 --out data --append
```

The same seed and date always produce the same day, and `--append` refuses overlapping dates.
To run the SQL, import the CSVs into a MySQL schema called `retail` and run `sql/00_import_checks.sql` first.

## Limitations

- Two months only, so there are no trends or seasonality yet.
- One reference store drives the scaling for the others; the numbers are illustrative, not real.
- No cost, margin or stock data, so profit analysis is not possible.
- Customer attributes (age, gender) and product sizes/colours are random and independent of what is bought,
  so differences across them are not meaningful. Basket pairs reflect product popularity, not true affinity.
