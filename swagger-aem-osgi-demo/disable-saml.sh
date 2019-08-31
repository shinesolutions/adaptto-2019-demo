#!/usr/bin/env bash
usage() {
    echo "disable-saml.sh usage:"
    echo ""
    echo "./disable-saml.sh"
    echo "--help"
    echo ""
    echo "Required options:"
    echo "--aem_id=(author|publish)"
    echo ""
    echo ""
}

required_value() {
  if [ -z "${2}" ]; then
    echo "Error: Parameter ${1} requires a value"
    echo ""
    usage
    exit
  fi
}

option_count=0

while [[ $# -gt 0 ]]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | sed 's/^[^=]*=//g'`

  if [[ "${VALUE}" = "${PARAM}" ]] ; then
     shift
     VALUE=$1
  fi
 case $PARAM in
  --help)
         usage
         exit 0
  ;;
  --aem_id)
             required_value $PARAM $VALUE
             aem_id=${VALUE}
             option_count=$(expr ${option_count} + 1)
  ;;
  *)
    echo "Error - please try again."
    echo ""
    usage
    exit 2
  ;;
  esac
  shift
done

if [ "$option_count" -gt 1 ] || [ "$option_count" -lt 1 ] ; then
  echo "Error please define all options."
  echo ""
  usage
  exit 1
fi

# translate puppet exit code to follow convention
translate_exit_code() {

  exit_code="$1"
  if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 2 ]; then
    exit_code=0
  else
    exit "$exit_code"
  fi

  return "$exit_code"
}

PATH=/opt/puppetlabs/puppet/bin/:$PATH

set +o errexit

FACTER_tmp_dir=/tmp \
  FACTER_enable_saml=false \
  FACTER_aem_id="${aem_id}" \
  /opt/puppetlabs/bin/puppet apply \
  --detailed-exitcodes \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  "manifest/config_saml.pp"

translate_exit_code "$?"
