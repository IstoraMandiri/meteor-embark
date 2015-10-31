Meteor.startup ->
  console.log 'Hi there, developer!'
  console.log 'SimpleCounter contract', SimpleCounter

  # set default values, `get` is synchronous
  Session.set 'transaction', false
  Session.set 'count', SimpleCounter.get().toNumber()
  # listen to the increment event
  SimpleCounter.onIncrement (err, response) ->
    Session.set 'transaction', false
    Session.set 'count', response.args.count.toNumber()

  # start some logging of the eth status status
  # TODO use events not polling; too many HTTP requests?
  setInterval ->
    Session.set 'web3Info',
      "mining": web3.eth.mining
      "hashrate": web3.eth.hashrate
      "syncing": web3.eth.syncing
      "block #": web3.eth.blockNumber
      "coinbase": web3.eth.coinbase
      "eth": web3.fromWei(web3.eth.getBalance(web3.eth.coinbase).toNumber(), 'ether')
  , 1000

Template.hello.events
  'click button' : ->
    Session.set 'transaction', '?'
    SimpleCounter.increment (err, address) ->
      Session.set 'transaction', address

Template.hello.helpers
  'transaction' : -> Session.get 'transaction'
  'counter' : -> Session.get 'count'
  'contractAddress' : -> SimpleCounter.address
  'web3Info' : -> JSON.stringify Session.get('web3Info'), null, 2