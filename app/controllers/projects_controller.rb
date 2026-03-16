# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :require_authentication

  def index
    @projects = Current.user.workspaces.flat_map(&:projects)
  end

  def new
    @project = Project.new
    @workspaces = Current.user.workspaces
  end

  def create
    @project = Project.new(project_params)
    @project.workspace ||= Current.user.workspaces.first
    @project.created_by = Current.user

    if @project.save
      redirect_to root_path, notice: 'Project created successfully!'
    else
      @workspaces = Current.user.workspaces
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def project_params
    params.require(:project).permit(:name, :slug, :description, :workspace_id)
  end
end
