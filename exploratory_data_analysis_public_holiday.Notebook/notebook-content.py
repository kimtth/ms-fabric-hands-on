# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "01cd0ac8-a366-4b71-9cbf-71965011efa6",
# META       "default_lakehouse_name": "DataScienceLakehouse",
# META       "default_lakehouse_workspace_id": "a6f7cb63-8ec0-4f7d-b368-d3277e9bded7",
# META       "known_lakehouses": [
# META         {
# META           "id": "01cd0ac8-a366-4b71-9cbf-71965011efa6"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

import pandas as pd

# Path to the Parquet file
# !Important - Use one of the sample datasets provided by Fabric.
path = "/lakehouse/default/Files/public-holiday"

# Read the Parquet file
df = pd.read_parquet(path)

# Display the first few rows
print(df.head())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load the Parquet file
df = pd.read_parquet(path)

# Convert date column to datetime
df['date'] = pd.to_datetime(df['date'], errors='coerce')

# Basic info
print("===== Basic Info =====")
print(f"Shape: {df.shape}")
print("Columns:", df.columns.tolist())
print(df.info())

# Summary stats for numeric columns (none in this dataset, so skip)
print("\n===== Missing Values =====")
print(df.isnull().sum())

# Value counts for categorical columns
categorical_cols = ['countryOrRegion', 'holidayName', 'normalizeHolidayName', 'isPaidTimeOff', 'countryRegionCode']
for col in categorical_cols:
    print(f"\nColumn: {col}")
    print(df[col].value_counts().head(10))


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Visualizations
sns.set(style="whitegrid")

# 1. Holidays per country
plt.figure(figsize=(10, 6))
sns.countplot(y='countryOrRegion', data=df, order=df['countryOrRegion'].value_counts().index)
plt.title("Number of Holidays per Country")
plt.show()

# 2. Top holiday names
plt.figure(figsize=(10, 6))
sns.countplot(y='normalizeHolidayName', data=df, order=df['normalizeHolidayName'].value_counts().head(10).index)
plt.title("Top 10 Holidays")
plt.show()

# 3. Paid Time Off distribution
plt.figure(figsize=(6, 4))
sns.countplot(x='isPaidTimeOff', data=df)
plt.title("Paid Time Off Distribution")
plt.show()

# 4. Holidays over time
plt.figure(figsize=(12, 6))
sns.histplot(df['date'], bins=30, kde=False)
plt.title("Holiday Dates Distribution")
plt.show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
