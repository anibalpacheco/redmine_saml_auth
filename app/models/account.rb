require 'ruby-saml'

class Account < ActiveRecord::Base
  def Account.get_saml_settings

    options = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'saml_auth.yml'))).result)
    settings = OneLogin::RubySaml::Settings.new

    settings.assertion_consumer_service_url = options[Rails.env]['assertion_consumer_service_url']
    settings.issuer                         = options[Rails.env]['issuer']
    settings.idp_sso_target_url             = options[Rails.env]['idp_sso_target_url']
    settings.idp_cert_fingerprint           = options[Rails.env]['idp_cert_fingerprint']
    settings.name_identifier_format         = options[Rails.env]['name_identifier_format']
    settings.private_key                    = options[Rails.env]['private_key']
    settings.private_key_pass               = options[Rails.env]['private_key_pass']
    settings.certificate                    = options[Rails.env]['certificate']

    settings
  end
end
