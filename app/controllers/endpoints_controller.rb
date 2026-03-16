# frozen_string_literal: true

class EndpointsController < ApplicationController
  before_action :require_authentication

  def index
    @api_revision = ApiRevision.find(params[:api_revision_id])
    @endpoints = @api_revision.endpoints

    # Search & filter
    if params[:q].present?
      @endpoints = @endpoints.where('path ILIKE ? OR operation_id ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @endpoints = @endpoints.where(method: params[:method].downcase) if params[:method].present?

    @endpoints = @endpoints.order(:path)
  end

  def show
    @endpoint = Endpoint.find(params[:id])
    @revision = @endpoint.revision
  end
end
