# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :require_authentication

  def index
    redirect_to new_organization_path and return if Current.user.organizations.empty?

    redirect_to new_workspace_path and return if Current.user.workspaces.empty?

    @workspaces = Current.user.workspaces
    @recent_projects = Project.where(workspace_id: @workspaces.pluck(:id)).order(updated_at: :desc).limit(6)
  end
end
