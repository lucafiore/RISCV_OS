#!/bin/bash

source ccommon.sh

echo $PATH
dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
echo $dir
