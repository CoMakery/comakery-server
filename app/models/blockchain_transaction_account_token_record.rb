class BlockchainTransactionAccountTokenRecord < BlockchainTransaction
  def update_transactable_status
    blockchain_transactable.update!(status: :synced)
  end

  def on_chain
    @on_chain ||= Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions.new(network, tx_hash)
  end

  private

    def tx
      @tx ||= contract.setAddressPermissions(
        blockchain_transactable.account.ethereum_wallet,
        blockchain_transactable.reg_group.blockchain_id,
        blockchain_transactable.lockup_until.to_i,
        blockchain_transactable.max_balance,
        blockchain_transactable.account_frozen
      )
    end
end