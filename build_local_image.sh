#!/bin/sh

# This file is useful only for local testing and is not part of the CI/CD,
# nor is it used to create any output images.
#
# Requires:
#   - docker

set -o errexit -o nounset

build_image () {
  # Build a single docker image for testing locally
  docker build \
  --tag 'jameswilliams1/python-webdriver:3.7-slim-buster-all' \
  --file ./3.7/slim-buster/all/Dockerfile .
}

build_image
