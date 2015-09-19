Package.describe({
  summary: "Streamlined Ethereum Integration",
  version: "0.6.0",
  name: "hitchcott:embark",
  git: "https://github.com/hitchcott/meteor-embark.git"
});

Package.registerBuildPlugin({
  name: "embark",
  use: [
    "meteor", //for wrapAsync
    "caching-compiler@1.0.0-rc.0",
    "coffeescript@1.0.8-rc.2"
  ],
  sources: [
    "handler.coffee"
  ],
   npmDependencies: {
    'embark-framework': '0.9.1',
    'ps-node': '0.0.4',
    'intercept-stdout': '0.1.2'
  }
});

Package.onUse(function (api) {
  api.versionsFrom('1.2-rc.7');
  api.use();
  api.use([
    'isobuild:compiler-plugin@1.0.0',
    'ethereum:web3@0.12.2'
  ]);
  api.export('web3');
});
