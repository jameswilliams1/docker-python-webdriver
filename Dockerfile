FROM python:3.7-slim-buster

LABEL maintainer="James Williams <jamesleighwilliams@gmail.com>"

RUN groupadd --system selenium \
    && useradd --gid selenium --shell /bin/bash --system selenium

# Ensure any piped commands exit on error
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the latest versions of Mozilla Firefox and Geckodriver
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests --assume-yes \
    curl \
    bzip2 \
    libgtk-3-0 \
    libdbus-glib-1-2 \
  && FIREFOX_DOWNLOAD_URL='https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64' \
  && curl -sL "$FIREFOX_DOWNLOAD_URL" | tar -xj -C /opt \
  && ln -s /opt/firefox/firefox /usr/local/bin/ \
  && BASE_URL='https://github.com/mozilla/geckodriver/releases/download' \
  && VERSION=$(curl -sL 'https://api.github.com/repos/mozilla/geckodriver/releases/latest' | grep tag_name | cut -d '"' -f 4) \
  && curl -sL "${BASE_URL}/${VERSION}/geckodriver-${VERSION}-linux64.tar.gz" | tar -xz -C /usr/local/bin \
  && apt-get purge -y \
    curl \
    bzip2 \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /tmp/* /usr/share/doc/* /var/cache/* /var/lib/apt/lists/* /var/tmp/*

# Install the latest versions of Google Chrome and Chromedriver
# Patches Chrome launch script and appends CHROMIUM_FLAGS to the last line for headless execution
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests --assume-yes \
    curl \
    unzip \
    gnupg \
  && CHROME_DOWNLOAD_URL='https://dl.google.com/linux' \
  && curl -sL "${CHROME_DOWNLOAD_URL}/linux_signing_key.pub" | apt-key add - \
  && curl -sL "${CHROME_DOWNLOAD_URL}/direct/google-chrome-stable_current_amd64.deb" > /tmp/chrome.deb \
  && (dpkg -i /tmp/chrome.deb || apt-get install --fix-broken) \
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

USER selenium

CMD ["chromedriver --version && echo -e '\n' && geckodriver --version"]
