# frozen_string_literal: true

class ApiRevisionsController < ApplicationController
  before_action :set_api_revision, only: [:edit]
  before_action :set_api_specification

  def new
    @api_revision = @api_specification.api_revisions.build
    @mode = params[:mode] || 'manual'
  end

  def create
    @api_revision = @api_specification.api_revisions.build(revision_params)
    @api_revision.committed_by = Current.user

    @api_revision.is_published = false if params[:commit_draft].present?

    if @api_revision.save
      ParseOpenapiRevisionJob.perform_later(@api_revision.id)
      notice = if @api_revision.is_published?
                 "Revision ##{@api_revision.revision_number} created. Parsing started."
               else
                 'Draft saved successfully.'
               end

      redirect_to project_api_specification_path(@api_specification), notice: notice
    else
      @mode = params[:mode] || 'manual'
      render :new, status: :unprocessable_entity
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
      :commit_message, :is_published, :content, :yaml_content, :file,
      :http_method, :request_body_description, :parent_revision_id,
      request_body:            [:media_type],
      request_body_properties: %i[name type format required nullable default
                                  min_length max_length pattern minimum maximum description],
      responses:               [:status_code, :description,
                                {
                                  response_body: [:media_type],
                                  properties:    %i[name type format required nullable default
                                                    min_length max_length pattern minimum maximum description]
                                }],
      security_schemes:        %i[name type in_location param_name scheme bearer_format
                                  authorization_url token_url refresh_url scopes
                                  description example required]
    )
  end
end
