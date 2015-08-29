fs = Npm.require 'fs'
crypto = Npm.require 'crypto'
Embark = Npm.require 'embark-framework'
storage = Npm.require 'node-persist'

Embark.init()
storage.initSync()

# TODO make this configurable?
Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'
chainFile = 'chains.json'
env = 'development' # TODO : actually check for environment

# TODO add caching
class EmbarkCompiler
  processFilesForTarget: (files) ->
    contentHash = ""
    filePaths = files.map (file) ->
      contentHash+= file.getSourceHash()
      return file.getPathInPackage()

    contentHash = crypto.createHash('md5').update(contentHash).digest('hex')
    if contentHash isnt storage.getItem 'contentHash'
      storage.setItem 'contentHash', contentHash
      console.log "🔨  compiling #{files.length} solidity files platform [#{files[0].getArch().split('.')[0]}]"
      files[0].addJavaScript
        data: Embark.deployContracts env, filePaths, false, chainFile
        path: '/packages/hitchcott_embark_web3.js'


Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()