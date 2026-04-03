# frozen_string_literal: true

class EndpointsController < ApplicationController
  before_action :require_authentication
  before_action :set_endpoint, only: [:update]

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

  def update
    if @endpoint.update(endpoint_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@endpoint, :details),
            partial: 'api_revisions/endpoint_details',
            locals:  { endpoint: @endpoint }
          )
        end
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def set_endpoint
    @endpoint = Endpoint.find(params[:id])
  end

  def endpoint_params
    params.require(:endpoint).permit(:version)
  end
end
