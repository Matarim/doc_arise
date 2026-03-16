# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :revision, class_name: 'ApiRevision'

  has_many :parameters, dependent: :destroy
  has_many :responses, dependent: :destroy
end
