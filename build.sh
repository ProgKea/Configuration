#!/bin/sh

set -xe
gcc -Wall -Wextra -O0 -ggdb -o configurator configurator.c
