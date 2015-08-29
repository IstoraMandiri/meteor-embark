# [wip] Transparent embark integration for Meteor

### ⚠️ Compatible with Meteor 1.2 +

```
meteor add hitchcott:embark
```

## What does it do?

1. (TODO, optional) Automatically starts the embark blockchian in the background. For now, run `embark blockchain;`
2. (TODO) Check if we're in development or deployment
3. Use `embark deploy` on `.sol` files, which deploys them if they need to be (the 'embark way')
4. Adds `web3` and it's contracts on client and/or server as global objects

## TODO

```
- Cache compile step
- Get multiple deployment environments working
- Test integration
- Configurable config file locations
- Configurable embark output (e.g. configurable `Contracts` namespace)
```

## License

MIT 2015, Chris Hitchcott
