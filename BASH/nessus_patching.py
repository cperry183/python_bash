import tenable.nessus
import pandas as pd
import os

def normalize_vulnerability_data(df):
    # Replace empty strings with 'Unknown'
    df.replace('', 'Unknown', inplace=True)

    # Handle missing values in numeric columns
    numeric_columns = df.select_dtypes(include=['int64', 'float64'])
    for col in numeric_columns:
        df[col].fillna(-999, inplace=True)

    # Handle missing values in categorical columns
    categorical_columns = df.select_dtypes(include=['object'])
    for col in categorical_columns:
        df[col].fillna('Unknown', inplace=True)

    # Convert categorical columns to lowercase
    for col in categorical_columns:
        df[col] = df[col].astype('str').str.lower()

    # Normalize date formats
    date_columns = ['published_date', 'last_modified_date']
    for col in date_columns:
        df[col] = pd.to_datetime(df[col])

    return df

def create_ansible_playbook(vulnerabilities_df):
    # Extract hostname, vulnerability severity, and vulnerability description
    vulnerabilities_df = vulnerabilities_df[['hostname', 'severity', 'description']]

    # Create Ansible playbook structure
    playbook = {
        "hosts": "all",
        "become": True,
        "tasks": []
    }

    # Iterate through each vulnerability and create Ansible tasks
    for index, row in vulnerabilities_df.iterrows():
        hostname = row['hostname']
        severity = row['severity']
        description = row['description'].replace('\n', ' ')

        # Create Ansible task to patch vulnerability based on severity
        if severity == 'high':
            task = {
                "name": f"Patch high severity vulnerability on {hostname}",
                "apt": {
                    "name": f"vulnerability-package-{description}",
                    "update_cache": "yes"
                }
            }
        elif severity == 'medium':
            task = {
                "name": f"Patch medium severity vulnerability on {hostname}",
                "yum": {
                    "name": f"vulnerability-package-{description}",
                    "update_cache": "yes"
                }
            }
        else:
            continue

        # Add task to the playbook
        playbook['tasks'].append(task)

    # Schedule playbook execution at 2:00 AM
    playbook['schedule'] = {
        "cron": "0 2 * * *"
    }

    # Save Ansible playbook to a file
    with open('patch_vulnerabilities.yml', 'w') as playbook_file:
        yaml.dump(playbook, playbook_file, default_flow_style=False)

# Connect to Tenable Nessus
nessus_host = '<your-nessus-server-hostname>'
nessus_port = 443
nessus_username = '<your-nessus-username>'
nessus_password = '<your-nessus-password>'

nessus = tenable.nessus.Nessus(
    host=nessus_host,
    port=nessus_port,
    username=nessus_username,
    password=nessus_password
)

# Get a list of all vulnerabilities
vulnerabilities = nessus.vulnerabilities.get()

# Convert the vulnerabilities data to a Pandas DataFrame
vulnerabilities_df = pd.DataFrame(vulnerabilities)

# Normalize the vulnerability data
vulnerabilities_df = normalize_vulnerability_data(vulnerabilities_df)

# Create Ansible playbook to patch affected servers
create_ansible_playbook(vulnerabilities_df)

