# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    if (user = User.authenticate_by(email_address: params[:email_address], password: params[:password]))
      start_new_session_for user
      redirect_to root_path, notice: 'Signed in successfully!'
    else
      @user = User.new(email_address: params[:email_address])
      flash.now[:alert] = 'Invalid email or password'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to sign_in_path, notice: 'Signed out successfully'
  end
end
