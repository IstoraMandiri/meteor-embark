fs = Npm.require 'fs'
crypto = Npm.require 'crypto'
Embark = Npm.require 'embark-framework'
storage = Npm.require 'node-persist'

# initialise enbark
Embark.init()
# storage is used for storing a cache-hash between builds
storage.initSync()

# TODO make the following block configurable via embark.yml

# if embark.yml is not visible, just ignore it and go with the following default
# load settings from project folders
Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'
# put chains.json in root dir of project, as per default embark behaviour
chainFile = 'chains.json'
env = process.env.EMBARK_ENV || 'development'

# define a class to be used by registerCompiller
# embark's `deployContracts` adds multiple files into one and adds a connection script
# so we'll need to hash the files files together to find a combined checksum
class EmbarkCompiler
  processFilesForTarget: (files) ->
    # this has is what we will use to check to see if we need to recompile
    contentHash = ""
    # map the file paths and at the same time record the hash
    filePaths = files.map (file) ->
      contentHash+= file.getSourceHash()
      # return the path itself so we can pass it directly to `deployContracts`
      return file.getPathInPackage()

    # we don't want to store a huge combined hash if there are lots of files
    # so let's shorten it to a fixed length
    contentHash = crypto.createHash('md5').update(contentHash).digest('hex')
    # let's compare this hash to the one that we created last time we compiled
    if contentHash isnt storage.getItem 'contentHash'
      # if it is not the same, we need to compile again
      # but first let's record our current hash for next time
      storage.setItem 'contentHash', contentHash
      # let the developer know what we're doing
      # TODO add option to silence
      console.log "🔨  compiling #{files.length} solidity files platform [#{files[0].getArch().split('.')[0]}]"
      # use files[0] becuase AFAIK there is no global `addJavascipt` available
      # this seems to work just as well, but could be regarded as hacky
      files[0].addJavaScript
        # pass `deployContracts` directly into `addJavaScript`, which returns the compiled .js file
        data: Embark.deployContracts env, filePaths, false, chainFile
        # name it in the same ay that meteor names packages, add `_web3` to the end
        path: '/packages/hitchcott_embark_web3.js'

# Tell meteor that we want to use the above class on all `sol` files
Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()