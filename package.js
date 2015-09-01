Package.describe({
  summary: "Transparent Embark integration",
  version: "0.3.1",
  name: "hitchcott:embark",
  git: "https://github.com/hitchcott/meteor-embark.git"
});

Package.registerBuildPlugin({
  name: "embark",
  use: [
    "meteor", //for wrapasync
    "caching-compiler",
    "coffeescript@1.0.8-rc.2"
  ],
  sources: [
    "handler.coffee"
  ],
   npmDependencies: {
    'embark-framework': '0.9.0',
    'ps-node': '0.0.4'
  }
});

Package.onUse(function (api) {
  api.use('isobuild:compiler-plugin@1.0.0');
});
