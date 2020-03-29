"""Test the output docker image is configured correctly."""
import subprocess
from os import environ

import pytest
import testinfra


@pytest.fixture(scope="session")
def image(request):
    """Run the image under test."""
    docker_image = environ.get("DOCKER_IMAGE") or "jameswilliams1/python-webdriver"
    docker_tag = environ.get("DOCKER_TAG") or "3.7-slim-buster-all"
    image_name = ":".join((docker_image, docker_tag))
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
