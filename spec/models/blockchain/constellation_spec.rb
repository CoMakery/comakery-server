require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::Constellation do
  it_behaves_like 'a blockchain'
end
