spawn = Npm.require('child_process').spawn
ps = Npm.require 'ps-node'
Embark = Npm.require 'embark-framework'

###
# Initialise Enbark
###

Embark.init()
# put chains.json in root dir of project, as per default embark behaviour
chainFile = 'chains.json'
# allow importing of environment
env = process.env.EMBARK_ENV || 'development'
# load settings from project folders
Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'


###
# Blockchain Startup
###

# first we look for a blockchain process (geth)
foundProcesses = do Meteor.wrapAsync (done) ->
  ps.lookup command: 'geth', done

if foundProcesses.length
  # if we've found a process there is no need to start another one
  if foundProcesses[0].arguments.indexOf('--networkid') is -1
    # if there is no --networkdid argument
    # let's prevent something potentially bad from happening
    # because we don't recognise this process
    new Meteor.error 'Found external blockchain process, could not identify networkId, exiting'

  # find the networkId from the process arguments
  networkId = foundProcesses[0].arguments[foundProcesses[0].arguments.indexOf('--networkid')+1]

  if networkId is "0" or networkId is "1"
    # throw an error if we think something dangerous could happen!
    # we don't want to do this in development mode
    # TODO make it possible to ooverride this in staging environment
    new Meteor.error 'Found external blockchian process with production networkId, exiting'
  else
    # let the user know we're connected to a network
    console.log """
    📎  Network #{networkId} : Existing Blockchain Process Found
    """

else
  # there's nothing running so we have to start our own blockchain process
  # get command string
  commandArgs = Embark.getStartBlockchainCommand(env, true)
  if process.env.EMBARK_DEBUG
    console.log commandArgs
  # satnatize so it's compatible with `spawn`
  commandArgs = commandArgs.replace(/\"/g,'').replace(/\=/g,' ').split(' ')
  # get the command name for `spawn`
  commandName = commandArgs.shift()
  # get the network id to show user
  if commandArgs.indexOf('--networkid') is -1
    # make sure we're not doing anything stupid
    new Meteor.error 'Couldn\'t get a networkId, exiting...'
  else
    networkId = commandArgs[commandArgs.indexOf('--networkid')+1]

  # spawn the blockchain process
  spawnedProcess = spawn commandName, commandArgs
  # add shutdown hook
  killBlockchain = -> process.kill spawnedProcess
  process.on "uncaughtException", killBlockchain
  process.on "SIGINT", killBlockchain
  process.on "SIGTERM", killBlockchain

  if process.env.EMBARK_DEBUG
    console.log commandName, commandArgs.join(' ')
    spawnedProcess.stdout.on 'data', (msg) -> console.log msg.toString()
    spawnedProcess.stderr.on 'data', (msg) -> console.log msg.toString()

  console.log """
  🔗  Network #{networkId} : Starting New Blockchain Process
  """
  # wait a bit
  do Meteor.wrapAsync (done) ->
    setTimeout ->
      done()
    , 2000


###
# OLD more basic compiler, copies embark style, no caching
###

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




# TODO Caching System
# Building the new file style

# init script i should just move to a different file
# which contains one instance of the web3 init script
# so all i need to do is process the contracts one by one through deployContracts
# and strip the init scripts before passing them into addJavascript

# by splitting out the `getSourceHash` of each individual file we can
# efficiently cache them and only recompile when totally necessary




# Tell meteor that we want to use the above class on all `sol` files
Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()
