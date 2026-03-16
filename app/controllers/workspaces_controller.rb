# frozen_string_literal: true

class WorkspacesController < ApplicationController
  before_action :require_authentication

  def new
    @workspace = Workspace.new
    @organizations = Current.user.organizations
  end

  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.organization = Current.user.organizations.first unless @workspace.organization_id.present?
    @workspace.created_by = Current.user

    if @workspace.save
      # Auto-create membership
      @workspace.workspace_memberships.create!(
        user: Current.user,
        role: 'admin'
      )

      redirect_to root_path, notice: 'Workspace created successfully!'
    else
      @organizations = Current.user.organizations
      render :new, status: :unprocessable_entity
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name, :slug, :description, :organization_id)
  end
end
