Package.describe({
  summary: "Transparent Embark integration",
  version: "0.2.0",
  name: "hitchcott:embark",
  git: "https://github.com/hitchcott/meteor-embark.git"
});

Package.registerBuildPlugin({
  name: "embark",
  use: [
    "caching-compiler@1.0.0-rc.0", // TODO: implement this
    "coffeescript@1.0.8-rc.2"
  ],
  sources: [
    "handler.coffee"
  ],
   npmDependencies: {
    'embark-framework': '0.8.6',
    'node-persist': '0.0.5'
  }
});

Package.onUse(function (api) {
  api.use('isobuild:compiler-plugin@1.0.0');
});
