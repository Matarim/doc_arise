# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :api_revision

  has_many :parameters, dependent: :destroy
  has_many :responses, dependent: :destroy

  validates :version, presence: true
end
