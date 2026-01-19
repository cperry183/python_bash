#!/bin/bash

remove_existing_repo() {
    echo "Removing existing GitLab EE repository configuration..."
    rm -rf /etc/yum.repos.d/gitlab_gitlab-ee.repo
}

add_gitlab_repo() {
    echo "Adding GitLab EE repository..."
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
}

check_upgrade_path() {
    echo ""
    echo "Check the upgrade path:"
    echo "https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/?current=16.3.0&distro=centos"
    echo ""
}

display_current_version() {
    echo "Current GitLab version:"
    gitlab-rake gitlab:env:info | grep "GitLab version"
}

prompt_for_version() {
    read -p "Enter the GitLab version you want to upgrade to (e.g., 16.4.0): " gitlab_version
}

update_gitlab() {
    echo "Updating GitLab to version $gitlab_version..."
    yum install -y gitlab-ee-$gitlab_version
}

verify_installation() {
    echo "GitLab has been updated to version $gitlab_version"
    gitlab-rake gitlab:env:info | grep "GitLab version"
}

check_background_migrations() {
    echo "Checking background migrations..."
    sudo gitlab-rails runner -e production 'puts Gitlab::BackgroundMigration.remaining' && 
    sudo gitlab-rails runner -e production 'puts Gitlab::Database::BackgroundMigration::BatchedMigration.queued.count'
}

main() {
    remove_existing_repo
    add_gitlab_repo
    check_upgrade_path
    display_current_version
    prompt_for_version
    update_gitlab
    verify_installation
    check_background_migrations
}

main
