#!/bin/bash
zypper --non-interactive -v ref >> /home/docker.log
zypper --non-interactive install docker >> /home/docker.log
chkconfg -add docker >> /home/docker.log
service docker start >> /home/docker.log
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cat > docker-compose.yml <<EOF
version: '3'

services:

  consul:
    image:  gliderlabs/consul-server:latest
    command: "-advertise=10.0.1.224 -server -retry-join=10.0.1.224 -bootstrap-expect=1"
    container_name: consul
    ports:
     - "8500:8500"
     - "8300:8300"
     - "8400:8400"
     - "8301:8301/tcp"
     - "8302:8302/tcp"
     - "8301:8301/udp"
     - "8302:8302/udp"
     - "53:8600/udp"


EOF
/usr/local/bin/docker-compose up -d >> /home/docker.log
