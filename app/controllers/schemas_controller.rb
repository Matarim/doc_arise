# frozen_string_literal: true

class SchemasController < ApplicationController
  before_action :require_authentication

  def index
    @api_revision = ApiRevision.find(params[:api_revision_id])
    @schemas = @api_revision.schemas.order(:name)

    return unless params[:q].present?

    @schemas = @schemas.where('name ILIKE ?', "%#{params[:q]}%")
  end

  def show
    @schema = Schema.find(params[:id])
    @revision = @schema.revision
  end
end
