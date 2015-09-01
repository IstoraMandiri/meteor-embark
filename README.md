# [wip] Meteor Embark

### Streamlined Ethereum Integration for Meteor

#### ️*Only compatible with Meteor 1.2 +*

Currently requires the use of a forked version of embark that is [pending PR](https://github.com/iurimatias/embark-framework/pull/73).

Friendly reminder that ethereum is still in it's early days and can be shaky! Don't put your life savings into a ethereum contract -- at least not for a few years.

Happy Dapp Developing.

```
meteor add hitchcott:embark
```

## What does it do?

1. Automatically starts a blockchain process if there isn't one running already
3. Use `embark deploy` on `.sol` files, which deploys them if they need to be (the 'embark way')
4. Adds `web3` and it's contracts to platforms as global objects

## Configuration

* Use environment variable `EMBARK_ENV=environment` to specify environment - defaults to `development`
* Use environment variable `EMBARK_DEBUG=1` to enable debug output

## TODO

```
- Rewrite build plugin function to be more meteor-like; compile + deploy individual SOL files
  - This also enables more efficient caching a la metoer 1.2

- Test integration
- Configurable config file locations
- Configurable embark output (e.g. configurable `Contracts` namespace)
- Configurable output verbosity
```

## License

MIT 2015, Chris Hitchcott
