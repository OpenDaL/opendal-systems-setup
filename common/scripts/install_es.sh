#!/bin/bash
set -e  # Make sure errors will stop execution


wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.1-amd64.deb -P ~/temp
dpkg -i ~/temp/elasticsearch-7.2.1-amd64.deb
rm ~/temp/elasticsearch-7.2.1-amd64.deb
