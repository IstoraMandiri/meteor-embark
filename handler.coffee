fs = Npm.require 'fs'
Embark = Npm.require 'embark-framework'

Embark.init()
# TODO make this configurable?
Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'
chainFile = 'chains.json'
env = 'development' # TODO : actually check for environment

# TODO add caching
class EmbarkCompiler
    processFilesForTarget: (files) ->
      filePaths = files.map (file) -> file.getPathInPackage()
      files[0].addJavaScript
        data: Embark.deployContracts env, filePaths, false, chainFile
        path: '/packages/hitchcott_embark_web3.js'

Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()