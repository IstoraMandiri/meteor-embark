# Meteor Embark

⚠️ This package is currently in beta - please report any bugs or issues. Thanks.

![Meteor Embark CLI Demo](http://i.imgur.com/4iscSMy.png)

### Streamlined Ethereum Integration for Meteor

This package makes it insanely simple to start developing decentralized apps (dapps) in the Meteor environment you are already used to.

* Automatically starts an Ethereum blockchain `geth` process in the background
* Or it will try to conntect to an existing process if one exists
* Optionally use the a simulation mode (ethersim) for more rapid development
* Automatically mine contracts and transactions on a zero-config private testnet
* Compile Solidity `.sol` and Serpent `.se` files on the fly in the Meteor way

## Install & Start (for OSX)

```bash
# install meteor
curl https://install.meteor.com/ | sh
# install ethereum
brew tap ethereum/ethereum
brew install ethereum
# clone repo
git clone https://github.com/hitchcott/meteor-embark
# go to example app
cd meteor-embark/example
# start meteor
EMBARK_DEBUG=1 meteor
```
Once Meteor starts it will take a few seconds to start a blockchain and mine the demo contract.

Then go to http://localhost:3000 and play with the example app!

## Full Setup Instructions

Before you begin, make sure you have a basic understanding of ethereum and geth.

And just a friendly reminder that ethereum is still in it's early days and you are on the front line. Don't put your life savings into an ethereum smart contract -- at least not for a few years!

Make sure you have [all the dependencies of embark installed](https://github.com/iurimatias/embark-framework/wiki/Installation). Meteor Embark currently uses Embark 1.0.2.

Set up your meteor project with the following config files, as per [embark demo boilerplate](https://github.com/iurimatias/embark-framework/tree/develop/demo_meteor/config) (the embark way). This package assumes this configuration, so you don't need `embark.yml`.

*This step will soon be automatic*

```
# config files
config/
  blockahin.yml
  contracts.yml
  genesis.json
  password
```

Then include your Solidity `.sol` or Serpent `.se` contracts along side your project files, anywhere in your project (the meteor way).

```
# project files in regular meteor fashion
client/
  myHtml.html
  mySuperPublicContract.sol
  mySuperPublicContractInterfact.coffee
server/
  mySerpentContract.se
  mySolidityContract.sol
  myMethods.coffee
both/
  simpleChat.html
  simpleChat.css
  simpleChat.coffee
  simpleChat.sol
```

Then install the meteor package

```
meteor add hitchcott:embark
```

And that's it! You should be able to start your meteor project, and contracts will be automatically compiled on the relevant platform (client and/or server) and deployed to a blockchain.

Happy Dapp Developing!

## What does it do?

* Automatically starts a blockchain process in the background for development (with a random networkId) or uses an external chain if there's one running already
* Uses `embark deploy` on all `.sol` and `.se` files in your project, and re-deploys them if they need to be. This also creates javascript `web3` ABI files that can be used to interact with the contacts for both client and/or server depending on where you place the contracts in your project (in 'the meteor way'). Each contract becomes a global object (just like embark).
* Creates a connection using `web3` via RPC to the blockchain process in both clients and on the server when your meteor app starts (only if contracts exist on that platform).

You can then, for exmaple, simply call `SimpleStorage.get()` on either the client or the server.

Check out the demo app for more usage examples!

For more information about embark configuration, check the [embark-framework repo](https://github.com/iurimatias/embark-framework).

## Configuration

Environment Variables:

* `EMBARK_DEBUG=1` to enable debug output
* `EMBARK_VERBOSITY=6` to set output levels (see geth documentation, only works with `EMBARK_DEBUG` enabled)
* `EMBARK_ENV=environment` to specify environment - defaults to `development`

## TODO

```
v1
- implement the simulator (embark 1.0+)
- auto-generate config (via embark boilerplate) if it doesn't exist
- automatically maintain `contracts.yml`
- example project
- better docs

> v1
- mist support
- ipfs deploy option
- client only deploy option
- ensure all embark options are supported
- split contracts into seperate JS files on client (needed?)
- test framework integration
- configurable config file locations
- tests
```

## Thanks to

* [embark-framework](https://github.com/iurimatias/embark-framework)
* [ethereum](https://www.ethereum.org/)
* [meteor](https://github.com/meteor/meteor)


## License

MIT 2015, Chris Hitchcott
