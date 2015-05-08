{View} = require 'atom'

module.exports =
class DecorationExampleView extends View
  @content: ->
    @div class: 'decoration-example tool-panel panel-bottom padded', =>
      @div class: 'btn-toolbar', =>
        @div class: 'btn-group', =>
          @button outlet: 'gutterToggle', class: 'btn', 'Toggle Gutter Decoration'
          @button outlet: 'gutterColorCycle', class: 'btn', 'Cycle Gutter Color'

        @div class: 'btn-group', =>
          @button outlet: 'lineToggle', class: 'btn', 'Toggle Lines Decoration'
          @button outlet: 'lineColorCycle', class: 'btn', 'Cycle Lines Color'

        @div class: 'btn-group', =>
          @button outlet: 'highlightToggle', class: 'btn', 'Toggle Highlight Decoration'
          @button outlet: 'highlightColorCycle', class: 'btn', 'Cycle Highlight Color'

  colors: ['green', 'blue', 'red']
  randomizeColors: true

  initialize: (serializeState) ->
    @decorationsByEditorId = {}
    @toggleButtons =
      'line': @lineToggle
      'line-number': @gutterToggle
      'highlight': @highlightToggle

    @lineToggle.on 'click', => @toggleDecorationForCurrentSelection('line')
    @gutterToggle.on 'click', => @toggleDecorationForCurrentSelection('line-number')
    @highlightToggle.on 'click', => @toggleDecorationForCurrentSelection('highlight')

    @lineColorCycle.on 'click', => @cycleDecorationColor('line')
    @gutterColorCycle.on 'click', => @cycleDecorationColor('line-number')
    @highlightColorCycle.on 'click', => @cycleDecorationColor('highlight')

    atom.workspaceView.on 'pane-container:active-pane-item-changed', => @updateToggleButtonStates()

  ## Decoration API methods

  createDecorationFromCurrentSelection: (editor, type) ->
    # Get the user's selection from the editor
    range = editor.getSelectedBufferRange()

    # create a marker that never invalidates that folows the user's selection range
    marker = editor.markBufferRange(range, invalidate: 'never')

    # create a decoration that follows the marker. A Decoration object is returned which can be updated
    decoration = editor.decorateMarker(marker, type: type, class: "#{type}-#{@getRandomColor()}")
    decoration

  updateDecoration: (decoration, newDecorationParams) ->
    # This allows you to change the class on the decoration
    decoration.update(newDecorationParams)

  destroyDecorationMarker: (decoration) ->
    # Destory the decoration's marker because we will no longer need it.
    # This will destroy the decoration as well. Destroying the marker is the
    # recommended way to destory the decorations.
    decoration.getMarker().destroy()

  ## Button handling methods

  toggleDecorationForCurrentSelection: (type) ->
    return unless editor = @getEditor()

    decoration = @getCachedDecoration(editor, type)
    if decoration?
      @destroyDecorationMarker(decoration)
      @setCachedDecoration(editor, type, null)
    else
      decoration = @createDecorationFromCurrentSelection(editor, type)
      @setCachedDecoration(editor, type, decoration)

    @updateToggleButtonStates()
    atom.workspaceView.focus()
    decoration

  updateToggleButtonStates: ->
    if editor = @getEditor()
      decorations = @decorationsByEditorId[editor.id] ? {}
      for type, button of @toggleButtons
        if decorations[type]?
          button.addClass('selected')
        else
          button.removeClass('selected')
    else
      for type, button of @toggleButtons
        button.removeClass('selected')

  cycleDecorationColor: (type) ->
    return unless editor = @getEditor()

    decoration = @getCachedDecoration(editor, type)
    decoration ?= @toggleDecorationForCurrentSelection(type)

    klass = decoration.getParams().class
    currentColor = klass.replace("#{type}-", '')
    newColor = @colors[(@colors.indexOf(currentColor) + 1) % @colors.length]
    klass = "#{type}-#{newColor}"

    @updateDecoration(decoration, {type, class: klass})

  ## Utility methods

  getEditor: ->
    atom.workspace.getActiveTextEditor()

  getCachedDecoration: (editor, type) ->
    (@decorationsByEditorId[editor.id] ? {})[type]

  setCachedDecoration: (editor, type, decoration) ->
    @decorationsByEditorId[editor.id] ?= {}
    @decorationsByEditorId[editor.id][type] = decoration

  getRandomColor: ->
    if @randomizeColors
      @colors[Math.round(Math.random() * 2)]
    else
      @colors[0]

  attach: ->
    atom.workspaceView.prependToBottom(this)

  # Tear down any state and detach
  destroy: ->
    @detach()
