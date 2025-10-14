#!/bin/bash
# By: Ventz Petkov <ventz_petkov@harvard.edu>
# Direct all questions/comments/improvements to ^^ :)

if [ "$#" -ne 1 ]; then
    echo ""
    echo "#########################################################"
    echo "[ ERROR - Missing Link Group ]"
    echo "This is used to link the Nessus Agent to an Organization!"
    echo "#########################################################"
    echo ""; echo "Usage:"; echo "$0 <LINK-GROUP>"; echo "";
    echo "Example:"; echo "$0 GSD"; echo "or"; echo "$0 HMS"; echo "";
    exit
fi
GROUP=$1

# NOTE: make sure you DO NOT have a "/" at the end of the URL
#INSTALL_URL="http://s3.amazonaws.com/nessus-agents"
INSTALL_URL="http://agents.itsec.harvard.edu/nessus"


INSTALL_VERSION="" # will get populated dynamically
INSTALL_NAME="NessusAgent"
# Will use ONE of:
INSTALL_OS_AMAZON="amzn.x86_64.rpm"
INSTALL_OS_DEBIAN="debian6_amd64.deb"
INSTALL_OS_UBUNTU="ubuntu1110_amd64.deb"
INSTALL_OS_RHEL_CENTOS6="es6.x86_64.rpm"
INSTALL_OS_RHEL_CENTOS7="es7.x86_64.rpm"
INSTALL_OS_SLES_11="suse11.x86_64.rpm"
INSTALL_OS_SLES_12="suse12.x86_64.rpm"
INSTALL_OS_SLES_15="suse15.x86_64.rpm"

if [[ -e /etc/os-release ]]; then
        OS=`egrep '^NAME=' /etc/os-release | sed 's/NAME=//' | tr -d \"`
        VERSION=`egrep '^VERSION_ID=' /etc/os-release | sed 's/VERSION_ID=//' | tr -d \"`

        if [[ "$OS" == "Amazon Linux" ]]; then
            echo "Starting Install for: $OS"
            command -v wget >/dev/null 2>&1 || { yum install -y wget; }
            INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
            INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_AMAZON"
            INSTALL_CMD="rpm -ivh "
        elif [[ "$OS" == "Red Hat Enterprise Linux Server" ]]; then
            echo "Starting Install for: $OS"
            command -v wget >/dev/null 2>&1 || { yum install -y wget; }
            INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
            INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_RHEL_CENTOS7"
            INSTALL_CMD="rpm -ivh "
        elif [[ "$OS" == "CentOS Linux" ]]; then
            echo "Starting Install for: $OS"
            command -v wget >/dev/null 2>&1 || { yum install -y wget; }
            INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
            INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_RHEL_CENTOS7"
            INSTALL_CMD="rpm -ivh "
        elif [[ "$OS" == "Ubuntu" ]]; then
            echo "Starting Install for: $OS"
            command -v wget >/dev/null 2>&1 || { apt-get update && apt-get install -y wget; }
            INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
            INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_UBUNTU"
            INSTALL_CMD="dpkg -i "
        elif [[ "$OS" == "Debian GNU/Linux" ]]; then
            echo "Starting Install for: $OS"
            command -v wget >/dev/null 2>&1 || { apt-get update && apt-get install -y wget; }
            INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
            INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_DEBIAN"
            INSTALL_CMD="dpkg -i "
        elif [[ "$OS" == "SLES" ]]; then
	    VERSION=`echo $VERSION | awk -F'.' {'print $1'}`
            if [[ "$VERSION" == "11" ]]; then
            	echo "Starting Install for: $OS 11"
			command -v wget >/dev/null 2>&1 || { yum install -y wget; }
			INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
			INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_SLES_11"
			INSTALL_CMD="rpm -ivh "
            elif [[ "$VERSION" == "12" ]]; then
            	echo "Starting Install for: $OS 12"
		    command -v wget >/dev/null 2>&1 || { yum install -y wget; }
		    INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
		    INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_SLES_12"
		    INSTALL_CMD="rpm -ivh "
            else
                echo "Unsupported SLES version."
            fi
        fi
elif [[ -e /etc/redhat-release ]]; then
	# If there's no "os-release", BUT we have "redhat-release" - THIS MEANS we are at CentOS 6x
        command -v wget >/dev/null 2>&1 || { yum install -y wget; }
        INSTALL_VERSION=$(wget -qO - $INSTALL_URL/VERSION)
        INSTALL_FILE="$INSTALL_NAME-$INSTALL_VERSION-$INSTALL_OS_RHEL_CENTOS6"
        INSTALL_CMD="rpm -ivh ";
else
	echo "System NOT one of: RHEL/CentOS 6 or 7, Debian, Ubuntu, or Amazon AMI"
    echo "If it's Mac OS X, Windows, or another flavor of Linux/BSD - please install manually and let us know to update this installer!"
    exit
fi


# Download and Install!
wget -q "$INSTALL_URL/$INSTALL_VERSION/$INSTALL_FILE"
$INSTALL_CMD "$INSTALL_FILE"
rm -f "$INSTALL_FILE"

# Link!
# Old Key no longer in use: ba71d5afb7819defd6d3c469aaf29dcd35964c6664b71955a9b7bf2529844d75
HOSTNAME=`hostname`
/opt/nessus_agent/sbin/nessuscli agent link --key= --host= --port=8834 --groups=$GROUP --name=$HOSTNAME

/opt/nessus_agent/sbin/nessuscli agent status

