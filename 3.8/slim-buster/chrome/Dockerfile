FROM python:3.8-slim-buster

LABEL org.opencontainers.image.authors="James Williams <jamesleighwilliams@gmail.com>"
LABEL org.opencontainers.image.version="0.3.0"
LABEL org.opencontainers.image.licenses="Apache License 2.0"
LABEL org.opencontainers.image.url="https://github.com/jameswilliams1/docker-python-webdriver"
LABEL org.opencontainers.image.title="Python Webdriver"
LABEL org.opencontainers.image.description="Dockerised python with Chrome webdriver."

# Ensure any piped commands exit on error
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the latest versions of Google Chrome and Chromedriver
# Patches Chrome launch script to disable /dev/shm and sandbox for use in docker
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests --assume-yes \
    curl \
    unzip \
    gnupg \
    xvfb \
  && CHROME_DOWNLOAD_URL='https://dl.google.com/linux' \
  && curl -sL "${CHROME_DOWNLOAD_URL}/linux_signing_key.pub" | apt-key add - \
  && curl -sL "${CHROME_DOWNLOAD_URL}/direct/google-chrome-stable_current_amd64.deb" > /tmp/chrome.deb \
  # TODO find packages that cause fail before this and install first
  && (dpkg -i /tmp/chrome.deb || apt-get install --no-install-recommends --no-install-suggests --assume-yes --fix-broken) \
  && CHROMIUM_FLAGS='--no-sandbox --disable-dev-shm-usage' \
  && CHROMIUM_OPTIONS_FILE=/opt/google/chrome/google-chrome \
  && echo "$(cat ${CHROMIUM_OPTIONS_FILE}) ${CHROMIUM_FLAGS}" > "${CHROMIUM_OPTIONS_FILE}"  \
  && BASE_URL='https://chromedriver.storage.googleapis.com' \
  && VERSION=$(curl -sL "${BASE_URL}/LATEST_RELEASE") \
  && curl -sL "${BASE_URL}/${VERSION}/chromedriver_linux64.zip" -o /tmp/driver.zip \
  && unzip /tmp/driver.zip \
  && chmod 0755 chromedriver \
  && mv chromedriver /usr/local/bin/ \
  && apt-get purge -y \
    curl \
    unzip \
    gnupg \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /tmp/* /usr/share/doc/* /var/cache/* /var/lib/apt/lists/* /var/tmp/*

CMD ["chromedriver --version && echo -e '\n' && geckodriver --version"]
