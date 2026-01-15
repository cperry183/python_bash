#!/usr/bin/env python3.12

import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline

def load_and_preprocess_data(filename='output.csv', encoder=None):
    df = pd.read_csv(filename)
    df.replace('Too Few to Report', np.nan, inplace=True)
    df.dropna(subset=['number_discharges', 'excess_readmission_ratio', 'predicted_readmission_rate', 'expected_readmission_rate', 'number_readmissions'], inplace=True)

    for column in df.columns:
        try:
            df[column] = df[column].astype(float)
        except:
            pass

    if encoder is None:
        encoder = OneHotEncoder(drop='first', sparse_output=False).fit(df[['Facility_Name', 'state']])
    encoded_features = encoder.transform(df[['Facility_Name', 'state']])
    df_encoded = pd.DataFrame(encoded_features, columns=encoder.get_feature_names_out(['Facility_Name', 'state']), index=df.index)  # Added index=df.index to align indices
    df = pd.concat([df.drop(columns=['Facility_Name', 'state']), df_encoded], axis=1)

    return df, encoder

def train_model(X, y):
    pipeline = make_pipeline(
        SimpleImputer(strategy='mean'),
        StandardScaler(),
        LinearRegression()
    )
    pipeline.fit(X, y)
    return pipeline

def evaluate_model(pipeline, X, y):
    y_pred = pipeline.predict(X)
    mse = mean_squared_error(y, y_pred)
    print('Mean squared error:', mse)

def make_and_save_predictions(pipeline, df, facility_name, output_filename='parkview_noble_hospital_predictions.csv'):
    facility_name_col = f'Facility_Name_{facility_name}'  # Potential Issue: Check if this column really exists
    if facility_name_col not in df.columns:
        print(f"No data found for {facility_name_col}")
        return

    facility_name_df = df[df[facility_name_col] == 1].drop(['number_discharges', 'excess_readmission_ratio', 'predicted_readmission_rate', 'expected_readmission_rate', 'number_readmissions'], axis=1)
    prediction = pipeline.predict(facility_name_df)
    columns = ['number_discharges_pred', 'excess_readmission_ratio_pred', 'predicted_readmission_rate_pred', 'expected_readmission_rate_pred', 'number_readmissions_pred']
    prediction_df = pd.DataFrame(prediction, columns=columns)
    prediction_df.to_csv(output_filename, index=False)
    print(f'Predictions saved to {output_filename}')

if __name__ == "__main__":
    df, encoder = load_and_preprocess_data()

    # Prepare your features and target variables
    X = df.drop(['number_discharges', 'excess_readmission_ratio', 'predicted_readmission_rate', 'expected_readmission_rate', 'number_readmissions'], axis=1)
    y = df[['number_discharges', 'excess_readmission_ratio', 'predicted_readmission_rate', 'expected_readmission_rate', 'number_readmissions']]  # Included 'number_readmissions'

    # Train the model
    pipeline = train_model(X, y)

    # Make and save predictions
    make_and_save_predictions(pipeline, df, 'parkview_noble_hospital')
