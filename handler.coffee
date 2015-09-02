spawn = Npm.require('child_process').spawn
ps = Npm.require 'ps-node'
Embark = Npm.require 'embark-framework'
intercept = Npm.require 'intercept-stdout'


###
# Initialise Enbark
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
    📎  network #{networkId} : Existing Blockchain Process Found
    """

else
  # there's nothing running so we have to start our own blockchain process

  # first we should quiet things down
  unhookIntercept = intercept (text) -> if process.env.EMBARK_DEBUG then text else ""

  # get command string
  commandArgs = Embark.getStartBlockchainCommand(env, true)

  console.log 'getStartBlockchainCommand returned: ', commandArgs

  # satnatize so it's compatible with `spawn`
  commandArgs = commandArgs
  .replace /\"/g, ''
  .replace /\=/g, ' '
  .replace /\*/g, '\"\*\"'
  .replace /\,/g, '\,'
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

  # spawn the blockchain process
  spawnedProcess = spawn commandName, commandArgs
  # add shutdown hook
  killBlockchain = -> process.kill spawnedProcess
  process.on "uncaughtException", killBlockchain
  process.on "SIGINT", killBlockchain
  process.on "SIGTERM", killBlockchain

  console.log 'spawning command: ', commandName, commandArgs.join(' ')

  if process.env.EMBARK_DEBUG
    spawnedProcess.stdout.on 'data', (msg) -> console.log msg.toString()
    spawnedProcess.stderr.on 'data', (msg) -> console.log msg.toString()

  unhookIntercept()

  console.log """
  🔗  network #{networkId} : Starting New Blockchain Process
  """

  # blockchain is ready once account is unlocked. block progress until then.
  do Meteor.wrapAsync (done) ->
    timeout = setTimeout ->
      done()
    , 1000 * 10 # 10 second timeout

    unlockListener = (msg) ->
      if msg.toString().indexOf 'unlocked' > -1
        clearTimeout timeout
        spawnedProcess.stdout.removeListener 'data', unlockListener
        done()

    spawnedProcess.stdout.on 'data', unlockListener



###
# Compile & Deploy .sol files
###


class EmbarkCompiler extends CachingCompiler

  constructor: ->
    super
      compilerName: 'EmbarkCompiler'
      defaultCacheSize: 1024*1024*10
      maxParallelism: 3

  _getCompileOptions: (inputFile) ->
    bare: true
    filename: inputFile.getPathInPackage()
    # This becomes the "file" field of the source map.
    generatedFile: "/" + inputFile.getPathInPackage() + ".js"
    # This becomes the "sources" field of the source map.
    sourceFiles: [inputFile.getDisplayPath()]


  getCacheKey: (inputFile) ->
    [
      inputFile.getSourceHash()
      @_getCompileOptions(inputFile)
    ]

  compileResultSize: (compileResult) -> compileResult.length

  compileOneFile: (inputFile) ->
    # filter output
    unhookIntercept = intercept (message) ->

      if message.indexOf('deployed') is 0
        return """
        \n🔏  #{message}
        """
      else if message.indexOf('contract') is 0
        return """
        🔐  #{message}
        """
      else if process.env.EMBARK_DEBUG
        return message
      else
        return ""

    # the actual compilation step
    compiledContract = Embark.deployContracts env, [inputFile.getPathInPackage()], false, chainFile

    # stop filtering outuput
    unhookIntercept()

    # remove web3 script, to be added once later
    pureContract = ""
    for line in compiledContract.split(';')
      if line.indexOf('web3.') isnt 0
        pureContract+= line + ';\n'

    return pureContract


  addCompileResult: (inputFile, compileResult) ->
    inputFile.addJavaScript
      data: compileResult,
      path: inputFile.getPathInPackage() + '.js',



# Tell meteor that we want to use the above class on all `sol` files
Plugin.registerCompiler
  extensions: ["sol"]
, -> new EmbarkCompiler()
