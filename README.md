# [wip] Meteor Embark

### Streamlined Ethereum Integration for Meteor

#### ️*Only compatible with Meteor 1.2 +*

This package makes is insanely simple to start developing decentralized apps (dapps) in the meteor environment you're already used to.

Friendly reminder that ethereum is still in it's early days and can be shaky! Don't put your life savings into a ethereum contract -- at least not for a few years. Happy Dapp Developing!

## Quickstart

Make sure you have [all the dependencies of embark installed](https://github.com/iurimatias/embark-framework/wiki/Installation). You don't need to install embark itself as it is required automatically.

Set up your meteor project with the following files (this step will soon be automatic), as per embark demo boilerplate. This package assumes this configuration, so you don't need `embark.yml`.

```
.meteor
config/
  blockahin.yml
  contracts.yml
  genesis.json
  password
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

## TODO

```
- Auto-generate contracts/blockchain/genesis/password config (via embark boilerplate) if they don't exist

- Rewrite build plugin function to be more meteor-like; compile + deploy individual SOL files
  - This also enables more efficient caching a la metoer 1.2

- Test integration
- Configurable config file locations
- Configurable embark output (e.g. configurable `Contracts` namespace)
- Configurable output verbosity
```

## License

MIT 2015, Chris Hitchcott
