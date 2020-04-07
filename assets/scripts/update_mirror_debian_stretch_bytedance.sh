#! /usr/bin/env bash
set -e

# Automate the initial creation and update of a Debian package mirror in aptly

# The variables (as set below) will create a mirror of the Debian jessie repo 
# with the main and update components. If you do mirror these, you'll want to
# include "deb http://security.debian.org jessie/updates main" in your sources.list
# file or mirror it similarly as done below to keep up with security updates.

DEBIAN_RELEASE=stretch
UPSTREAM_URL="http://mirrors.bytedance.com/debian/"

aptly mirror create -architectures=amd64 stretch-bytedance-main ${UPSTREAM_URL} stretch stretch-main

REPOS=( stretch-bytedance-main )

for repo in ${REPOS[@]}; do
    aptly mirror update ${repo}
done

unset SNAPSHOTARRAY

for repo in ${REPOS[@]}; do
    echo "Creating snapshot of ${repo} repository mirror.."
    SNAPSHOTARRAY+="${repo}-`date +%Y%m%d%H` "
    aptly snapshot create ${repo}-`date +%Y%m%d%H` from mirror ${repo}
done

# Publish the latest merged snapshot
aptly publish snapshot -passphrase="${GPG_PASSWORD}" \
    -component="stretch-main" -distribution=${DEBIAN_RELEASE} ${SNAPSHOTARRAY[@]} debian-bytedance

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  gpg --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Generate Aptly Graph
aptly graph -output /opt/aptly/public/aptly_graph.png