{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

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

        @div class: 'btn-group', =>
          @button outlet: 'overlayToggle', class: 'btn', 'Toggle Overlay Decoration'

  colors: ['green', 'blue', 'red']
  randomizeColors: true

  initialize: (serializeState) ->
    @decorationsByEditorId = {}
    disposables = new CompositeDisposable

    @toggleButtons =
      line: @lineToggle
      gutter: @gutterToggle
      overlay: @overlayToggle
      highlight: @highlightToggle

    @lineToggle.on 'click', => @toggleDecorationForCurrentSelection('line')
    @gutterToggle.on 'click', => @toggleDecorationForCurrentSelection('line-number')
    @highlightToggle.on 'click', => @toggleDecorationForCurrentSelection('highlight')

    @lineColorCycle.on 'click', => @cycleDecorationColor('line')
    @gutterColorCycle.on 'click', => @cycleDecorationColor('line-number')
    @highlightColorCycle.on 'click', => @cycleDecorationColor('highlight')

    @overlayToggle.on 'click', =>
      return unless editor = @getEditor()

      type = 'overlay'

      decoration = @getCachedDecoration(editor, type)
      if decoration?
        decoration.destroy()
        @setCachedDecoration(editor, type, null)
      else
        position = editor.getCursorBufferPosition()
        range = [position, position]

        item = document.createElement('div')
        item.classList.add 'overlay-example'
        item.classList.add 'popover-list'

        # marker = editor.markBufferRange(range, invalidate: 'never')
        marker = editor.getLastCursor().marker

        # create a decoration that follows the marker. A Decoration object is returned which can be updated
        decoration = editor.decorateMarker(marker, {type, item})

        @setCachedDecoration(editor, type, decoration)

      @updateToggleButtonStates()
      atom.workspaceView.focus()

    disposables.add atom.workspace.onDidChangeActivePaneItem => @updateToggleButtonStates()

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
    decoration.setProperties(newDecorationParams)

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
    atom.views.getView(atom.workspace).focus()
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

    klass = decoration.getProperties().class
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
    atom.workspace.addBottomPanel(item: this)

  # Tear down any state and detach
  destroy: ->
    @detach()
