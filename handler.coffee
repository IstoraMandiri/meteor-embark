spawn = Npm.require('child_process').spawn
Embark = Npm.require '../../../../../../ether/embark-framework'

# initialise enbark
Embark.init()
# storage is used for storing a cache-hash between builds
# storage.initSync dir: '.persist' # configure this to be more discreet

# TODO make the following block configurable via embark.yml

# # if embark.yml is not visible, just ignore it and go with the following default
# # load settings from project folders
Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'
# # put chains.json in root dir of project, as per default embark behaviour
chainFile = 'chains.json'
env = process.env.EMBARK_ENV || 'development'


# TODO implement smarter startup sequenc; don't try to spawn unless it's begun already
# this is technically an optimisation because it will close itself anyway quite quickly
# but it would be nice to do anyway so we don't spam up the console every rer

# check if the process is not started
# or check to see if the settings are different

#   always shut down the old process if it exists

#   start the process with new settings

# TEMPORARILY DISABLE CONSOLE LOG
# tempThing = console.log
# console.log = -> return null

commandArgs = Embark.getStartBlockchainCommand(env, true).split(' ')

# # RESTORE CONSOLE LOG
# console.log = tempThing

commandName = commandArgs.shift()
networkId = commandArgs[commandArgs.indexOf('--networkid')+1]

console.log """
🔗  Connecting to Ethereum networkId #{networkId}
"""

# todo make output configurable
spanwedProcess = spawn commandName, commandArgs, stdio: ['ignore', 'ignore', 'ignore']

# hold on a seconds
# while new Date().getTime() < new Date().getTime() + 2000
#   return



# define a class to be used by registerCompiller
# embark's `deployContracts` adds multiple files into one and adds a connection script
# so we'll need to hash the files files together to find a combined checksum
class EmbarkCompiler
  processFilesForTarget: (files) ->
    console.log 'processing files'
    # this has is what we will use to check to see if we need to recompile
    contentHash = ""
    # map the file paths and at the same time record the hash
    filePaths = files.map (file) ->
      contentHash+= file.getSourceHash()
      # return the path itself so we can pass it directly to `deployContracts`
      return file.getPathInPackage()

    # # TEMPORARILY DISABLE CONSOLE LOG
    # tempThing = console.log
    # console.log = -> return null

    console.log "🔏  Deploying #{files.length} contract(s) on #{files[0].getArch().split('.')[0...2].join(' ')}"
    files[0].addJavaScript
      # pass `deployContracts` directly into `addJavaScript`, which returns the compiled .js file
      data: Embark.deployContracts env, filePaths, false, chainFile
      # name it in the same ay that meteor names packages, add `_web3` to the end
      path: '/packages/hitchcott_embark_web3.js'
      # add to global scope
      bare: true

    # RESTORE CONSOLE LOG
    # console.log = tempThing

# Tell meteor that we want to use the above class on all `sol` files
Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()