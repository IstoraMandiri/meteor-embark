spawn = Npm.require('child_process').spawn
Embark = Npm.require '../../../../../../ether/embark-framework'

# initialise enbark
Embark.init()

# TODO make the following block configurable via embark.yml

# # if embark.yml is not visible, just ignore it and go with the following default
# # load settings from project folders
Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'
# # put chains.json in root dir of project, as per default embark behaviour
chainFile = 'chains.json'
env = process.env.EMBARK_ENV || 'development'


# start the blockchain

# TODO implement smarter startup sequence; don't try to spawn unless it's begun already
# this is technically an optimisation because it will close itself anyway quite quickly
# but it would be nice to do anyway so we don't spam up the console every rer

# check if the process is not started
# or check to see if the settings are different

#   always shut down the old process if it exists

# start the process with new settings

# get command string
commandArgs = Embark.getStartBlockchainCommand(env, true)
# satnatize it it's compatible with `spawn`
commandArgs = commandArgs.replace(/\"/g,'').replace(/\=/g,' ').split(' ')
# get the command name for `spawn`
commandName = commandArgs.shift()
# get the network id to show user
networkId = commandArgs[commandArgs.indexOf('--networkid')+1]

console.log """
 [#{commandArgs.join('] [')}]
"""
# TODO: make output configurable
spawnedProcess = spawn commandName, commandArgs#, stdio: ['ignore', 'ignore', 'ignore']
# spawnedProcess.stdout.on 'data', (msg) -> console.log msg.toString()
spawnedProcess.stderr.on 'data', (msg) -> console.log msg.toString()

console.log """
🔗  Connecting to networkId #{networkId}
"""



# define a class to be used by registerCompiller
# embark's `deployContracts` adds multiple files into one and adds a connection script
# so we'll need to hash the files files together to find a combined checksum
class EmbarkCompiler
  processFilesForTarget: (files) ->

    console.log "🔏  Deploying #{files.length} contract(s) on #{files[0].getArch().split('.')[0...2].join(' ')}"

    # map the file paths and at the same time record the hash
    filePaths = files.map (file) -> file.getPathInPackage()

    files[0].addJavaScript
      # pass `deployContracts` directly into `addJavaScript`, which returns the compiled .js file
      data: Embark.deployContracts env, filePaths, false, chainFile
      # name it in the same ay that meteor names packages, add `_web3` to the end
      path: '/packages/hitchcott_embark_web3.js'
      # add to global scope
      bare: true


# Tell meteor that we want to use the above class on all `sol` files
Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()