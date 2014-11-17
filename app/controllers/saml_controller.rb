require 'base64'
require 'ruby-saml'

class SamlController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:consume]
  skip_before_filter :check_if_login_required

  def index
    settings = Account.get_saml_settings
    request = OneLogin::RubySaml::Authrequest.new
    back_url = params[:back_url].to_s
    if back_url.present?
      cookies[:back_url] = back_url
    end
    redirect_to(request.create(settings))
  end

  def consume
    response = OneLogin::RubySaml::Response.new(Base64.decode64(
       params[:SAMLResponse]).force_encoding('utf-8').encode('windows-1252'))
    response.settings = Account.get_saml_settings

    name_id_tokens = response.name_id.downcase.split('-')
    name_id_map = {'68909' => 'ci', '68912' => 'psp', 'do' => 'do'}
    name_id = [name_id_tokens[0], name_id_map[name_id_tokens[1]],
       name_id_tokens[2]].join('-')
    if response.is_valid? && user = User.find_by_login(name_id)

      self.logged_user = user
      # generate a key and set cookie if autologin
      if params[:autologin] && Setting.autologin?
        token = Token.create(:user => user, :action => 'autologin')
        cookies[:autologin] = { :value => token.value, :expires => 1.year.from_now }
      end
      call_hook(:controller_account_success_authentication_after, {:user => user })

      back_url = cookies[:back_url].to_s
      if back_url.present?
        redirect_to back_url
      else
        redirect_back_or_default :controller => 'my', :action => 'page'
      end

    else
      invalid_credentials(user)
      error = l(:notice_account_invalid_creditentials)
    end
  end

  def complete
  end

  def fail
  end

end
