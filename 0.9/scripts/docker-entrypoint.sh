#!/bin/sh
# Deluged entrypoint
# Using ENV set at "docker run -e"
# or "docker create -e"
# info@sinaptika.net

set -e

export TZ="${TZ}"

rm -f "${D_DIR}"/config/deluged.pid

AUTH_UID="$(stat -c %u ${D_DIR}/config/auth)"

if [ "${D_UID}" != "${AUTH_UID}" ]
then
  apk add --no-cache shadow
  usermod -u "${D_UID}" "${D_USER}"
  groupmod -g "${D_GID}" "${D_GROUP}"
  apk del shadow
  chown -R "${D_UID}":"${D_GID}" "${D_DIR}"
  echo "${D_UID}":"${D_GID}" >> "${D_DIR}"/config/deluged-user-id
  echo "File permissions set"
fi

exec /sbin/su-exec \
  "${D_UID}":"${D_GID}" \
    /sbin/tini -- \
      deluged -d \
      -c "${D_DIR}"/config \
      -l "${D_DIR}"/config/deluged.log \
      -L "${D_D_LOG_LEVEL}"
echo "Starting Deluged"