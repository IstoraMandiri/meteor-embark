Package.describe({
  summary: "Streamlined Ethereum Integration",
  version: "0.6.3",
  name: "hitchcott:embark",
  git: "https://github.com/hitchcott/meteor-embark.git"
});

Package.registerBuildPlugin({
  name: "embark",
  use: [
    "meteor", // for wrapAsync
    "caching-compiler@1.0.0",
    "coffeescript@1.0.10"
  ],
  sources: [
    "handler.coffee"
  ],
   npmDependencies: {
    'embark-framework': '1.0.2',
    'ps-node': 'https://github.com/hitchcott/ps/archive/2ace1d34a77a12c62dcc4aee597d93b1a28468b4.tar.gz',
    'intercept-stdout': '0.1.2'
  }
});

Package.onUse(function (api) {
  api.versionsFrom('1.2-rc.7');

  api.use([
    'isobuild:compiler-plugin@1.0.0',
    'ethereum:web3@=0.13.0'
  ]);

});
