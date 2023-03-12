#!/bin/bash
rm nohup.out
nohup sudo docker-compose up &
./logtail.sh
