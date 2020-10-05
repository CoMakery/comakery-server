class Blockchain::Algorand < Blockchain
  # Generated template for implementing a new blockchain subclass
  # See: rails g blockchain -h

  # Name of the blockchain for UI purposes
  # @return [String] name
  def name
    'Algorand'
  end

  # Hostname of block explorer API
  # @return [String] hostname
  def explorer_api_host
    'api.algoexplorer.io'
  end

  # Hostname of block explorer website
  # @return [String] hostname
  def explorer_human_host
    'algoexplorer.io'
  end

  # Is mainnet?
  # @return [Boolean] mainnet?
  def mainnet?
    true
  end

  # Number of confirmations to wait before marking transaction as successful
  # @return [Integer] number
  def number_of_confirmations
    1
  end

  # Seconds to wait between syncs with block explorer API
  # @return [Integer] seconds
  def sync_period
    60
  end

  # Maximum number of syncs with block explorer API
  # @return [Integer] number
  def sync_max
    10
  end

  # Seconds to wait when transaction is created
  # @return [Integer] seconds
  def sync_waiting
    600
  end

  # Transaction url on block explorer website
  # @return [String] url
  def url_for_tx_human(hash)
    "https://#{explorer_human_host}/tx/#{hash}"
  end

  # Transaction url on block explorer API
  # @return [String] url
  def url_for_tx_api(_hash)
    nil
  end

  # Address url on block explorer websitea
  # @return [String] url
  def url_for_address_human(addr)
    "https://#{explorer_human_host}/address/#{addr}"
  end

  # Address url on block explorer API
  # @return [String] url
  def url_for_address_api(addr)
    "https://#{explorer_api_host}/v2/accounts/#{addr}"
  end

  # Validate blockchain transaction hash
  # @raise [Blockchain::Tx::ValidationError]
  # @return [void]
  def validate_tx_hash(_hash)
    raise Blockchain::Address::ValidationError, 'should consist of 52 alphanumeric characters' unless /\A[0-9A-Za-z]{52}\z/.match?(addr)
  end

  # Validate blockchain address
  # @raise [Blockchain::Address::ValidationError]
  # @return [void]
  def validate_addr(addr)
    raise Blockchain::Address::ValidationError, 'should consist of 58 alphanumeric characters' unless /\A[0-9A-Za-z]{58}\z/.match?(addr)
  end
end