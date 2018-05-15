#!/usr/bin/env bash
KETVERSION=${1:-"1.11.0"}

if [ "$USER" != "root" ]; then
  echo "Must run as root or with sudo."
  exit 1
fi

if [ ! -f trainees.yaml ]; then
  echo "ERROR: No trainees.yaml found. Unable to create users."
  exit 2
fi

tarball=kismatic-v${KETVERSION}-`uname|tr 'A-Z' 'a-z'`-amd64.tar.gz
curl -o kismatic.tar.gz -L https://github.com/apprenda/kismatic/releases/download/v${KETVERSION}/${tarball}

groupadd training
USERS=$(grep '^-\ user:' trainees.yaml |awk '{print $3}')
for u in $USERS; do
  useradd -s /bin/bash -g training -m ${u}
  cp -p kismatic.pem /home/${u}
  mkdir /home/${u}/.ssh
  cp -p /home/ubuntu/.ssh/authorized_keys /home/${u}/.ssh/
  tar -C /home/${u} -zxf  kismatic.tar.gz
  chown -R ${u}:training /home/${u}
done

ansible-playbook kismatic-ansible.yaml -e @trainees.yaml
