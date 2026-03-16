# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def google_oauth2
    handle_omniauth('google')
  end

  def entra_id
    handle_omniauth('entra_id')
  end

  def failure
    redirect_to sign_in_path, alert: "Authentication failed: #{params[:message]}"
  end

  private

  def handle_omniauth(provider)
    auth = request.env['omniauth.auth']
    identity = Identity.find_or_create_by!(provider: provider, uid: auth.uid) do |i|
      i.user = User.find_or_create_by!(email: auth.info.email) do |u|
        u.name = auth.info.name
        u.avatar_url = auth.info.image
      end
    end

    # Link or update user
    identity.update!(user: User.find_or_create_by!(email: auth.info.email)) if identity.user.nil?

    sign_in identity.user
    redirect_to root_path, notice: "Signed in successfully with #{provider.titleize}!"
  end
end
