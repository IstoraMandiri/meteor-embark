# Meteor Embark

![Meteor Embark CLI Demo](http://i.imgur.com/4iscSMy.png)

### Streamlined Ethereum Integration for Meteor

#### ️*Only Compatible with Meteor 1.2 +*

This package makes is insanely simple to start developing decentralized apps (dapps) in the Meteor environment you're already used to.

Friendly reminder that ethereum is still in it's early days and things might not always work as expected! Don't put your life savings into a ethereum contract -- at least not for a few years. Happy Dapp Developing!

## Quickstart

Make sure you have [all the dependencies of embark installed](https://github.com/iurimatias/embark-framework/wiki/Installation).

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

Then include your `.sol` contracts along side your project files, anywhere in your project (the meteor way).

```
# project files in regular meteor fashion
client/
  myHtml.html
  mySuperPublicContract.sol
  mySuperPublicContractInterfact.coffee
server/
  myTrustedBackendContracts.sol
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

## What does it do

* Automatically starts a blockchain process in the background for development (with a random networkId) if there isn't one running already
* Uses `embark deploy` on all `.sol` files in your project, and re-deploys them if they need to be. This also creates javascript `web3` ABI files that can be used to interact with the contacts for both client and/or server depending on where you place the contracts in your project (in 'the meteor way'). Each contract becomes a global object (just like embark).
* Creates a connection using `web3` via RCP to the blockchain process in both clients and on the server when your meteor app starts (only if contracts exist on that platform).

You can then, for exmaple, simply call `SimpleStorage.get()` on either the client or the server.

## Configuration

Environment Variables:

* `EMBARK_ENV=environment` to specify environment - defaults to `development`
* `EMBARK_DEBUG=1` to enable debug output
* `EMBARK_VERBOSITY=6` to set output levels (see geth documentation, only works with `EMBARK_DEBUG` enabled)

## TODO

```
v1
- auto-generate contracts/blockchain/genesis/password config (via embark boilerplate) if they don't exist
- docs
- example project

> v1
- ipfs deploy option
- client only deploy option
- split contracts into seperate JS files on client (needed?)
- test framework integration
- configurable config file locations
```

## Thanks to

* [embark-framework](https://github.com/iurimatias/embark-framework)
* [etehereum](https://www.ethereum.org/)
* [meteor](https://github.com/meteor/meteor)


## License

MIT 2015, Chris Hitchcott