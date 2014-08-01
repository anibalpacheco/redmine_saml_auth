RedmineApp::Application.routes.draw do
  match 'auth/saml', :to => 'saml#index', :as => 'saml_login'
  match 'auth/saml/consume', :to => 'saml#consume', :as => 'saml_consume'
end
