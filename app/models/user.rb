# frozen_string_literal: true

class User < ApplicationRecord
  include SoftDeletable

  has_secure_password
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  has_many :sessions, dependent: :destroy
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships

  has_many :workspace_memberships, dependent: :destroy
  has_many :workspaces, through: :workspace_memberships

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  has_many :created_organizations, class_name: 'Organization', foreign_key: :created_by_id, dependent: :nullify
  has_many :created_workspaces,    class_name: 'Workspace',    foreign_key: :created_by_id, dependent: :nullify
  has_many :created_teams,         class_name: 'Team',         foreign_key: :created_by_id, dependent: :nullify
  has_many :created_projects,      class_name: 'Project',      foreign_key: :created_by_id, dependent: :nullify

  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :nullify

  validates :accept_terms, acceptance: true

  def confirm!
    update!(email_verification_accepted_at: Time.current)
  end

  def confirmed?
    email_verification_accepted_at.present?
  end

  def send_confirmation_email
    update!(email_verification_accepted_at: Time.current)
    UserMailer.confirmation(self).deliver_later
  end

  def confirmation_token
    generate_token_for(:confirmation)
  end

  def resend_allowed?
    email_verification_sent_at.nil? || email_verification_sent_at < 1.hour.ago
  end

  def set_confirmation_sent_at
    self.email_verification_sent_at = Time.current
  end
end
