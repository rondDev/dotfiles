#!/bin/sh

file_path=$1
# file=$(<$file_path)

file_name=$(basename "$file_path")

response=$(curl -s \
  -H "origin: https://" \ # TODO: add domain
  -F key=abc \ # TODO: add key
  -F name=$file_path \
  -F d=@$file_path \
  https://) # TODO add domain

a=$(echo $response | jq '.url' | tr -d '"')
echo $a
