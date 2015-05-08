path = require 'path'
{WorkspaceView} = require 'atom'
DecorationExample = require '../lib/decoration-example'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.

describe "DecorationExample", ->
  [activationPromise, editor, editorView, decorationExampleView] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.project.setPath(path.join(__dirname, 'fixtures'))

    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      atom.workspaceView.attachToDom()
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()

      activationPromise = atom.packages.activatePackage('decoration-example').then ({mainModule}) ->
        {decorationExampleView} = mainModule
        decorationExampleView.randomizeColors = false

    waitsForPromise ->
      activationPromise

  describe "when the view is loaded", ->
    it "attaches the view", ->
      expect(atom.workspaceView.find('.decoration-example')).toExist()

  describe "when the toggle buttons are clicked", ->
    beforeEach ->
      editor.setSelectedBufferRange [[5, 8], [6, 10]]

    describe "when the gutter toggle button is clicked", ->
      it "adds a decoration to the gutter and removes it", ->
        expect(editorView.find('.gutter .line-number-green')).toHaveLength 0

        decorationExampleView.gutterToggle.click()
        expect(editorView.find('.gutter .line-number-green')).toHaveLength 2

        decorationExampleView.gutterToggle.click()
        expect(editorView.find('.gutter .line-number-green')).toHaveLength 0

    describe "when the line toggle button is clicked", ->
      it "adds a decoration to the lines and removes it", ->
        expect(editorView.find('.line.line-green')).toHaveLength 0

        decorationExampleView.lineToggle.click()
        expect(editorView.find('.line.line-green')).toHaveLength 2

        decorationExampleView.lineToggle.click()
        expect(editorView.find('.line.line-green')).toHaveLength 0

    describe "when the highlight toggle button is clicked", ->
      it "adds a decoration for the highlight and removes it", ->
        expect(editorView.find('.highlight-green .region')).toHaveLength 0

        decorationExampleView.highlightToggle.click()
        expect(editorView.find('.highlight-green .region')).toHaveLength 2

        decorationExampleView.highlightToggle.click()
        expect(editorView.find('.highlight-green .region')).toHaveLength 0

  describe "when the color cycle buttons are clicked", ->
    beforeEach ->
      editor.setSelectedBufferRange [[5, 8], [6, 10]]

    describe "when the gutter color cycle button is clicked", ->
      it "cycles through the gutter decoration's colors", ->
        decorationExampleView.gutterToggle.click()
        expect(editorView.find('.gutter .line-number-green')).toHaveLength 2

        decorationExampleView.gutterColorCycle.click()
        expect(editorView.find('.gutter .line-number-green')).toHaveLength 0
        expect(editorView.find('.gutter .line-number-blue')).toHaveLength 2

        decorationExampleView.gutterColorCycle.click()
        expect(editorView.find('.gutter .line-number-blue')).toHaveLength 0
        expect(editorView.find('.gutter .line-number-red')).toHaveLength 2

        decorationExampleView.gutterColorCycle.click()
        expect(editorView.find('.gutter .line-number-red')).toHaveLength 0
        expect(editorView.find('.gutter .line-number-green')).toHaveLength 2

    describe "when the line color cycle button is clicked", ->
      it "cycles through the line decoration's colors", ->
        decorationExampleView.lineToggle.click()
        expect(editorView.find('.line.line-green')).toHaveLength 2

        decorationExampleView.lineColorCycle.click()
        expect(editorView.find('.line.line-green')).toHaveLength 0
        expect(editorView.find('.line.line-blue')).toHaveLength 2

        decorationExampleView.lineColorCycle.click()
        expect(editorView.find('.line.line-blue')).toHaveLength 0
        expect(editorView.find('.line.line-red')).toHaveLength 2

        decorationExampleView.lineColorCycle.click()
        expect(editorView.find('.line.line-red')).toHaveLength 0
        expect(editorView.find('.line.line-green')).toHaveLength 2

    describe "when the highlight color cycle button is clicked", ->
      it "cycles through the highlight decoration's colors", ->
        decorationExampleView.highlightToggle.click()
        expect(editorView.find('.highlight-green .region')).toHaveLength 2

        decorationExampleView.highlightColorCycle.click()
        expect(editorView.find('.highlight-green .region')).toHaveLength 0
        expect(editorView.find('.highlight-blue .region')).toHaveLength 2

        decorationExampleView.highlightColorCycle.click()
        expect(editorView.find('.highlight-blue .region')).toHaveLength 0
        expect(editorView.find('.highlight-red .region')).toHaveLength 2

        decorationExampleView.highlightColorCycle.click()
        expect(editorView.find('.highlight-red .region')).toHaveLength 0
        expect(editorView.find('.highlight-green .region')).toHaveLength 2
