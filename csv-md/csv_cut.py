#!/usr/bin/env python3

import pandas as pd

# Define the columns to keep
columns_to_keep = ['Family', 'Severity', 'IP Address', 'DNS Name', 'Plugin Output']

# Load the CSV file
df = pd.read_csv('/home/chp6694_adm/linux.csv')

# Keep only the required columns
df = df[columns_to_keep]

# Save the filtered dataframe back to CSV
df.to_csv('/home/chp6694_adm/sorted.csv', index=False)
