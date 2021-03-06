require 'rails_helper'

describe AwardDecorator do
  let!(:team) { create :team }
  let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny' }
  let!(:recipient) { create :account, first_name: 'Betty', last_name: 'Ross' }
  let!(:authentication) { create :authentication, account: issuer }
  let!(:project) { create :project, account: issuer, token: create(:token, _token_type: 'eth', _blockchain: :ethereum_ropsten) }
  let!(:wallet_issuer) { create :wallet, account: issuer, address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453', _blockchain: project.token._blockchain }
  let!(:wallet_recipient) { create :wallet, account: recipient, address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423', _blockchain: project.token._blockchain }
  let!(:award_type) { create :award_type, project: project }
  let!(:award) { create :award, award_type: award_type, issuer: issuer }
  let!(:channel) { create :channel, project: project, team: team, channel_id: 'channel' }

  before do
    team.build_authentication_team authentication
  end

  subject { (create :award, award_type: award_type, issuer: issuer, account: recipient).decorate }
  specify { expect(subject.issuer_display_name).to eq('johnny johnny') }
  specify { expect(subject.issuer_user_name).to eq('johnny johnny') }
  specify { expect(subject.issuer_address).to eq('0xD8655aFe58B540D8372faaFe48441AeEc3bec453') }
  specify { expect(subject.recipient_display_name).to eq('Betty Ross') }
  specify { expect(subject.recipient_user_name).to eq('Betty Ross') }
  specify { expect(subject.recipient_address).to eq('0xD8655aFe58B540D8372faaFe48441AeEc3bec423') }
  specify { expect(subject.json_for_sending_awards).to be_a(String) }

  it 'returns ethereum_transaction_address_short' do
    award = create :award, ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    expect(award.decorate.ethereum_transaction_address_short).to eq '0xb808727d...'
  end

  it 'returns ethereum_transaction_explorer_url' do
    award = create :award, ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'returns ethereum_transaction_explorer_url for qtum' do
    award = create :award, ethereum_transaction_address: 'b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    award.project.token._blockchain = 'qtum_test'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'returns amount_pretty' do
    award = create :award, amount: 2.34
    expect(award.decorate.amount_pretty).to eq '2.34000000'
  end

  it 'returns total_amount_pretty' do
    award = create :award, quantity: 2.5
    expect(award.decorate.total_amount_pretty).to eq '125.00000000'

    award = create :award, quantity: 25
    expect(award.decorate.total_amount_pretty).to eq '1,250.00000000'

    award.token.update decimal_places: 2
    expect(award.decorate.total_amount_pretty).to eq '1,250.00'
  end

  it 'returns part_of_email' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.part_of_email).to eq 'test@...'
  end

  it 'returns communication_channel' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.communication_channel).to eq 'Email'

    award = create :award, award_type: award_type, quantity: 1, channel: channel
    expect(award.decorate.communication_channel).to eq channel.name_with_provider
  end

  describe 'total_amount_wei' do
    let!(:amount) { 2 }
    let!(:award_18_decimals) { create(:award, status: :ready, amount: amount) }
    let!(:award_2_decimals) { create(:award, status: :ready, amount: amount) }
    let!(:award_0_decimals) { create(:award, status: :ready, amount: amount) }
    let!(:award_no_token) { create(:award, status: :ready, amount: amount) }

    before do
      award_18_decimals.project.token.update(decimal_places: 18)
      award_2_decimals.project.token.update(decimal_places: 2)
      award_0_decimals.project.token.update(decimal_places: 0)
      award_no_token.project.update(token: nil)
    end

    it 'returns total_amount in Wei based on token decimals' do
      expect(award_18_decimals.decorate.total_amount_wei).to eq(2000000000000000000)
      expect(award_2_decimals.decorate.total_amount_wei).to eq(200)
      expect(award_0_decimals.decorate.total_amount_wei).to eq(2)
      expect(award_no_token.decorate.total_amount_wei).to eq(2)
    end
  end

  describe 'transfer_button_text' do
    let!(:project) { create(:project, token: create(:token, contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', _token_type: :comakery_security_token, _blockchain: :ethereum_ropsten)) }
    let!(:eth_award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }
    let!(:mint_award) { create(:award, status: :accepted, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project)) }
    let!(:burn_award) { create(:award, status: :accepted, transfer_type: project.transfer_types.find_by(name: 'burn'), award_type: create(:award_type, project: project)) }

    it 'returns text based on transfer type' do
      expect(eth_award.decorate.transfer_button_text).to eq('Pay')
      expect(mint_award.decorate.transfer_button_text).to eq('Mint')
      expect(burn_award.decorate.transfer_button_text).to eq('Burn')
    end
  end

  describe 'pay_data' do
    let!(:project) { create(:project, token: create(:token, contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', _token_type: :comakery_security_token, _blockchain: :ethereum_ropsten)) }
    let!(:eth_award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }
    let!(:mint_award) { create(:award, status: :accepted, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project)) }
    let!(:burn_award) { create(:award, status: :accepted, transfer_type: project.transfer_types.find_by(name: 'burn'), award_type: create(:award_type, project: project)) }
    let!(:other_award) { create(:award) }

    it 'returns payment data for ethereum_controller.js' do
      data = eth_award.decorate.pay_data
      expect(data['controller']).to eq('ethereum')
      expect(data['target']).to eq('ethereum.button')
      expect(data['action']).to eq('click->ethereum#pay')
      expect(data['ethereum-id']).to eq(eth_award.id)
      expect(data['ethereum-payment-type']).to eq(eth_award.token._token_type)
      expect(data['ethereum-address']).to eq(eth_award.recipient_address)
      expect(data['ethereum-amount']).to eq(eth_award.decorate.total_amount_wei)
      expect(data['ethereum-decimal-places']).to eq(eth_award.project.token&.decimal_places&.to_i)
      expect(data['ethereum-contract-address']).to eq(eth_award.project.token&.contract_address)
      expect(data['ethereum-contract-abi']).to eq(eth_award.project.token&.abi&.to_json)
      expect(data['ethereum-transactions-path']).to include(eth_award.project.id.to_s)
      expect(data['info']).not_to be_nil
    end

    it 'returns mint data for ethereum_controller.js' do
      data = mint_award.decorate.pay_data
      expect(data['controller']).to eq('ethereum')
      expect(data['target']).to eq('ethereum.button')
      expect(data['action']).to eq('click->ethereum#mint')
      expect(data['ethereum-id']).to eq(mint_award.id)
      expect(data['ethereum-payment-type']).to eq(mint_award.token._token_type)
      expect(data['ethereum-address']).to eq(mint_award.recipient_address)
      expect(data['ethereum-amount']).to eq(mint_award.decorate.total_amount_wei)
      expect(data['ethereum-decimal-places']).to eq(mint_award.project.token&.decimal_places&.to_i)
      expect(data['ethereum-contract-address']).to eq(mint_award.project.token&.contract_address)
      expect(data['ethereum-contract-abi']).to eq(mint_award.project.token&.abi&.to_json)
      expect(data['ethereum-transactions-path']).to include(mint_award.project.id.to_s)
      expect(data['info']).not_to be_nil
    end

    it 'returns burn data for ethereum_controller.js' do
      data = burn_award.decorate.pay_data
      expect(data['controller']).to eq('ethereum')
      expect(data['target']).to eq('ethereum.button')
      expect(data['action']).to eq('click->ethereum#burn')
      expect(data['ethereum-id']).to eq(burn_award.id)
      expect(data['ethereum-payment-type']).to eq(burn_award.token._token_type)
      expect(data['ethereum-address']).to eq(burn_award.recipient_address)
      expect(data['ethereum-amount']).to eq(burn_award.decorate.total_amount_wei)
      expect(data['ethereum-decimal-places']).to eq(burn_award.project.token&.decimal_places&.to_i)
      expect(data['ethereum-contract-address']).to eq(burn_award.project.token&.contract_address)
      expect(data['ethereum-contract-abi']).to eq(burn_award.project.token&.abi&.to_json)
      expect(data['ethereum-transactions-path']).to include(burn_award.project.id.to_s)
      expect(data['info']).not_to be_nil
    end

    it 'returns data for legacy payment logic' do
      data = other_award.decorate.pay_data
      expect(data[:id]).not_to be_nil
      expect(data[:info]).not_to be_nil
    end
  end

  describe 'transfer_button_state_class' do
    let!(:award_created_not_expired) { create(:blockchain_transaction, status: :created, created_at: 1.year.from_now).blockchain_transactable }
    let!(:award_pending) { create(:blockchain_transaction, status: :pending).blockchain_transactable }
    let!(:award_created_expired) { create(:blockchain_transaction, status: :created, created_at: 1.year.ago).blockchain_transactable }
    let!(:award) { create(:award) }

    it 'returns css class for award with created blockchain_transaction' do
      expect(award_created_not_expired.decorate.transfer_button_state_class).to eq('in-progress--metamask')
    end

    it 'returns css class for award with pending blockchain_transaction' do
      expect(award_pending.decorate.transfer_button_state_class).to eq('in-progress--metamask in-progress--metamask__paid')
    end

    it 'returns nil for award with created and expired blockchain_transaction' do
      expect(award_created_expired.decorate.transfer_button_state_class).to be_nil
    end

    it 'returns nil for award without blockchain_transaction' do
      expect(award.decorate.transfer_button_state_class).to be_nil
    end
  end
end
