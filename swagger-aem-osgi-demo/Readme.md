AdaptTo() 2019 swagger-aem-osgi demo
---------------------

Instructions to reproduce the the swagger-aem-osgi demo

* Auto generate OpenAPI Spec for AEM OSGI Configuration nodes
* Enable SAML automated on AEM
* Disable SAML automated on AEM


## Pre-requisites
### Evironment
Run a Docker container inside of the repository directory:
```
docker run \
	--rm \
	--workdir /opt/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v `pwd`:/opt/workspace \
  -i -t shinesolutions/aem-platform-buildenv
```
### Dependencies
Resolve dependencies
```
make deps
```

## Generate OpenAPI Spec for AEM

For generating the OpenAPI Spec for the AEM OSGI Config nodes we are using the tool `openapi_spec_generator.rb` from the repository [Swagger AEM OSGI](https://github.com/shinesolutions/swagger-aem-osgi).

Usage:
```
author_verify_ssl=false \
  author_protocol=https \
	author_host=author.sandpit.aemopencloud.net \
	author_port=443 \
	author_username=admin \
	author_password=admin \
	ruby tools/openapi_spec_generator.rb \
	--in template/api.yml \
	--out conf/api.yml
```
## Enable SAML on AEM

To enable SAML automated on AEM we are using the puppet module  [Puppet AEM Resources](https://github.com/shinesolutions/puppet-aem-resources).

Enable SAML on AEM by uploading the SAML certificate from S3 to the AEM Truststore.

```
author_verify_ssl=false \
	author_protocol=https \
	author_host=author.sandpit.aemopencloud.net \
	author_port=443 \
	author_username=admin \
	author_password=admin \
	./enable-saml.sh \
	--file="s3://aem-opencloud/adobeaemcloud/certs/google_saml_cert.pem" \
	--aem_id=author \
	--path='/' \
	--service_provider_entity_id=AEMSSO \
	--idp_url="https://accounts.google.com/o/saml2/idp?idpid=123456" \
	--assertion_consumer_service_url="https://author.sandpit.aemopencloud.net:443/saml_login" \
	--create_user=true \
	--default_groups=content-authors \
	--group_membership_attribute=groupMembership \
	--handle_logout=true \
	--idp_http_redirect=false \
	--logout_url=https://accounts.google.com/logout \
	--name_id_format='urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' \
	--signature_method="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" \
	--synchronize_attributes='givenName=profile/givenName,familyName=profile/familyName,mail=profile/email' \
	--use_encryption=false \
	--user_id_attribute=NameID
```

Enable SAML on AEM using the serial number of the certificate which already exists in the AEM Truststore

```
author_verify_ssl=false \
	author_protocol=https \
  author_host=author.sandpit.aemopencloud.net \
  author_port=443 \
  author_username=admin \
  author_password=admin \
  ./enable-saml.sh \
  --serial=1499489110076 \
	--aem_id=author \
	--path='/' \
	--service_provider_entity_id=AEMSSO \
	--idp_url="https://accounts.google.com/o/saml2/idp?idpid=123456" \
	--assertion_consumer_service_url="https://author.sandpit.aemopencloud.net:443/saml_login" \
	--create_user=true \
	--default_groups=content-authors \
	--group_membership_attribute=groupMembership \
	--handle_logout=true \
	--idp_http_redirect=false \
	--logout_url=https://accounts.google.com/logout \
	--name_id_format='urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' \
	--signature_method="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" \
	--synchronize_attributes='givenName=profile/givenName,familyName=profile/familyName,mail=profile/email' \
	--use_encryption=false \
	--user_id_attribute=NameID
```

Enable SAML on AEM using the certificate alias name of the certificate in the AEM Truststore

```
author_verify_ssl=false \
	author_protocol=https \
  author_host=author.sandpit.aemopencloud.net \
  author_port=443 \
  author_username=admin \
  author_password=admin \
  ./enable-saml.sh \
  --idp_cert_alias=certalias_123456 \
	--aem_id=author \
	--path='/' \
	--service_provider_entity_id=AEMSSO \
	--idp_url="https://accounts.google.com/o/saml2/idp?idpid=123456" \
	--assertion_consumer_service_url="https://author.sandpit.aemopencloud.net:443/saml_login" \
	--create_user=true \
	--default_groups=content-authors \
	--group_membership_attribute=groupMembership \
	--handle_logout=true \
	--idp_http_redirect=false \
	--logout_url=https://accounts.google.com/logout \
	--name_id_format='urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' \
	--signature_method="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" \
	--synchronize_attributes='givenName=profile/givenName,familyName=profile/familyName,mail=profile/email' \
	--use_encryption=false \
	--user_id_attribute=NameID
```

## Disable SAML

To disable SAML automated on AEM we are using the puppet module  [Puppet AEM Resources](https://github.com/shinesolutions/puppet-aem-resources).

Usage:
```
author_verify_ssl=false \
	author_protocol=https \
	author_host=author.sandpit.aemopencloud.net \
	author_port=443 \
	author_username=admin \
	author_password=admin \
	./disable-saml.sh \
	--aem_id=author
```

## Sources
[How to use Google Gsuite as SAML Provider in AEM](https://pillpall.github.io/aem/2019/05/05/Google-Gsuite-as-SAML-provider-in-AEM.html)

[SAML app error messages](https://support.google.com/a/answer/6301076?hl=en)
