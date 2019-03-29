#!/bin/sh

if [ $# -ne 2 ]; then
        echo "usage: $0 terraform-version bin-dir"
        exit 2
fi

version=$1
bin="$2"
if [ ! -x "$bin/terraform-$version" ]; then
  mkdir -p "$bin"
  cd "$bin"
  os=$(uname -s | tr '[A-Z]' '[a-z]')
  arch=$(uname -m)
  case $arch in
    x86_64) arch=amd64 ;;
  esac
  dist=https://releases.hashicorp.com/terraform/$version/terraform_${version}_${os}_${arch}.zip
  echo $dist
  zf=$(basename $dist)
  wget $dist
  unzip $zf
  mv terraform terraform-$version
fi

echo "$bin/terraform-$version"
