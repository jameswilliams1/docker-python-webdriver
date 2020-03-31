#!/usr/bin/env python3
"""Verify the output docker image is configured correctly.

This is run from the CI where the environment sets the image under test for
the current run using DOCKER_IMAGE and DOCKER_TAG.

Note: This file will not run from the CLI using 'pytest'.
"""
import subprocess
import sys
from os import environ

import pytest
import testinfra

DOCKER_IMAGE = environ.get("DOCKER_IMAGE") or "jameswilliams1/python-webdriver"
DOCKER_TAG = environ.get("DOCKER_TAG") or "3.7-slim-buster-all"
BROWSERS = [DOCKER_TAG.split("-")[-1]]  # chrome, firefox or all
if BROWSERS[0] == "all":  # special case where all is chosen -> test for each
    BROWSERS = ["chrome", "firefox"]


@pytest.fixture(scope="module")
def host():
    """Run the image under test in the background.

    Destroys the image after all tests have ran.

    Yields:
        host: running container as a testinfra host.
    """
    # TODO drop or statements after fully setting up CI
    image_name = f"{DOCKER_IMAGE}:{DOCKER_TAG}"
    docker_id = (
        subprocess.check_output(
            ["docker", "run", "--detach", "--tty", image_name, "/bin/sh"]
        )
        .decode()
        .strip()
    )
    # return a testinfra connection to the container
    host = testinfra.get_host("docker://" + docker_id)
    yield host
    # force remove container and all data after testing
    subprocess.check_call(["docker", "rm", "--force", "--volumes", docker_id])


@pytest.mark.parametrize("browser", BROWSERS)
def test_browsers_are_installed(host, browser):
    """Browsers should be installed to /opt."""
    install_dir = host.file(
        f"/opt/{browser if browser != 'chrome' else 'google/' + browser}"
    )
    assert install_dir.exists
    assert install_dir.is_directory


@pytest.mark.parametrize("browser", BROWSERS)
def test_webdrivers_are_installed(host, browser):
    """Webdrivers should be installed to /usr/local/bin."""
    webdriver = host.file(
        f"/usr/local/bin/{browser if browser != 'firefox' else 'gecko'}driver"
    )
    assert webdriver.exists
    assert webdriver.is_file
    assert oct(webdriver.mode) == "0o755"  # must be executable


@pytest.mark.parametrize("browser", BROWSERS)
def test_browsers_are_on_path(host, browser):
    """Browsers should be callable from the CLI."""
    assert host.exists(browser if browser != "chrome" else "google-chrome")


@pytest.mark.parametrize("browser", BROWSERS)
def test_webdrivers_are_on_path(host, browser):
    """Browsers should be callable from the CLI."""
    assert host.exists(f"{browser if browser != 'firefox' else 'gecko'}driver")


if __name__ == "__main__":
    # run these tests only when called directly with ./verify_image.py
    # allows passthrough of any flags from the CLI to pytest
    # NOTE using pytest.main gives warnings about not reloading files
    args = ["pytest", __file__] + sys.argv[1:]
    sys.exit(subprocess.call(args))
