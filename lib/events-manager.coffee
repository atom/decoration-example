View = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class EventsManager
  notify: ->
    noteMessage = 'Try hovering over the gutter/line highlights.'
    notifOnOff = atom.config.get('decoration-example.showconfignotification')
    if notifOnOff == 'on' or typeof notifOnOff is 'undefined'
      atom.notifications.addInfo noteMessage,
        buttons: [ {
          text: 'Don\'t show again'
          onDidClick: (ev) ->
            atom.config.set 'decoration-example.showconfignotification', 'off'
            notes = atom.notifications.getNotifications()
            i = 0
            while i < notes.length
              if notes[i].getMessage() == noteMessage
                notes[i].dismiss()
              i++
            return
        } ]
        dismissable: true

  #this currently works with only gutter and line decorations
  doDecoration: (decoration) ->
    @notify()
    klass = decoration.getProperties().class
    #we're interested in the current editor
    edview = atom.views.getView(atom.workspace.getActiveTextEditor())
    #We have to wait for the decoration
    #To be added until atom's API implements some sort of
    #callback on notification added.
    #So for now we resort to a timeout callback
    stocb = =>
      #We identify our element by the klass added to it
      #The text-editor relevant DOM elements
      #All fall under a deprecated ::shadow pseudo element
      shadowRoot = edview.shadowRoot
      match = shadowRoot.querySelector(".#{klass}")
      if (match != null)
        #Get our object and play around with it
        object = View.$(match)
        #it is important to realize that this
        #call back will run for any object that
        #matches the above selector
        #You can check the line number by reading
        #the data-screen-row attribute
        object.mouseover (ev) =>
          #You can inspect object here via debugger or
          #console.log(object)
          sr = object.attr("data-screen-row")
          console.log("moused over at screen row #{sr}")
          divhtml = '<div class="my-div" style="top:' + (event.clientY-40) +
                     'px;left:' + (event.clientX-120) + 'px;">\
                        Moused over!
                        </div>'
          div = View.$(divhtml).appendTo("body")
          div.mouseout =>
            div.remove()
        decoration.onDidDestroy =>
          #once the decoration is gone
          #we have to stop tracking the line-number div
          #this will prevent the mouseover event to trigger
          #again on the same line
          object.off()
    setTimeout stocb, 100
