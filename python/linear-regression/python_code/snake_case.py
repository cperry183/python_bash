#!/usr/bin/enc python3.12

import csv

# Define file paths
snake_names_file = 'snake_case_names.txt'
input_csv_file = 'input.csv'
output_csv_file = 'output.csv'

# Load snake names from the file into a list
with open(snake_names_file, 'r') as snake_names_file:
    snake_names = [line.strip() for line in snake_names_file]

# Create a dictionary to map original names to snake names
name_mapping = {}
for snake_name in snake_names:
    original_name = snake_name.lower().replace('_', ' ')
    name_mapping[original_name] = snake_name

# Function to replace names
def replace_names(name):
    return name_mapping.get(name.lower(), name)

# Open input CSV and output CSV files
with open(input_csv_file, 'r', newline='') as infile, open(output_csv_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    # Iterate through rows and replace names
    for row in reader:
        updated_row = [replace_names(cell) for cell in row]
        writer.writerow(updated_row)

print("Names replaced successfully.")
