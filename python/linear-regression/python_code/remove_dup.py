#!/usr/bin/enc python3.12

def remove_duplicate_entries(input_file, output_file):
  with open(input_file, "r") as f:
    lines = f.readlines()
  unique_lines = set()
  for line in lines:
    unique_lines.add(line)
  with open(output_file, "w") as f:
    for line in unique_lines:
      f.write(line)

remove_duplicate_entries("input.txt", "output.txt")
