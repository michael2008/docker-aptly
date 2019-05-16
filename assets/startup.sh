#! /bin/bash


# If the repository GPG keypair doesn't exist, create it.
if [[ ! -f /opt/aptly/aptly.sec ]] || [[ ! -f /opt/aptly/aptly.pub ]]; then
  /opt/gpg_batch.sh
  # If your system doesn't have a lot of entropy this may, take a long time
  # Google how-to create "artificial" entropy if this gets stuck
  gpg1 --batch --gen-key /opt/gpg_batch
fi

# Export the GPG Public key
if [[ ! -f /opt/aptly/public/aptly_repo_signing.key ]]; then
  mkdir -p /opt/aptly/public
  gpg1 --export --armor > /opt/aptly/public/aptly_repo_signing.key
fi

# Import Ubuntu keyrings if they exist
if [[ -f /usr/share/keyrings/ubuntu-archive-keyring.gpg ]]; then
  gpg1 --list-keys
  gpg1 --no-default-keyring                                     \
      --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg  \
      --export |                                                \
  gpg1 --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                 \
      --import
fi

# Import Debian keyrings if they exist
if [[ -f /usr/share/keyrings/debian-archive-keyring.gpg ]]; then
  gpg1 --list-keys
  gpg1 --no-default-keyring                                     \
      --keyring /usr/share/keyrings/debian-archive-keyring.gpg  \
      --export |                                                \
  gpg1 --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                 \
      --import
fi

# Import EPICS GPG
if [[ -f /usr/share/keyrings/nsls2-archive-keyring.gpg ]]; then
  gpg1 --list-keys
  gpg1 --no-default-keyring                                     \
      --keyring /usr/share/keyrings/nsls2-archive-keyring.gpg   \
      --export |                                                \
  gpg1 --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                 \
      --import

  # The above might not be updated. Use also the repository repo-key.pub
  wget -O - \
      https://epicsdeb.bnl.gov/debian/repo-key.pub |            \
  gpg1 --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                 \
      --import
fi

# Aptly looks in /root/.gnupg for default keyrings
ln -sf /opt/aptly/aptly.sec /root/.gnupg/secring.gpg
ln -sf /opt/aptly/aptly.pub /root/.gnupg/pubring.gpg

# Generate Nginx Config
/opt/nginx.conf.sh

# Start Supervisor
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
