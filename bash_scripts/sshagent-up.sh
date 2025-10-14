#!/usr/bin/env bash
export PDSH_SSH_ARGS_APPEND='-o StrictHostKeyChecking=no'
eval  `ssh-agent -s`
ssh-add -l
ssh-add .ssh/id_rsa_root

