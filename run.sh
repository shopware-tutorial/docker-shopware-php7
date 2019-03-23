#!/bin/bash

docker run --name shopware -d -p 80:80 -p 2222:22 -p 3306:3306 wesolowski/shopware-php72
