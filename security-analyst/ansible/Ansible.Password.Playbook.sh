To install the library:
sudo pip install passlib

Generate a hash for the new root password you want:
python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"

Simple Ansible playbook:

- hosts: test
  tasks:
    - name: Change root password
    - user: name=arl update_password=always password=<HASHGOESHERE>
