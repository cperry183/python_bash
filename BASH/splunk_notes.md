 # Download Links for Splunk Agent:

wget -O splunkforwarder-9.2.1-78803f08aabb-x64-release.msi "https://download.splunk.com/products/universalforwarder/releases/9.2.1/windows/splunkforwarder-9.2.1-78803f08aabb-x64-release.msi"
 
wget -O splunkforwarder-9.2.1-78803f08aabb.x86_64.rpm "https://download.splunk.com/products/universalforwarder/releases/9.2.1/linux/splunkforwarder-9.2.1-78803f08aabb.x86_64.rpm"

wget -O splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.2.1/linux/splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz"


# Please update your installed scripts with the new Splunk Deployment Server: splunk-deploy02.med.harvard.edu.

# Windows Command Update:
"C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe" set deploy-poll splunk-deploy02.med.harvard.edu:8089
 
# Linux Command Update:
/opt/splunkforwarder/bin/splunk set deploy-poll splunk-deploy02.med.harvard.edu:8089
 
 

# One example of an install script. If you need more information, please reach out to me. 

#####Splunk Agent UF Linux Tar install script example########
/opt/splunkforwarder/bin/splunk stop
rm -Rf /opt/splunkforwarder/

wget -O splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.2.1/linux/splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz"
tar xvzf splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz -C /opt

/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd <your password for Splunk local admin app user>

###One or the other:
/opt/splunkforwarder/bin/splunk splunk enable boot-start
### If Splunk is being run by a different user then root for exmaple "splunk"
/opt/splunkforwarder/bin/splunk splunk enable boot-start -user splunk

##This step required logging in with the admin and password that was created from --seed-passwd
##This setting can also be set as a configuration file if you do not want to authenticate.
/opt/splunkforwarder/bin/splunk set deploy-poll splunk-deploy02.med.harvard.edu:8089 

/opt/splunkforwarder/bin/splunk restart