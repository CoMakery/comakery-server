module BlockchainTransactable
  extend ActiveSupport::Concern

  included do
    has_many :blockchain_transactions, as: :blockchain_transactable, dependent: :destroy
    # rubocop:todo Rails/InverseOf
    has_one :latest_blockchain_transaction, -> { order created_at: :desc }, class_name: 'BlockchainTransaction', as: :blockchain_transactable, foreign_key: :blockchain_transactable_id
    # rubocop:enable Rails/InverseOf

    # Return transactables matching at least one of the following conditions:
    # – Doesn't have any blockchain transactions yet
    # – Latest blockchain transaction state is "cancelled"
    # – (Optionally) Latest blockchain transaction state is "failed"
    # – Latest blockchain transaction state is "created" and transaction is created more than 10 minutes ago
    # – Doesn't have a  (AccountTokenRecord and TransferRule)
    # – Is in accepted state (Award)
    #
    # Model specific conditions:
    # - Award must be in `accepted` state
    # - AccountTokenRecord, TransferRule must be not in `synced` status
    scope :ready_for_blockchain_transaction, lambda { |include_failed = false|
      q = joins(sanitize_sql_array([
                                     ''"
        LEFT JOIN blockchain_transactions
        ON blockchain_transactions.blockchain_transactable_id = #{table_name}.id
        AND blockchain_transactions.blockchain_transactable_type = '#{table_name.camelize.singularize}'
        AND blockchain_transactions.id = (
          SELECT MAX(id) FROM blockchain_transactions
          WHERE blockchain_transactions.blockchain_transactable_id = #{table_name}.id
          AND blockchain_transactions.blockchain_transactable_type = '#{table_name.camelize.singularize}'
        )
        "''
                                   ]))
          .distinct
          .where(
            ''"
            (blockchain_transactions.id IS NULL)
            OR (blockchain_transactions.status IN (2 #{include_failed ? ', 4' : nil}))
            OR (blockchain_transactions.status = 0 AND blockchain_transactions.created_at < :timestamp)
            "'',
            timestamp: 10.minutes.ago
          )

      if table_name == 'awards'
        q.accepted
      elsif table_name.in? %w[account_token_records transfer_rules]
        q.not_synced
      else
        q
      end
    }

    scope :ready_for_manual_blockchain_transaction, lambda {
      ready_for_blockchain_transaction(true)
    }

    def blockchain_transaction_class
      "BlockchainTransaction#{self.class}".constantize
    end

    def new_blockchain_transaction(params)
      blockchain_transaction_class.new(
        params.merge(
          blockchain_transactable: self
        )
      )
    end
  end
end
