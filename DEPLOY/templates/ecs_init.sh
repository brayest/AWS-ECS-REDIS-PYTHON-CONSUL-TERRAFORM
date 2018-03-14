#!/bin/bash
ECS_CLUSTER='default' > /etc/ecs/esc.confing
start ecs
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
export LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
cat > docker-compose.yml <<EOF
version: '3'

services:

  consul:
    image:  gliderlabs/consul-server:latest
    command: "-advertise=$LOCAL_IP -retry-join=10.0.1.224"
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

  registrator:
    image: gliderlabs/registrator:latest
    command: "consul://$LOCAL_IP:8500"
    container_name: registrator
    depends_on:
    - consul
    volumes:
    - /var/run/docker.sock:/tmp/docker.sock


    
EOF
/usr/local/bin/docker-compose up -d >> /home/docker.log


