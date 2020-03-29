"""Verify the output docker image is configured correctly.

This is run from the CI where the environment sets the image under test for
the current run using DOCKER_IMAGE and DOCKER_TAG.

Note: This file will not run from the CLI using 'pytest'.
"""
import subprocess
from os import environ

import pytest
import testinfra


@pytest.fixture(scope="session")
def docker_image(request):
    """Run the image under test in the background.

    Destroys the image after all tests have ran.

    Yields:
        host: running container as a testinfra host.
    """
    # TODO drop or statements after fully setting up CI
    image = environ.get("DOCKER_IMAGE") or "jameswilliams1/python-webdriver"
    docker_tag = environ.get("DOCKER_TAG") or "3.7-slim-buster-all"
    image_name = ":".join((image, docker_tag))
    docker_id = (
        subprocess.check_output(["docker", "run", "--detatch", image_name])
        .decode()
        .strip()
    )
    # return a testinfra connection to the container
    host = testinfra.get_host("docker://" + docker_id)
    request.cls.host = host
    yield host
    # force remove container after testing
    subprocess.check_call(["docker", "rm", "--force", docker_id])
