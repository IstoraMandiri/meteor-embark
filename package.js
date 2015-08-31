Package.describe({
  summary: "Transparent Embark integration",
  version: "0.3.0",
  name: "hitchcott:embark",
  git: "https://github.com/hitchcott/meteor-embark.git"
});

Package.registerBuildPlugin({
  name: "embark",
  use: [
    "meteor", //for wrapasync
    "coffeescript@1.0.8-rc.2"
  ],
  sources: [
    "handler.coffee"
  ],
   npmDependencies: {
    'embark-framework': '0.8.6',
    'ps-node': '0.0.4'
  }
});

Package.onUse(function (api) {
  // TODO - create a script that stops the child process when meteor is killed by user
  // but does not quit if it's a simple restart
  api.use('isobuild:compiler-plugin@1.0.0');
});
