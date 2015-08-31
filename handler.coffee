spawn = Npm.require('child_process').spawn
ps = Npm.require 'ps-node'
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


###
# Blockchain Startup
###

# first we look for a blockchain process (geth)
foundProcesses = do Meteor.wrapAsync (done) ->
  ps.lookup command: 'geth', done

if foundProcesses.length
  # if we've found a process there is no need to start another one
  networkId = foundProcesses[0].arguments[foundProcesses[0].arguments.indexOf('--networkid')+1]
  if (networkId is "0" or networkId is "1") and env is 'development'
    # throw an error if we think something dangerous could happen!
    new Meteor.error 'Found external blockchian process with production networkId, exiting'
  else
    # let the user know we're connected to a network
    console.log """
    📎  Network #{networkId} : Existing Blockchain Process Found
    """

else
  # we have to start our own blockchain process
  # get command string
  commandArgs = Embark.getStartBlockchainCommand(env, true)
  # satnatize so it's compatible with `spawn`
  commandArgs = commandArgs.replace(/\"/g,'').replace(/\=/g,' ').split(' ')
  # get the command name for `spawn`
  commandName = commandArgs.shift()
  # get the network id to show user
  networkId = commandArgs[commandArgs.indexOf('--networkid')+1]

  # TODO censor out the unlock password?
  # console.log """
  #  Spawning process '#{commandName}' with params #{JSON.stringify commandArgs}
  # """
  # TODO: make output configurable
  # TODO: hide outpuut by default
  # attach settingsHash has as env variable for identification + comparison
  spawnedProcess = spawn commandName, commandArgs
  # spawnedProcess.stdout.on 'data', (msg) -> console.log msg.toString()
  # spawnedProcess.stderr.on 'data', (msg) -> console.log msg.toString()

  console.log """
  🔗  Network #{networkId} : Starting New Blockchain Process
  """
  # wait a bit
  do Meteor.wrapAsync (done) ->
    setTimeout ->
      done()
    , 2000



# define a class to be used by registerCompiller
# embark's `deployContracts` adds multiple files into one and adds a connection script
# so we'll need to hash the files files together to find a combined checksum
class EmbarkCompiler
  processFilesForTarget: (files) ->

    console.log """
    🔏  Deploying #{files.length} contract(s) on #{files[0].getArch().split('.')[0...2].join(' ')}
    """

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