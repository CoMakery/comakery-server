module BlockchainJob
  class SyncJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      comakery_security_tokens
      pending_blockchain_transactions
    end

    private

      def comakery_security_tokens
        Token._token_type_comakery_security_token.each do |token|
          BlockchainJob::ComakerySecurityTokenJob::TokenSyncJob.perform_later(token)
        end
      end

      def pending_blockchain_transactions
        BlockchainTransaction.pending.each do |transaction|
          BlockchainJob::BlockchainTransactionSyncJob.perform_later(transaction)
        end
      end
  end
end
