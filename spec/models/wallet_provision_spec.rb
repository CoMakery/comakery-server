require 'rails_helper'
require 'models/concerns/synchronisable_spec'

RSpec.describe WalletProvision, type: :model do
  it_behaves_like 'synchronisable'
  before { allow_any_instance_of(described_class).to receive(:sync_allowed?).and_return(true) }

  subject { create(:wallet_provision, wallet_address: build(:algorand_address_1)) }

  it { is_expected.to belong_to(:wallet) }
  it { is_expected.to belong_to(:token) }
  it {
    is_expected.to define_enum_for(:state).with_values({
      pending: 0,
      initial_balance_confirmed: 1,
      opt_in_created: 2,
      provisioned: 3
    })
  }

  describe '#sync_balance' do
    before do
      allow(subject).to receive(:wallet).and_return(Wallet.new)
      allow_any_instance_of(Wallet).to receive(:coin_balance).and_return(Balance.new)
      allow_any_instance_of(Balance).to receive(:value).and_return(coin_balance_value)
    end

    context 'when coin balance is positive' do
      let(:coin_balance_value) { 1 }

      specify do
        subject.sync_balance

        expect(subject.state).to eq 'initial_balance_confirmed'
      end
    end

    context 'when coin balance is not positive' do
      let(:coin_balance_value) { 0 }

      specify do
        expect { subject.sync_balance }.to raise_error(WalletProvision::ProvisioningError)
      end
    end
  end

  describe '#create_opt_in_tx', vcr: true do
    context 'when opt_in tx has been created' do
      it 'calls service to sign the transaction' do
        expect_any_instance_of(OreIdService).to receive(:create_tx)
        expect(subejct).to receive(:opt_in_created!)
        subject.create_opt_in_tx

        expect(TokenOptIn.last.wallet).to eq(subject.wallet)
        expect(BlockchainTransactionOptIn.last.blockchain_transactable.wallet).to eq(subject.wallet)
      end
    end
  end
end
