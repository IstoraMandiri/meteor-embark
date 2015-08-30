# [wip] Meteor Embark

### Streamlined Ethereum Integration for Meteor

#### ️*Only compatible with Meteor 1.2 +*

```
meteor add hitchcott:embark
```

## What does it do?

Basically, it automatically runs `embark deploy`

3. Use `embark deploy` on `.sol` files, which deploys them if they need to be (the 'embark way')
4. Adds `web3` and it's contracts to platforms as global objects

## Configuration

* Use environment variable `EMBARK_ENV` to specify environment - defaults to `development`

## TODO

```
- Better caching
  - Rewrite function to be more meteor-like; compile individual SOL files
- Automatic Blockchain Starting
  - Create EmbarkDeamonizer

- Patch embark itself
  - Better startup config options
  - Silence output

- Test integration
- Configurable config file locations
- Configurable embark output (e.g. configurable `Contracts` namespace)
```

## License

MIT 2015, Chris Hitchcott
