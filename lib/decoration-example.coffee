DecorationExampleView = require './decoration-example-view'

module.exports =
  decorationExampleView: null

  activate: (state) ->
    @decorationExampleView = new DecorationExampleView(state.decorationExampleViewState)
    @decorationExampleView.attach()

  deactivate: ->
    @decorationExampleView.destroy()

  serialize: ->
    decorationExampleViewState: @decorationExampleView.serialize()
