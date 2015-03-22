# #enigma2 Plugin

# This is an plugin to control a linux receiver

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  util = env.require 'util'
  M = env.matcher
  Restler = require 'restler'

  ip = ""
  port = 80
  user = ""
  password = ""
  
  class enigma2Plugin extends env.plugins.Plugin

    # ####init()
    init: (app, @framework, config) =>
      ip = config.ip
      port = config.port
      user = config.user
      password = config.password
      @framework.ruleManager.addActionProvider(new enigma2MessageActionProvider @framework, config)
  
  # Create a instance of my plugin
  plugin = new enigma2Plugin()

  class enigma2MessageActionProvider extends env.actions.ActionProvider
  
    constructor: (@framework, @config) ->
      return

    parseAction: (input, context) =>

      defaultTimeout = @config.timeout
      defaultMessagetype = @config.messagetype

      # Helper to convert 'some text' to [ '"some text"' ]
      strToTokens = (str) => ["\"#{str}\""]

      timeout = defaultTimeout
      messagetype = defaultMessagetype
      messageTokens = ['""']
      
      setTimeout2 = (m, d) => timeout = d
      setMessagetype = (m, t) => messagetype = t
      setMessage = (m, tokens) => messageTokens = tokens

      m = M(input, context)
        .match('send ', optional: yes)
        .match(['tv-message'])

      next = m.match(' message:').matchStringWithVars(setMessage)
      if next.hadMatch() then m = next

      next = m.match(' messagetype:').matchStringWithVars(setMessagetype)
      if next.hadMatch() then m = next
      
      next = m.match(' timeout:').matchNumber(setTimeout2)
      if next.hadMatch() then m = next

      if m.hadMatch()
        match = m.getFullMatch()

        assert Array.isArray(messageTokens)

        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new enigma2MessageActionHandler(
            @framework, timeout, messagetype, messageTokens 
          )
        }
            

  class enigma2MessageActionHandler extends env.actions.ActionHandler 

    constructor: (@framework, @timeout, @messagetype, @messageTokens) ->

    executeAction: (simulate, context) ->
      Promise.all( [
        @framework.variableManager.evaluateStringExpression(@messageTokens)
      ]).then( ([message]) =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          return __("would send message \"%s\" with type \"%s\" and timeout \"%s\"", message, messagetype, timeout)
        else
          UserPassword = ""
          
          if user? and user.length > 0
            UserPassword = user + ":" + password + "@"
          
          messagetype = @messagetype
          timeout = @timeout
          
          mtype = 2
          if messagetype == "info"
            mtype = 2
          else if messagetype == "warning"
            mtype = 3
          else if messagetype == "error"
            mtype = 1
          else if messagetype == "question"
            mtype = 0
            
          env.logger.debug "enigma2: messagetype= #{messagetype} #{mtype}"
          env.logger.debug "enigma2: timeout= #{timeout}"
          env.logger.debug "enigma2: message= #{message}"

          Restler.post('http://'+UserPassword+ip+'/web/message', data:{ text: message, type: mtype, timeout: timeout}).on 'complete', (data, response) ->
              if response.statusCode == 201
                return "Message send successfully"
              else
                return "Error when sending message " + response.statusCode
      )

  module.exports.enigma2MessageActionHandler = enigma2MessageActionHandler

  # and return it to the framework.
  return plugin   
