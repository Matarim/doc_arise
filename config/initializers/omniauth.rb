# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  google_client_id     = ENV.fetch('GOOGLE_CLIENT_ID', Rails.application.credentials.dig(:google, :client_id))
  google_client_secret = ENV.fetch('GOOGLE_CLIENT_SECRET', Rails.application.credentials.dig(:google, :client_secret))

  if google_client_id.present? && google_client_secret.present?
    provider :google_oauth2,
             google_client_id,
             google_client_secret,
             scope: 'email,profile'
  end

  # Microsoft (Office 365 + Azure Entra ID + personal accounts)
  microsoft_client_id     = ENV.fetch('MICROSOFT_CLIENT_ID', Rails.application.credentials.dig(:microsoft, :client_id))
  microsoft_client_secret = ENV.fetch('MICROSOFT_CLIENT_SECRET',
                                      Rails.application.credentials.dig(:microsoft, :client_secret))

  if microsoft_client_id.present? && microsoft_client_secret.present?
    provider :entra_id,
             {
               client_id:     microsoft_client_id,
               client_secret: microsoft_client_secret,
               tenant:        'common',          # ← Supports Work/School (Office 365/Azure) + Personal Microsoft accounts
               scope:         'openid profile email',
               prompt:        'select_account'   # Shows account chooser
             }
  else
    Rails.logger.warn 'Microsoft OmniAuth provider disabled (missing credentials)'
  end
end
