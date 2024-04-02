#!/usr/bin/env bash

echo "正在备份全部镜像文件至当前文件夹"

for image_id in $(docker images | awk '{print $3}');do
  if [ "$image_id" == "IMAGE" ];then
    continue
  fi
  echo "docker save $image_id -o $image_id.tar"
  docker save "$image_id" -o "$image_id.tar"
done
