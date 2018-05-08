class Api::AccountsController < Api::ApiController
  def create
    render(json: { failed: true }) && return if params[:public_address].blank?
    @account = Account.find_or_initialize_by public_address: params[:public_address]
    @account.assign_attributes nonce: rand.to_s[2..6], email: "#{params[:public_address]}@comakery.com"
    if @account.save
      render json: { account: @account.as_json(only: %i[id public_address nonce]) }
    else
      render json: { failed: true }
    end
  end

  def find_by_public_address
    if (@account = Account.find_by public_address: params[:public_address]).present?
      render json: { account: @account.as_json(only: %i[id public_address nonce]) }
    else
      render json: {}
    end
  end

  def verify_signature
    eth_util = EthereumUtilSchmoozer.new(Rails.root)
    @account = Account.find_by public_address: params[:public_address]
    render(json: { success: false }) && return if params[:public_address].blank? || @account.nil?
    msg = "I am signing my one-time nonce: #{@account.nonce}"
    render json: {
      success: eth_util.verify_signature(params[:public_address], params[:signature], msg)
    }
  end
end
