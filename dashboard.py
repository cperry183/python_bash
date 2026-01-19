import pandas as pd
import dash
import plotly.graph_objects as go
from dash import dcc
from dash import html
from dash.dependencies import Input, Output

# Create the DataFrame
data = pd.DataFrame({
    "Vehicle": ["2019 Tesla Model 3 AWD", "2023 Ford Mustang Mach-E Premium AWD Extended Range", "2022 Rivian R1T Large Pack, 20\" all-terrain tires"],
    "Real Range (miles)": [290, 285, 254],
    "EPA Range (miles)": [332, 290, 314],
    "Efficiency (mi/kWh)": [4.25, 3.10, 2.03],
    "Level 1 Charging (120V)": ["19 hours", "15 hours", "11 hours"],
    "Level 2 Charging (240V)": ["9 hours", "7 hours", "4 hours"],
    "DC Fast Charging (150 kW)": ["45 minutes", "38 minutes", "75 minutes"],
})

# Convert charging times to minutes
for col in ["Level 1 Charging (120V)", "Level 2 Charging (240V)", "DC Fast Charging (150 kW)"]:
    data[col] = data[col].apply(lambda x: int(x.split()[0]) * 60 if 'hour' in x else int(x.split()[0]))

# Create the dashboard
app = dash.Dash(__name__)

# Create the layout of the dashboard
app.layout = html.Div(children=[
    html.H1("Electric Vehicle Comparison Dashboard"),
    dcc.Dropdown(
        id="vehicle-type",
        options=[{"label": vehicle, "value": vehicle} for vehicle in data["Vehicle"]],
        value=["2019 Tesla Model 3 AWD"],
        multi=True
    ),
    dcc.Graph(
        id="comparison-chart",
    ),
])

# Add a callback to update the graph when the vehicle type is changed
@app.callback(
    Output("comparison-chart", "figure"),
    Input("vehicle-type", "value"),
)
def update_graph(vehicle_types):
    if isinstance(vehicle_types, str):
        vehicle_types = [vehicle_types]
    fig = go.Figure()
    for vehicle_type in vehicle_types:
        data_filtered = data[data["Vehicle"] == vehicle_type]
        fig.add_trace(go.Bar(
            x=["Real Range (miles)", "EPA Range (miles)", "Efficiency (mi/kWh)",
               "Level 1 Charging (120V)", "Level 2 Charging (240V)", "DC Fast Charging (150 kW)"],
            y=[data_filtered[col].values[0] for col in ["Real Range (miles)", "EPA Range (miles)", "Efficiency (mi/kWh)",
                                                        "Level 1 Charging (120V)", "Level 2 Charging (240V)", "DC Fast Charging (150 kW)"]],
            name=vehicle_type
        ))

    fig.update_layout(
        title="Comparison of Selected Vehicles",
        xaxis_title="Parameter",
        yaxis_title="Value",
        barmode='group'
    )
    return fig

# Run the dashboard
if __name__ == "__main__":
    app.run_server()

