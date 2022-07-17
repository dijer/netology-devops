#!/usr/bin/env bash

err=$?

docker start centos7
if [ $err -eq 0 ]; then
  docker run --name centos7 -d centos:7 sleep 60000000
fi

docker start ubuntu
if [ $err -eq 0 ]; then 
  docker run --name ubuntu -d ubuntu:latest sleep 60000000
fi

docker start fedora
if [ $err -eq 0 ]; then 
  docker run --name fedora -d pycontribs/fedora sleep 60000000
fi

ansible-playbook -i inventory/prod.yml site.yml --vault-password-file bash-password

docker stop ubuntu
docker stop centos7
docker stop fedora
