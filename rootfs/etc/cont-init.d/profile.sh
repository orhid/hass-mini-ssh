#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Setup persistent user settings
# ==============================================================================
readonly DIRECTORIES=(addon_configs addons homeassistant media share ssl)

# Make Home Assistant TOKEN available on the CLI
mkdir -p /etc/profile.d
bashio::var.json \
    supervisor_token "${SUPERVISOR_TOKEN}" \
    | tempio \
        -template /usr/share/tempio/homeassistant.profile \
        -out /etc/profile.d/homeassistant.sh


# Persist shell profile by redirecting .bash_profile to /data
if ! bashio::fs.file_exists /data/.profile; then
    touch /data/.profile
fi
chmod 600 /data/.profile

# Links some common directories to the user's home folder for convenience
for dir in "${DIRECTORIES[@]}"; do
    ln -s "/${dir}" "${HOME}/${dir}" \
        || bashio::log.warning "Failed linking common directory: ${dir}"
done

source ~/.ashrc
