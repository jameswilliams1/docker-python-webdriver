<div align="center">
  <h1>python-webdriver</h1>
</div>

<div align="center"><img src="https://github.com/jameswilliams1/docker-python-webdriver/workflows/Code/badge.svg" alt="Code"> <img src="https://github.com/jameswilliams1/docker-python-webdriver/workflows/Build/badge.svg" alt="Build"> <a href="https://opensource.org/licenses/Apache-2.0">
  <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License: Apache 2.0">
</a> <a href="https://github.com/psf/black">
  <img src="https://img.shields.io/badge/code%20style-black-000000.svg" alt="Code style: black">
</a><p><br>
  <strong>Dockerised python with webdrivers for Chrome and Firefox.</strong></p><a href="https://github.com/jameswilliams1/docker-python-webdriver">https://github.com/jameswilliams1/docker-python-webdriver</a><br><br></div>

_Note_: This project is a work in progress and currently only the following tags are supported, providing Chrome and/or Firefox:

- 3.7-slim-buster-all
- 3.7-slim-buster-chrome
- 3.8-slim-buster-all
- 3.8-slim-buster-chrome

This is the Git repo of the Docker image for [python-webdriver](https://hub.docker.com/r/jameswilliams1/python-webdriver "python-webdriver on Docker Hub"). This image is a tool for scraping, testing or any other task that needs a [webdriver](https://www.w3.org/TR/webdriver/ "W3 Webdriver information") and a browser. Currently, there are images for [Google Chrome](https://www.google.co.uk/chrome/ "Google Chrome download page") with [Chromedriver](https://chromedriver.chromium.org/downloads "Chromedriver download page"), [Mozilla Firefox](https://www.mozilla.org/en-GB/firefox/new/ "Mozilla Firefox download page") with [Geckodriver](https://github.com/mozilla/geckodriver/releases "Geckodriver release page"), or both. Once the automated Dockerfile scripts are complete, the plan is to provide Chrome and Firefox along with most of the latest versions of python on Debian or Alpine.

Updates are pushed daily for all images by an automated CI pipeline which builds, tests and releases at 06:10am every morning.

# How to use this image

## Tags

Various versions of python, and either Chrome, Firefox or both can be chosen with the tag format:

```
<python-version>-<distribution>-<browser>
```

i.e. for Python 3.8 on Debian Slim Buster, with Chrome and Firefox installed:

```
docker pull jameswilliams1/python-webdriver:3.8-slim-buster-all
```

## Usage

This image runs as root by default. If you are using it in production your Dockerfile should change this. The image is primarily intended for use with the [Selenium WebDriver](https://selenium-python.readthedocs.io/getting-started.html "Selenium WebDriver Python information page") python bindings. Selenium is not installed by default as this should generally be handled through a requirements file for your project. The chosen browser and webdriver are installed, and the system is configured to allow headless execution in Docker out of the box. Setup is similar to any other python image:

```docker
FROM jameswilliams1/python-webdriver:3.8-slim-buster-all
COPY ./Pipfile ./Pipfile.lock /tmp/
WORKDIR /tmp/
RUN pip install --no-cache-dir pipenv \
    && pipenv install --deploy --system
    && rm -rf /tmp/*
COPY . /app
WORKDIR /app
ENTRYPOINT ["./entrypoint.sh"]
```

# Issues and Suggestions

Please report any issues or feature suggestions on [the issues page](https://github.com/jameswilliams1/docker-python-webdriver/issues "Github issues page").
