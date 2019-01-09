window.alertMsg = (modal, msg) ->
  modal.find('.alert-msg').text(msg)
  modal.foundation('open')

window.transferAwardOnQtum = (award) -> # award in JSON
  transferQrc20Tokens award

transferAwardOnCardano = (award) -> # award in JSON
  transferAdaCoins award

transferAwardOnBitcoin = (award) -> # award in JSON
  console.log award

window.transferAward = (award) -> # award in JSON
  if award.project.coin_type == 'erc20' || award.project.coin_type == 'eth'
    transferAwardOnEthereum award
  else if award.project.coin_type == 'qrc20'
    transferAwardOnQtum award
  else if award.project.coin_type == 'ada'
    transferAwardOnCardano award
  else if award.project.coin_type == 'btc'
    transferAwardOnBitcoin award

$ ->
  $(document).on 'click', '.transfer-tokens-btn', ->
    award = JSON.parse $(this).attr('data-info')
    transferAward award
