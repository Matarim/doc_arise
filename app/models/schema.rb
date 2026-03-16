# frozen_string_literal: true

class Schema < ApplicationRecord
  belongs_to :revision, class_name: 'ApiRevision'
end
