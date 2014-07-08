{View} = require 'atom'

module.exports =
class DecorationExampleView extends View
  @content: ->
    @div class: 'decoration-example tool-panel panel-bottom', =>
      @div "The DecorationExample package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "decoration-example:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "DecorationExampleView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
