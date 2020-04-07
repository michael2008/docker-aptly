#! /usr/bin/env bash
set -e

# Automate the initial creation and update of a Debian package mirror in aptly

# The variables (as set below) will create a mirror of the Debian jessie repo 
# with the main and update components. If you do mirror these, you'll want to
# include "deb http://security.debian.org jessie/updates main" in your sources.list
# file or mirror it similarly as done below to keep up with security updates.

DEBIAN_RELEASE=stretch
UPSTREAM_URL="http://mirrors.aliyun.com/debian-security/"

aptly mirror create -architectures=amd64 -with-installer -with-udebs stretch-security-updates-main ${UPSTREAM_URL} stretch/updates main
aptly mirror create -architectures=amd64 -with-installer -with-udebs stretch-security-updates-contrib ${UPSTREAM_URL} stretch/updates contrib
aptly mirror create -architectures=amd64 -with-installer -with-udebs stretch-security-updates-non-free ${UPSTREAM_URL} stretch/updates non-free

REPOS=( stretch-security-updates-main stretch-security-updates-contrib stretch-security-updates-non-free )

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
    -component="main,contrib,non-free" -distribution=stretch ${SNAPSHOTARRAY[@]} debian-security

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  gpg --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Generate Aptly Graph
aptly graph -output /opt/aptly/public/aptly_graph.png
