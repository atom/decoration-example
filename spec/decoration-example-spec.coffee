{WorkspaceView} = require 'atom'
DecorationExample = require '../lib/decoration-example'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "DecorationExample", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('decoration-example')

  describe "when the decoration-example:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.decoration-example')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'decoration-example:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.decoration-example')).toExist()
        atom.workspaceView.trigger 'decoration-example:toggle'
        expect(atom.workspaceView.find('.decoration-example')).not.toExist()
