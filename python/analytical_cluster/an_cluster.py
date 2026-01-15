import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import LabelEncoder, StandardScaler

# Load the data into a DataFrame
df = pd.read_csv('hospital-inpatient-discharges-sparcs-de-identified-2016.csv')
print(df.columns)
print(df.head())

# Replace '120 +' with 120
df['Length of Stay'] = df['Length of Stay'].replace('120 +', 120).astype(float)

# Select the relevant variables
relevant_variables = ['Age Group', 'Length of Stay', 'Total Charges']

# Extracting relevant data
data = df[relevant_variables].copy()

label_encoders = {}
for column in ['Age Group']:
    le = LabelEncoder()
    data[column] = le.fit_transform(data[column])
    label_encoders[column] = le

# Scaling the data
scaler = StandardScaler()
data_scaled = scaler.fit_transform(data)

# Explicitly set n_init to suppress the future warning
kmeans = KMeans(n_clusters=2, n_init=10)
kmeans.fit(data_scaled)
df['cluster'] = kmeans.labels_

# Checking the number of records in each cluster
print(df['cluster'].value_counts())

# To predict the cluster for a new patient
new_patient = {'Age Group': '50 to 69', 'Length of Stay': 5, 'Total Charges': 5000}

# Pre-process the new_patient data in the same way as the training data
new_patient['Age Group'] = label_encoders['Age Group'].transform([new_patient['Age Group']])[0]
new_patient_data = [list(new_patient.values())]
new_patient_scaled = scaler.transform(new_patient_data)

# Predict the cluster for the new patient
cluster_label = kmeans.predict(new_patient_scaled)[0]
print(f"Predicted cluster for new patient: {cluster_label}")

# Scaling the data
scaler = StandardScaler()
data_scaled = scaler.fit_transform(data)

# Cluster the data
kmeans = KMeans(n_clusters=2)
kmeans.fit(data_scaled)
df['cluster'] = kmeans.labels_

# Checking the number of records in each cluster
print(df['cluster'].value_counts())

# To predict the cluster for a new patient
new_patient = {'Age Group': '50 to 69', 'Length of Stay': 5, 'Total Charges': 5000}

# Pre-process the new_patient data in the same way as the training data
new_patient['Age Group'] = label_encoders['Age Group'].transform([new_patient['Age Group']])[0]
new_patient_scaled = scaler.transform([list(new_patient.values())])

# Predict the cluster for the new patient
cluster_label = kmeans.predict(new_patient_scaled)[0]
print(f"Predicted cluster for new patient: {cluster_label}")

# Save the DataFrame with cluster labels to a CSV file
df.to_csv('cluster_results.csv', index=False)
