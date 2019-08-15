# Ansible deployer
---

Ansible Deployer helps with Vizix Deployment on hosts, it has different roles to help you to do tasks while you're having a good time solving Complex Issues.

# Requirements:
  - [Ansible 2.4][ansible] or later
  - Python 2.6 or later on Nodes

# What you can do

  - Perform Provision of the required software to launch Vizix (Install Docker, Add tools like CTop or Docker-compose)
  - Launch Vizix as docker-compose file (Copy compose files, create mongo user, launch vizix-tools, etc)
  - Create a Swarm, join multiple nodes as workers or managers and set their host tag.

You can also:
  - Restore a back-up from a URL, mongo and/or mysql.
  - Create the mongo user.

### Usage

First, we need the host file, use *[hostsFiles/hostsExample.ini][PlHF]* file as example, copy and edit with your own settings.

Once done, use one of the following commands to launch it according your needs:

```sh
$ ansible-playbook -i hostsFiles/hostsExample.ini site-install-vizix.yml
$ ansible-playbook -i hostsFiles/hostsExample.ini site-create-swarm.yml
$ ansible-playbook -i hostsFiles/hostsExample.ini site-provision.yml
$ ansible-playbook -i hostsFiles/hostsExample.ini site-restore-mongo.yml
$ ansible-playbook -i hostsFiles/hostsExample.ini site-restore-mysql.yml
$ ansible-playbook -i hostsFiles/hostsExample.ini site-restoreDB.yml
```

### Available Roles

We have the following roles availables

| Role | README |
| ------ | ------ |
| create-mongo-user | [AnsibleTemplate/roles/create-mongo-user/README.md][PlCMU] |
| launch-vizix | [AnsibleTemplate/roles/launch-vizix/README.md][PlLV] |
| provision | [AnsibleTemplate/roles/provision/README.md][PlP] |
| restore-mongo | [AnsibleTemplate/roles/restore-mongo/README.md][PlRMO] |
| restore-mysql | [AnsibleTemplate/roles/restore-mysql/README.md][PlRMY] |
| create-docker-swarm | [AnsibleTemplate/roles/create-docker-swarm/README.md][PlCDS] |
| join-swarm-manager | [AnsibleTemplate/roles/join-swarm-manager/README.md][PlJSM] |
| join-swarm-worker | [AnsibleTemplate/roles/join-swarm-worker/README.md][PlJSW] |
| set-swarm-labels | [AnsibleTemplate/roles/set-swarm-labels/README.md][PlSSL] |
### ROADMAP

Features to be considered in new versions:
  - ~~Docker Swarm Provision.~~
  - Docker Swarm Install Vizix According to Sizing Guideline.
  - Create BackUps.
  - Upload BackUps to S3 bucket.
  - Move backups between Staging and Prod Hosts.
  - Rancher Set Up.
  - Offline Installation.
  - Analytics Setup.

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [ansible]: <http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>
   [git-repo-url]: <https://github.com/tierconnect/vizix-compose.git>

   [PlHF]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/hostsFiles/hostsExample.ini>
   [PlCMU]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/create-mongo-user/README.md>
   [PlLV]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/launch-vizix/README.md>
   [PlP]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/provision/README.md>
   [PlRMO]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/restore-mongo/README.md>
   [PlRMY]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/restore-mysql/README.md>
   [PlCDS]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/create-docker-swarm/README.md>
   [PlJSM]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/join-swarm-manager/README.md>
   [PlJSW]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/join-swarm-worker/README.md>
   [PlSSL]: <https://github.com/tierconnect/vizix-compose/tree/dev/6.x.x/AnsibleTemplate/roles/set-swarm-labels/README.md>
