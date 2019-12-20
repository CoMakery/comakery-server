class TransferRuleDecorator < Draper::Decorator
  delegate_all

  def eth_data(controller = 'transfer-rule-form')
    {
      "#{controller}-rule-from-group-id" => sending_group.blockchain_id,
      "#{controller}-rule-to-group-id" => receiving_group.blockchain_id,
      "#{controller}-rule-lockup-until" => lockup_until.strftime('%b %e, %Y')
    }
  end
end