#!/bin/bash
echo "Start Gazebo Simulation!"
xhost +local:root
docker compose -f ./sim-docker-compose-fix.yaml up