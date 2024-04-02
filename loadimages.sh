#!/usr/bin/env bash

echo "正在从当前文件夹恢复镜像"

for file in *;do
  if [ -d "$file" ];then
    continue
  fi
  echo "docker load -i $file"
  docker load -i "$file"
done
