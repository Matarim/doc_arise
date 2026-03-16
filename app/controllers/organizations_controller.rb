# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :require_authentication

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.created_by = Current.user

    if @organization.save
      @organization.organization_memberships.create!(
        user: Current.user,
        role: 'owner'
      )

      redirect_to new_workspace_path, notice: 'Organization created! Now create your first workspace.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :description)
  end
end
