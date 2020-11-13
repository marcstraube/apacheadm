#!/usr/bin/env bash

if [ ${EUID} -ne 0 ]; then
  printf "Install script must be run as root!\n"
  exit 1
fi

DESTDIR=""
CONFDIR="/etc/httpd"

while getopts d:c: option; do
  case "${option}" in
    c) CONFDIR=${OPTARG};;
    d) DESTDIR=${OPTARG};;
  esac
done

install -d ${DESTDIR}${CONFDIR}/conf/mods-available/
install -d ${DESTDIR}${CONFDIR}/conf/mods-enabled/
install -d ${DESTDIR}${CONFDIR}/conf/sites-available/
install -d ${DESTDIR}${CONFDIR}/conf/sites-enabled/

install -Dm0755 src/apacheadm ${DESTDIR}/usr/bin/apacheadm
install -Dm0644 src/httpd.conf.example ${DESTDIR}${CONFDIR}/conf/httpd.conf.example
install -Dm0644 src/mods-available/*.{conf,load} ${DESTDIR}${CONFDIR}/conf/mods-available/
install -Dm0644 src/sites-available/*.conf ${DESTDIR}${CONFDIR}/conf/sites-available/

default_modules=( mpm_event log_config mime dir authz_core unixd headers )

for module in ${default_modules[@]}; do
  prefix="10-"

  if [ ${module} == "unixd" ]; then
    prefix="00-"
  fi

  ln -s ../mods-available/${module}.load ${DESTDIR}${CONFDIR}/conf/mods-enabled/${prefix}${module}.load

  if [ -e ${DESTDIR}${CONFDIR}/conf/mods-available/${module}.conf ]; then
    ln -s ../mods-available/${module}.conf ${DESTDIR}${CONFDIR}/conf/mods-enabled/${prefix}${module}.conf
  fi
done

ln -s ../sites-available/00-default.conf ${DESTDIR}${CONFDIR}/conf/sites-enabled/00-default.conf

