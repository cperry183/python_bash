#!/usr/bin/env python3
import logging
import subprocess
import sys
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

from o2_config import hostname_base,schedule_path,maintenance_path
from read_schedule import get_schedule
from read_date_counter import DateCounter

sys.path.append('..')
from nessus_remediations import cli_args,Remediation
from core_config import *
from slack_handler import *

status_healthy = f":white_check_mark: : {hostname_base} rebooted successfully for maintenance"
status_unhealthy = f":warning: : {hostname_base} did not complete scheduled reboot successfully"

def check_maintenance_window():
    schedule = get_schedule() # check if we're in an active maintenance window
    maintenance_day = int([key for key, value in schedule.items() if hostname_base in value][0])
    counter = DateCounter()
    if not counter.paused and maintenance_day == counter.counter:
        logger.info(f"Node {hostname_base} detected its maintenance day")
        check_reservation()

def check_reservation():
    # active_reservation = subprocess.check_output(
    #     "/usr/bin/sinfo -T | awk '{print $2,$1}' | grep '^ACTIVE' | awk '{print $2}'",
    #     shell=True
    # ).decode().strip()
    node_state = subprocess.check_output(
        f"/usr/bin/sinfo -h -O StateCompact --node {hostname_base}",
        shell=True
    ).decode().strip()
    # reservation_index = active_reservation.split("-")[1]
    if "maint" in node_state or "$" in node_state:
        invoke_updates()
    else:
        send_slack_alert(
            text = f"WARNING: {hostname_base} did not detect an active reservation during its maintenance window"
        )
        logger.error(f"Error: Node state was not valid: ({node_state})")
        dump_logs()


def dump_logs(level="debug"):
    squeue = subprocess.check_output("/usr/bin/squeue -w localhost", shell=True).decode()
    logger.error(f"Squeue: {squeue}")
    if level == "debug":
        full_job_info = subprocess.check_output(
            "/usr/bin/squeue -w localhost --noheader |awk '{print $1}'|xargs -I % scontrol show job %",
            shell=True).decode()
        logger.error(f"Full job info: \n {full_job_info}")

def set_reboot_trigger(ts):
    try:
        crontab = "/var/spool/cron/root"
        script_line = f"cd {maintenance_path}; source ../pyenv/bin/activate; \
                        {maintenance_path}/o2_health_check.py {ts}"
        cron_line = f"@reboot {script_line} \n"
        with open(crontab, "a") as f:
            f.writelines(cron_line)
    except Exception as err:
        logger.error(f"Exception encountered setting reboot rigger: {err}")

def invoke_updates():
    args = cli_args()
    args.update_all = True
    remediation = Remediation(
        args                = args,
        logger              = logger,
        host                = host,
        os_family           = os_family,
        managed_repos       = managed_repos,
        nessus_cli          = '/opt/nessus_agent/sbin/nessuscli',
        info_file           = info_file,
        excluded_pkgs       = args.excluded_pkgs.split(","),
        nessus_api_host     = args.api_host,
        nessus_api_user     = args.api_user,
        nessus_api_pw       = args.api_pw,
        es_host             = args.es_host,
        es_index            = args.es_index,
    )
    if remediation.check_needed_reboot():
        status_down = f":arrow_down: : {hostname_base} rebooting for maintenance"
        result = send_slack_alert(text=status_down)
        logger.info(result)
        set_reboot_trigger(ts=result['ts'])
        subprocess.check_output(f"sleep 60; /bin/scontrol reboot ASAP nextstate=resume reason=SEC_REMEDIATIONS {hostname_base}", shell=True)

def send_email_alert(subject, body):
    sender_email = "devops@listserv.med.harvard.edu"
    receiver_email = "ce1f6a8d.HU.onmicrosoft.com@amer.teams.ms"

    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = subject

    message.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP("smtp-mail.outlook.com", 25) as server:
            server.sendmail(sender_email, receiver_email, message.as_string())
        logger.info("Email sent successfully")
    except Exception as e:
        logger.error(f"Failed to send email: {e}")

if __name__ == '__main__':
    logger = logging.getLogger()
    logging.basicConfig(
        level=logging.INFO,
        format=f"[{hostname_base}]" + "[{levelname}][{asctime}]: {message}",
        style="{",
        filename=f"{schedule_path}/logs/o2-updates.log")
    if 'dev' in schedule_path:
        ### We're a dev node - always update/reboot and exit:
        invoke_updates()
        exit()
    else:
        check_maintenance_window()
