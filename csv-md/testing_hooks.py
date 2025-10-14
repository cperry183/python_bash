#!/usr/bin/env python3

import requests
import logging
import json

# Define the status messages
def get_status_messages(hostname_base):
    status_healthy = f"✅ Host {hostname_base} has successfully rebooted for scheduled maintenance."
    status_unhealthy = f"⚠️ Host {hostname_base} failed to complete the scheduled reboot successfully."
    status_no_reservation = f"⚠️ WARNING: Host {hostname_base} did not detect an active reservation during its scheduled maintenance window."

    return status_healthy, status_unhealthy, status_no_reservation

# Function to send messages to Teams via webhook
def send_teams_webhook(message, webhook_url):
    # Create the payload for the webhook
    payload = {
        "text": message  # The text message to send to Teams
    }

    # Send the request to the Teams webhook
    try:
        response = requests.post(webhook_url, data=json.dumps(payload), headers={"Content-Type": "application/json"})
        if response.status_code == 200:
            logging.info(f"Message successfully sent to Teams channel")
        else:
            logging.error(f"Failed to send message to Teams. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        logging.error(f"Error sending message to Teams: {e}")

# Example usage
if __name__ == "__main__":
    # Set up logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your actual webhook URL
    webhook_url = "DEFINE_URL"

    # Example hostname
    hostname_base = "DEFINE_HOSTNAME"

    # Get the status messages
    status_healthy, status_unhealthy, status_no_reservation = get_status_messages(hostname_base)

    # Send each status message to Teams
    send_teams_webhook(status_healthy, webhook_url)
    send_teams_webhook(status_unhealthy, webhook_url)
    send_teams_webhook(status_no_reservation, webhook_url)

