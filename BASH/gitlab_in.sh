#!/usr/bin/env bash 

# Set GitLab root password in GitLab EE
GITLAB_ROOT_PASSWORD="NewSecurePassword123"


yum update -y --disablerepo=* --enablerepo=els* --enablerepo=centos-7* --exclude=sensu --exclude=puppet-agent
yum install --disablerepo=* --enablerepo=els* --enablerepo=centos-7* -y curl policycoreutils-python openssh-server perl
for SYS in start enable; do systemctl ${SYS} sshd;done
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # Allow HTTP traffic
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # Allow HTTPS traffic
systemctl reload firewalld
yum install postfix
systemctl enable postfix
systemctl start postfix
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
export EXTERNAL_URL="https://$HOSTNAME";  yum install gitlab-ee-17.3.2


# Check if the GitLab rails console is accessible
if command -v gitlab-rails > /dev/null; then
  echo "Setting GitLab root password..."

  # Run the command to set the root password
  gitlab-rails runner "user = User.find_by_username('root'); user.password = '$GITLAB_ROOT_PASSWORD'; user.password_confirmation = '$GITLAB_ROOT_PASSWORD'; user.save!"

  if [ $? -eq 0 ]; then
    echo "Password for root user successfully updated."
  else
    echo "Failed to update root password. Please check for errors."
  fi
else
  echo "gitlab-rails command not found. Make sure GitLab is installed properly."
fi

