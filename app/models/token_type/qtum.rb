class TokenType::Qtum < TokenType
  # Generated template for implementing a new token type subclass
  # See: rails g token_type -h

  # Name of the token type for UI purposes
  # @return [String] name
  def name
    'QTUM'
  end

  # Symbol of the token type for UI purposes
  # @return [String] symbol
  def symbol
    'QTUM'
  end

  # Number of decimals
  # @return [Integer] number
  def decimals
    8
  end

  # Contract instance if implemented
  # @return [nil]
  def contract
    # Comakery::Eth::Contract::Erc20.new
  end

  # Transaction instance if implemented
  # @return [nil]
  def tx
    # Comakery::Eth::Tx.new
  end
end
