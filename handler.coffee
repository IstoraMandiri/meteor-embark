spawn = Npm.require('child_process').spawn
# TODO replace with actual embark release
Embark = Npm.require 'embark-framework'
Future = Npm.require 'fibers/future'
async = Npm.require 'async'
intercept = Npm.require 'intercept-stdout'
ps = Npm.require 'ps-node'

###
# Initialise Embark
#
# This runs once every time meteor is started, but not after hot code reloads.
###

Embark.init()
# put chains.json in root dir of project, as per default embark behaviour
chainFile = 'chains.json'
# allow importing of environment
env = process.env.EMBARK_ENV || 'development'
# load settings from project folders
try
  Embark.contractsConfig.loadConfigFile 'config/contracts.yml'
  Embark.blockchainConfig.loadConfigFile 'config/blockchain.yml'
catch e
  console.log e
  return false

###
# Blockchain Startup
#
# This runs once every time meteor is started, but not after hot code reloads.
###

# first we should quiet things down
unhookIntercept = intercept (text) ->
  if text.indexOf('Account #') is 0
    return """
    🔑  #{text.toLowerCase()}
    """
  else if process.env.EMBARK_DEBUG
    return text
  else
    return ""

# debug
console.log Embark.contractsConfig
console.log Embark.blockchainConfig


# let's look for an existing blockchain process (geth)
foundProcesses = do Meteor.wrapAsync (done) ->
  ps.lookup
    command: 'geth'
  , (err,res) ->
    console.log 'ps.lookup', err, res
    done err, res


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
    unhookIntercept()
  else
    unhookIntercept()
    # let the user know we're connected to a network
    console.log "📎  network #{networkId} : Existing Blockchain Process Found"

else
  # there's nothing running so we have to start our own blockchain process
  # get command string
  commandArgs = Embark.getStartBlockchainCommand(env, true)

  console.log 'getStartBlockchainCommand returned: ', commandArgs

  # satnatize so it's compatible with `spawn`
  commandArgs = commandArgs
  .replace /\"/g, ''
  .replace /\=/g, ' '
  .split ' '

  # get the command name for `spawn`
  commandName = commandArgs.shift()

  if process.env.EMBARK_VERBOSITY
    commandArgs = ['--verbosity', process.env.EMBARK_VERBOSITY].concat commandArgs

  # get the network id to show user
  if commandArgs.indexOf('--networkid') is -1
    # make sure we're not doing anything stupid
    new Meteor.error 'Couldn\'t get a networkId, exiting...'
  else
    networkId = commandArgs[commandArgs.indexOf('--networkid')+1]

  # copy miner javascript code to temp directory, emulating `geth deploy`
  Embark.copyMinerJavascriptToTemp()

  # debug output
  console.log 'spawn:', "#{commandName} #{commandArgs.join(' ')}"
  # spawn the blockchain process
  spawnedProcess = spawn commandName, commandArgs,
    stdio: ['ignore','pipe','pipe']

  # no more console spam
  unhookIntercept()

  # console log the childprocess
  spawnedProcess.stdout.on 'data', (msg) ->
    if process.env.EMBARK_DEBUG
      console.log "child stdout: #{msg}"

    # create a nice mining tracker
    else if msg.toString().indexOf('== Pending transactions!') > -1
      process.stdout.write "  🔨  Mining Transactions...\r"
    else if msg.toString().indexOf('== No transactions left.') > -1
      process.stdout.write "                                                       \r"

  if process.env.EMBARK_DEBUG
    spawnedProcess.stderr.on 'data', (msg) ->
        console.log "child stderr: #{msg}"

  # add shutdown hook
  killBlockchain = -> process.kill spawnedProcess
  process.on "uncaughtException", killBlockchain
  process.on "SIGINT", killBlockchain
  process.on "SIGTERM", killBlockchain


  console.log "🔗  network #{networkId} : Starting New Blockchain Process"

  # now wait for the process to be ready for contract creation
  do Meteor.wrapAsync (done) ->
    timeout = setTimeout ->
      done()
    , 1000 * 10 # 10 second timeout

    unlockListener = (msg) ->
      if msg.toString().indexOf 'Listening on' > -1
        clearTimeout timeout
        spawnedProcess.stderr.removeListener 'data', unlockListener
        setTimeout ->
          done()
        , 1000

    spawnedProcess.stderr.on 'data', unlockListener

  # debug output
  if process.env.EMBARK_DEBUG
    foundProcesses = do Meteor.wrapAsync (done) ->
      ps.lookup
        command: 'geth'
      , (err,res) ->
        console.log 'Started geth process', err, res
        done err, res


###
# Compile & Deploy .sol files
#
# This runs once every time meteor is started AND during hot code reloads.
###

class EmbarkCompiler extends CachingCompiler
  constructor: ->
    @deploymentNotifications = {}
    @firstRun = true
    super
      compilerName: 'EmbarkCompiler'
      defaultCacheSize: 1024*1024*10
      maxParallelism: 1

  _getCompileOptions: (inputFile) ->
    bare: true
    filename: inputFile.getPathInPackage()
    # This becomes the "file" field of the source map.
    generatedFile: "/" + inputFile.getPathInPackage() + ".js"
    # This becomes the "sources" field of the source map.
    sourceFiles: [inputFile.getDisplayPath()]

  getCacheKey: (inputFile) ->
    [
      inputFile.getArch()
      inputFile.getSourceHash()
      @_getCompileOptions(inputFile)
    ]

  compileResultSize: (compileResult) ->
    compileResult.length

  notifyDeployment : (deploymentMessage) ->
    contractName = deploymentMessage.split(' ')[1]
    notifiedBefore = @deploymentNotifications[contractName]?
    @deploymentNotifications[contractName] = true
    return notifiedBefore

  # hook into the before/after hook
  processFilesForTarget: (inputFiles) ->
    # filter output
    unhookIntercept = intercept (message) =>
      # make the outuput easier to parse
      if message.indexOf('deployed ') is 0
        @notifyDeployment message
        return "\n🔏  #{message}"
      else if message.indexOf('contract ') is 0 and !@notifyDeployment(message)
        return "🔐  #{message}"
      else if process.env.EMBARK_DEBUG
        return message
      else
        return ""

    thisArch = inputFiles[0].getArch()
    console.log "Processing contracts for #{thisArch}"
    # for each arch, we will recompile all contracts if any of the contracts change
    needToRecompile = false

    for inputFile in inputFiles
      # first check for a cached versions
      cacheKey = @_deepHash @getCacheKey(inputFile)
      if !@_cache.get(cacheKey)
        # there's no cached version, so flag that we need to recompile all contracts on this arch
        needToRecompile = true
        # let's tell the cache that we have the latest version of this file compiled
        # we don't need to save the cache result because we generate it fresh each time we deploy
        @_cache.set cacheKey, true

    combinedCacheKey = @_deepHash ['combined', thisArch]
    cachedResult = @_cache.get(combinedCacheKey)

    if needToRecompile or !cachedResult
      console.log 'Need to recompile!'
      # get contract paths
      filePaths = inputFiles.map (file) -> file.getPathInPackage()
      # compile them together, then re-add for the relevent files
      compiledABIs = Embark.deployContracts env, filePaths, false, chainFile
      # save the result to the cache
      @_cache.set combinedCacheKey, compiledABIs
      @addCompileResult inputFiles[0], compiledABIs, '/packages/hitchcott_embark_web3_contracts.js'
    else
      # add cached version
      console.log "using cached contracts on #{thisArch}"
      @addCompileResult inputFiles[0], cachedResult, '/packages/hitchcott_embark_web3_contracts.js'

    @firstRun = false
    unhookIntercept()

  addCompileResult: (inputFile, compileResult, path) ->
    console.log 'adding compile result', compileResult
    inputFile.addJavaScript
      data: compileResult,
      path: path



# Tell meteor that we want to use the above class on all `sol` files
Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()
