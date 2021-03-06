#!/usr/bin/env bash

## Global settings
# image name
DOCKER_IMAGE="${DOCKER_REPO:-phppgadmin}"

## Initialization
set -e

if [ -n ${IMAGE_VARIANT} ]; then
  image_building_name="${DOCKER_IMAGE}:building_${IMAGE_VARIANT}"
  image_tags_prefix="${IMAGE_VARIANT}-"
  echo "-> set image variant '${IMAGE_VARIANT}' for build"
else
  image_building_name="${DOCKER_IMAGE}:building"
fi
docker_run_options='--detach'
echo "-> use image name '${image_building_name}' for tests"


## Prepare
if [[ -z $(which container-structure-test 2>/dev/null) ]]; then
  echo "Retrieving structure-test binary...."
  if [[ -n "${TRAVIS_OS_NAME}" && "$TRAVIS_OS_NAME" != 'linux' ]]; then
    echo "container-structure-test only released for Linux at this time."
    echo "To run on OSX, clone the repository and build using 'make'."
    exit 1
  else
    curl -sS -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 \
    && chmod +x container-structure-test-linux-amd64 \
    && sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
  fi
fi

# Download tools shim.
if [[ ! -f _tools.sh ]]; then
  curl -L -o ${PWD}/_tools.sh https://gist.github.com/Turgon37/2ba8685893807e3637ea3879ef9d2062/raw
fi
source ${PWD}/_tools.sh


## Test
container-structure-test \
    test --image "${image_building_name}" --config ./tests.yml

## Ensure that required php extensions are installed
extensions=`docker run --rm "${image_building_name}" php -m`
for ext in pgsql; do
  if ! echo "${extensions}" | grep -qi $ext; then
    echo "missing PHP extension '$ext'" 1>&2
    exit 1
  fi
done

#1 Test web access
echo '-> 1 Test web access'
image_name=glpi_1
docker run $docker_run_options --name "${image_name}" --publish 8000:80 "${image_building_name}"
wait_for_string_in_container_logs "${image_name}" 'nginx entered RUNNING state'
sleep 5
# test
if ! curl -v http://localhost:8000 2>&1 | grep --quiet 'browser.php'; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"
