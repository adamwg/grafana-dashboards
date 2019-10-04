#!/bin/sh

set -e

rm -rf /usr/share/doc
rm -rf /usr/share/man
rm -rf /usr/share/info
rm -rf /usr/share/i18n
rm -rf /usr/share/locale
rm -rf /lib/udev
rm -rf /lib/systemd
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*
rm -rf /var/cache/debconf/*old
