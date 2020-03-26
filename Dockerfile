FROM python:3.7-slim-buster

RUN addgroup --system selenium \
    && adduser --ingroup selenium selenium

# Install the latest version of Firefox
RUN ["/bin/bash", "-c", "set -o pipefail && DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y libgtk-3-0 libdbus-glib-1-2 bzip2 \
    && FIREFOX_DOWNLOAD_URL='https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64' \
    && curl -sL $FIREFOX_DOWNLOAD_URL | tar -xj -C /opt \
    && ln -s /opt/firefox/firefox /usr/local/bin/ \
    && apt-get purge -y bzip2 \
    && apt-get clean && rm -rf /tmp/* /usr/share/doc/* /var/cache/* /var/lib/apt/lists/* /var/tmp/*"]

# Install the latest version of Geckodriver
RUN ["/bin/bash", "-c", "set -o pipefail && BASE_URL=https://github.com/mozilla/geckodriver/releases/download \
    && VERSION=$(curl -sL https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep tag_name | cut -d '\"' -f 4) \
    && FILE_NAME=geckodriver-$VERSION-linux64.tar.gz \
    && curl -sL $BASE_URL/$VERSION/$FILE_NAME | tar -xz -C /usr/local/bin \
    && rm $FILE_NAME"]

# Install the latest versions of Google Chrome and Chromedriver
# Patches Chrome launch script and appends CHROMIUM_FLAGS to the last line for headless execution
RUN ["/bin/bash", "-c", "set -o pipefail && DEBIAN_FRONTEND=noninteractive && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y unzip gnupg \
  && CHROME_DOWNLOAD_URL=https://dl.google.com/linux \
  && curl -sL \"$CHROME_DOWNLOAD_URL/linux_signing_key.pub\" | apt-key add - \
  && curl -sL \"$CHROME_DOWNLOAD_URL/direct/google-chrome-stable_current_amd64.deb\" > /tmp/chrome.deb \
  && apt install --no-install-recommends --no-install-suggests -y /tmp/chrome.deb \
  && CHROMIUM_FLAGS='--no-sandbox --disable-dev-shm-usage' \
  && sed -i '${s/$/'\" $CHROMIUM_FLAGS\"'/}' /opt/google/chrome/google-chrome \
  && BASE_URL=https://chromedriver.storage.googleapis.com \
  && VERSION=$(curl -sL \"$BASE_URL/LATEST_RELEASE\") \
  && curl -sL \"$BASE_URL/$VERSION/chromedriver_linux64.zip\" -o /tmp/driver.zip \
  && unzip /tmp/driver.zip \
  && chmod 755 chromedriver \
  && mv chromedriver /usr/local/bin/ \
  && apt-get purge -y unzip gnupg \
  && apt-get clean && rm -rf /tmp/* /usr/share/doc/* /var/cache/* /var/lib/apt/lists/* /var/tmp/*"]

USER selenium

CMD ["chromedriver --version && echo -e '\n' && geckodriver --version"]
