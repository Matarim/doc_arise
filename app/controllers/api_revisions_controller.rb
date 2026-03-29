# frozen_string_literal: true

class ApiRevisionsController < ApplicationController
  before_action :set_api_revision, only: %i[edit update documentation]
  before_action :set_api_specification

  def new
    @api_revision = @api_specification.api_revisions.build
    @mode = params[:mode] || 'manual'
  end

  def create
    @api_revision = @api_specification.api_revisions.build(revision_params)
    @api_revision.committed_by = Current.user
    @api_revision.is_published = params[:commit_draft] != 'true'
    @api_revision.revision_number = (@api_specification.api_revisions.maximum(:revision_number) || 0) + 1
    @project = @api_specification.project

    if @api_revision.save
      ParseOpenapiRevisionJob.perform_later(@api_revision.id)

      notice = if @api_revision.is_published?
                 "Revision ##{@api_revision.revision_number} (v#{@api_revision.version}) published."
               else
                 'Draft saved successfully.'
               end

      respond_to do |format|
        format.html do
          redirect_to project_api_specification_path(@project, @api_specification), notice: notice
        end
        format.turbo_stream do
          head :ok, location: project_api_specification_path(@project, @api_specification)
        end
      end
    else
      @mode = params[:mode] || 'manual'
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'spec-content',
            partial: 'api_specifications/edit_mode',
            locals: { revision: @api_revision, project: @project, api_specification: @api_specification }
          )
        end
        format.html { render :new }
      end
    end
  end

  def update
    @api_revision.assign_attributes(revision_params)
    @api_revision.committed_by = Current.user
    @api_revision.is_published = params[:commit_draft]
    @project = @api_specification.project

    if @api_revision.save
      ParseOpenapiRevisionJob.perform_later(@api_revision.id)

      notice = if @api_revision.is_published?
                 "Revision ##{@api_revision.revision_number} (v#{@api_revision.version}) published."
               else
                 'Draft updated successfully.'
               end

      respond_to do |format|
        format.html do
          redirect_to project_api_specification_path(@project, @api_specification), notice: notice
        end
        format.turbo_stream do
          head :ok, location: project_api_specification_path(@project, @api_specification)
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'spec-content',
            partial: 'api_specifications/edit_mode',
            locals: { revision: @api_revision, project: @project, api_specification: @api_specification }
          )
        end
      end
    end
  end

  def show
    @api_revision = ApiRevision.find(params[:id])
    respond_to do |format|
      format.json { render json: @api_revision.content }
      format.yaml do
        render plain: @api_revision.yaml_content.presence || @api_revision.content.to_yaml, content_type: 'text/yaml'
      end
      format.html { redirect_to project_api_specification_path(@api_revision.api_specification) }
    end
  end

  def edit
    @api_revision = ApiRevision.find(params[:id])
    @mode = params[:mode] || 'manual'
    render partial: 'api_specifications/edit_mode', locals: { revision: @api_revision, project: @project, api_specification: @api_specification }
  end

  def documentation
    @api_revision = ApiRevision.includes(endpoints: %i[parameters responses])
                               .find(params[:id])

    return unless params[:endpoint_id].present?

    @selected_endpoint = @api_revision.endpoints.find_by(id: params[:endpoint_id])

    render partial: 'documentation_content'
  end

  private

  def set_api_revision
    @api_revision = ApiRevision.find(params[:id])
  end

  def set_api_specification
    @api_specification = ApiSpecification.find(params[:api_specification_id])
  end

  def revision_params
    params.require(:api_revision).permit(
      :commit_message,
      :is_published,
      :content,
      :yaml_content,
      :file,
      :parent_revision_id,
      :version
    )
  end
end
