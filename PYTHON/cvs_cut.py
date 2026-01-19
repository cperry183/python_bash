#!/usr/bin/env python3 

import pandas as pd

# Define the columns to keep
columns_to_keep = ['Family', 'Severity', 'IP Address', 'DNS Name', 'Plugin Output']

# Load the CSV file
df = pd.read_csv('/path/to/your/csvfile.csv')

# Keep only the required columns
df = df[columns_to_keep]

# Save the filtered dataframe back to CSV
df.to_csv('/path/to/your/filtered_csvfile.csv', index=False)

