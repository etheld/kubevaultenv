#!/bin/bash

initArch() {
    ARCH=$(uname -m)
    if [ -n "$DEP_ARCH" ]; then
        echo "Using DEP_ARCH"
        ARCH="$DEP_ARCH"
    fi
    case $ARCH in
        amd64) ARCH="amd64";;
        x86_64) ARCH="amd64";;
        i386) ARCH="386";;
        *) echo "Architecture ${ARCH} is not supported by this installation script"; exit 1;;
    esac
    echo "ARCH = $ARCH"
}

initOS() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    if [ -n "$DEP_OS" ]; then
        echo "Using DEP_OS"
        OS="$DEP_OS"
    fi
    case "$OS" in
        darwin) OS='darwin';;
        linux) OS='linux';;
        freebsd) OS='freebsd';;
        mingw*) OS='windows';;
        msys*) OS='windows';;
        *) echo "OS ${OS} is not supported by this installation script"; exit 1;;
    esac
    echo "OS = $OS"
}

downloadFile() {
    url="$1"
    destination="$2"

    echo "Fetching $url.."
    if test -x "$(command -v curl)"; then
        code=$(curl -s -w '%{http_code}' -L "$url" -o "$destination")
    elif test -x "$(command -v wget)"; then
        code=$(wget -q -O "$destination" --server-response "$url" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        echo "Neither curl nor wget was available to perform http requests."
        exit 1
    fi

    if [ "$code" != 200 ]; then
        echo "Request failed with code $code"
        exit 1
    fi
}

initVersion() {
     echo "Fetching $url"
    if test -x "$(command -v curl)"; then
        VERSION=$(curl --silent "https://api.github.com/repos/etheld/kubevaultenv/releases/latest" | grep -i tag_name | gsed -re's/.*\"tag_name\":\s*\"([0-9\.]+)\",.*/\1/g')

    elif test -x "$(command -v wget)"; then
        VERSION=$(wget -O- "https://api.github.com/repos/etheld/kubevaultenv/releases/latest" | grep -i tag_name | gsed -re's/.*\"tag_name\":\s*\"([0-9\.]+)\",.*/\1/g')
    else
        echo "Neither curl nor wget was available to perform http requests."
        exit 1
    fi
}

initArch
initOS
initVersion https://api.github.com/repos/etheld/kubevaultenv/releases/latest


downloadFile https://github.com/etheld/kubevaultenv/releases/download/${VERSION}/kubevaultenv-${OS}-${ARCH} /usr/local/bin/vaultenv
chmod +x /usr/local/bin/vaultenv