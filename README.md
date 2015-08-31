# [wip] Meteor Embark

### Streamlined Ethereum Integration for Meteor

#### ️*Only compatible with Meteor 1.2 +*

```
meteor add hitchcott:embark
```

## What does it do?

1. Automatically starts a blockchain process if there isn't one running already (using `embark blockchain`)
3. Use `embark deploy` on `.sol` files, which deploys them if they need to be (the 'embark way')
4. Adds `web3` and it's contracts to platforms as global objects

## Configuration

* Use environment variable `EMBARK_ENV` to specify environment - defaults to `development`

## TODO

```
- Rewrite build plugin function to be more meteor-like; compile + deploy individual SOL files
  - This also enables more efficient caching a la metoer 1.2

- Test integration
- Configurable config file locations
- Configurable embark output (e.g. configurable `Contracts` namespace)
```

## License

MIT 2015, Chris Hitchcott
