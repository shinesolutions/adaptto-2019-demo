#!/usr/bin/env bash
usage() {
    echo "enable-saml.sh usage:"
    echo ""
    echo "./enable-saml.sh"
    echo "--help"
    echo ""
    echo "SAML Certificate can be provided in several ways:"
    echo ""
    echo "You can define the Truststore Certalias directly:"
    echo "--idp_cert_alias=certalias_123456"
    echo ""
    echo "or"
    echo ""
    echo "you can define the certificates serial number:"
    echo "--serial=12:34:56"
    echo ""
    echo "or"
    echo ""
    echo "you can upload a SAML certificate to the AEM Truststore:"
    echo "--file=s3://aem-opencloud/saml.crt"
    echo ""
    echo ""
    echo "Required options:"
    echo "--idp_url=http:..."
    echo "--path=/:... (default: /)"
    echo "--service_provider_entity_id=..."
    echo "--aem_id=(author|publish)"
    echo ""
    echo ""
    echo "Optional options:"
    echo ""
    echo "--add_group_memberships=(true|false) (default: true)"
    echo ""
    echo "--assertion_consumer_service_url=String"
    echo ""
    echo "--clock_tolerance=Integer (default: 60)"
    echo ""
    echo "--create_user=(true|false) (default: true)- optional"
    echo ""
    echo "--default_groups=String"
    echo ""
    echo "--default_redirect_url=/path (default: /)"
    echo ""
    echo "--digest_method=http://... (default: http://www.w3.org/2001/04/xmlenc#sha256)"
    echo ""
    echo "--group_membership_attribute=(author|publish) (default: author)"
    echo ""
    echo "--handle_logout=(true|false) (default: false)"
    echo ""
    echo "--idp_http_redirect=(true|false) (default: false)"
    echo ""
    echo "--key_store_password=***"
    echo ""
    echo "--logout_url=http:..."
    echo ""
    echo "--name_id_format=urn:... (default: urn:oasis:names:tc:SAML:2.0:nameid-format:transient)"
    echo ""
    echo "--service_ranking=5002 (default: 5002)"
    echo ""
    echo "--signature_method=http://... (default: http://www.w3.org/2001/04/xmldsig-more#rsa-sha256)"
    echo ""
    echo "--sp_private_key_alias=..."
    echo ""
    echo "--synchronize_attributes=givenName=profile/givenName,familyName=profile/familyName"
    echo ""
    echo "--use_encryption=(true|false) (default: true)"
    echo ""
    echo "--user_id_attribute=userID (default: uid)"
    echo ""
    echo "--user_intermediate_path=..."
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
  --idp_url)
            required_value $PARAM $VALUE
            idp_url=$VALUE
            option_count=$(expr ${option_count} + 1)
  ;;
  --path)
            required_value $PARAM $VALUE
             path=$VALUE
             option_count=$(expr ${option_count} + 1)
  ;;
  --service_provider_entity_id)

            required_value $PARAM $VALUE
             service_provider_entity_id=$VALUE
             option_count=$(expr ${option_count} + 1)
  ;;
  --file)
             file=$VALUE
             option_count=$(expr ${option_count} + 1)
  ;;
  --idp_cert_alias)
             idp_cert_alias=$VALUE
             option_count=$(expr ${option_count} + 1)
  ;;
  --serial)
             serial=$VALUE
             option_count=$(expr ${option_count} + 1)
  ;;
  --aem_id)
             required_value $PARAM $VALUE
             aem_id=${VALUE}
             option_count=$(expr ${option_count} + 1)
  ;;
  --add_group_memberships)
             add_group_memberships=$VALUE
  ;;
  --assertion_consumer_service_url)
             assertion_consumer_service_url=$VALUE
  ;;
  --clock_tolerance)
             clock_tolerance=$VALUE
  ;;
  --create_user)
             create_user=$VALUE
  ;;
  --default_groups)
             default_groups=$VALUE
  ;;
  --default_redirect_url)
             default_redirect_url=$VALUE
  ;;
  --digest_method)
             digest_method=$VALUE
  ;;
  --group_membership_attribute)
             group_membership_attribute=$VALUE
  ;;
  --handle_logout)
             handle_logout=$VALUE
  ;;
  --idp_http_redirect)
             idp_http_redirect=$VALUE
  ;;
  --key_store_password)
             key_store_password=$VALUE
  ;;
  --logout_url)
             logout_url=$VALUE
  ;;
  --name_id_format)
             name_id_format=$VALUE
  ;;
  --service_ranking)
             service_ranking=$VALUE
  ;;
  --signature_method)
             signature_method=$VALUE
  ;;
  --sp_private_key_alias)
             sp_private_key_alias=$VALUE
  ;;
  --synchronize_attributes)
             synchronize_attributes=$VALUE
  ;;
  --use_encryption)
             use_encryption=$VALUE
  ;;
  --user_id_attribute)
             user_id_attribute=$VALUE
  ;;
  --user_intermediate_path)
             user_intermediate_path=$VALUE
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

if [ "$option_count" -lt 5 ]; then
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
FACTER_enable_saml=true \
  FACTER_add_group_memberships="${add_group_memberships}" \
  FACTER_aem_id="${aem_id}" \
  FACTER_assertion_consumer_service_url="${assertion_consumer_service_url}" \
  FACTER_clock_tolerance="${clock_tolerance}" \
  FACTER_create_user="${create_user}" \
  FACTER_default_groups="${default_groups}" \
  FACTER_default_redirect_url="${default_redirect_url}" \
  FACTER_digest_method="${digest_method}" \
  FACTER_file="${file}" \
  FACTER_group_membership_attribute="${group_membership_attribute}" \
  FACTER_handle_logout="${handle_logout}" \
  FACTER_idp_cert_alias="${idp_cert_alias}" \
  FACTER_idp_http_redirect="${idp_http_redirect}" \
  FACTER_idp_url="${idp_url}" \
  FACTER_key_store_password="${key_store_password}" \
  FACTER_logout_url="${logout_url}" \
  FACTER_name_id_format="${name_id_format}" \
  FACTER_path="${path}" \
  FACTER_service_provider_entity_id="${service_provider_entity_id}" \
  FACTER_service_ranking="${service_ranking}" \
  FACTER_serial="${serial}" \
  FACTER_signature_method="${signature_method}" \
  FACTER_sp_private_key_alias="${sp_private_key_alias}" \
  FACTER_synchronize_attributes="${synchronize_attributes}" \
  FACTER_use_encryption="${use_encryption}" \
  FACTER_user_id_attribute="${user_id_attribute}" \
  FACTER_user_intermediate_path="${user_intermediate_path}" \
  /opt/puppetlabs/bin/puppet apply \
  --detailed-exitcodes \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  "manifest/config_saml.pp"

translate_exit_code "$?"
