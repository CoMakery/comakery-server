require 'rails_helper'

describe TokenDecorator do
  let(:token) { (create :token).decorate }

  describe 'with ethereum contract' do
    let(:token) do
      build(:token,
        ethereum_contract_address: '0xa234567890b234567890a234567890b234567890').decorate
    end

    specify do
      expect(token.ethereum_contract_explorer_url)
        .to include("#{Rails.application.config.ethereum_explorer_site}/token/#{token.ethereum_contract_address}")
    end
  end

  describe 'with contract_address' do
    let(:token) do
      build(:token,
        coin_type: 'qrc20', blockchain_network: 'qtum_testnet',
        contract_address: 'a234567890b234567890a234567890b234567890').decorate
    end

    specify do
      expect(token.ethereum_contract_explorer_url)
        .to include(UtilitiesService.get_contract_url(token.blockchain_network, token.contract_address))
    end
  end

  describe '#currency_denomination' do
    specify do
      token.update denomination: 'USD'
      expect(token.currency_denomination).to eq('$')
    end

    specify do
      token.update denomination: 'BTC'
      expect(token.currency_denomination).to eq('฿')
    end

    specify do
      token.update denomination: 'ETH'
      expect(token.currency_denomination).to eq('Ξ')
    end
  end

  describe 'eth_data' do
    let!(:token) { create(:token, coin_type: :comakery) }

    it 'returns data for ethereum_controller.js' do
      data = token.decorate.eth_data

      expect(data['ethereum-payment-type']).to eq(token.coin_type)
      expect(data['ethereum-amount']).to eq(0)
      expect(data['ethereum-contract-address']).to eq(token.contract_address)
      expect(data['ethereum-contract-abi']).to eq(token.abi&.to_json)
    end
  end
end
