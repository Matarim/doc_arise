# frozen_string_literal: true

class SecurityScheme < ApplicationRecord
  belongs_to :revision, class_name: 'ApiRevision'
end
