# frozen_string_literal: true

class ApiSpecificationsController < ApplicationController
  before_action :require_authentication
  before_action :set_project
  before_action :set_api_specification, only: [:show]
  before_action :set_selected_revision, only: [:show]

  def new
    @api_specification = ApiSpecification.new
  end

  def create
    @api_specification = @project.api_specifications.build(api_specification_params)
    @api_specification.created_by = Current.user

    if @api_specification.save
      redirect_to project_api_specification_path(@project, @api_specification),
                  notice: 'API Specification created!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_api_specification
    @api_specification = @project.api_specifications.find(params[:id])
  end

  def set_selected_revision
    @selected_revision = @api_specification.api_revisions.order(revision_number: :desc).first
  end

  def api_specification_params
    params.require(:api_specification).permit(:name, :description)
  end
end
