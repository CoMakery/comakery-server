class Award < ApplicationRecord
  paginates_per 50

  include EthereumAddressable

  belongs_to :account, optional: true
  belongs_to :authentication, optional: true
  belongs_to :award_type
  belongs_to :issuer, class_name: 'Account'
  belongs_to :channel, optional: true
  has_one :team, through: :channel
  has_one :project, through: :award_type

  validates :proof_id, :award_type, :unit_amount, :total_amount, :quantity, presence: true
  validates :quantity, :total_amount, :unit_amount, numericality: { greater_than: 0 }

  validates :ethereum_transaction_address, ethereum_address: { type: :transaction, immutable: true } # see EthereumAddressable

  before_validation :ensure_proof_id_exists

  scope :confirmed, -> { where confirm_token: nil }

  def self.total_awarded
    sum(:total_amount)
  end

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44) # 58^44 > 2^256
  end

  def ethereum_issue_ready?
    project.ethereum_enabled &&
      account&.ethereum_wallet.present? &&
      ethereum_transaction_address.blank?
  end

  def self_issued?
    account_id == issuer_id
  end

  def recipient_auth_team
    account.authentication_teams.find_by team_id: channel.team_id if channel
  end

  def send_confirm_email
    UserMailer.send_award_notifications(self).deliver_now unless discord? || confirmed?
  end

  def confirm!(account)
    update confirm_token: nil, account: account
  end

  def confirmed?
    confirm_token.blank?
  end

  def discord?
    team && team.discord?
  end
  delegate :image, to: :team, prefix: true, allow_nil: true

  def total_amount=(x)
    self[:total_amount] = x.round
  end
end
