# Decoration Example

This will show you all the capabilities of Atom's Decoration API. When enabled, this package adds a panel of buttons that exercise the API.

![decoration-example](https://cloud.githubusercontent.com/assets/69169/3518389/d9a8344e-06ff-11e4-9283-c32c9d99e0c1.gif)

## What is the Decoration API?

It's common when writing packages to annotate, or decorate lines, gutter line numbers, and highlight ranges of text. The decoration API allows you to add CSS classes and styling to these line, gutter line numbers, and regions of text.

Several packages use decorations: [git-diff] (for gutter diff indicators), [bookmarks] (for gutter book mark indicators), and [find-and-replace] (for boxes around found search terms). Decorations are even used in the core editor: selections (the colored selection regions are decorations), and the highlight in the gutter indicating which line the cursor is on.

## The code

The interesting bits of this package are in the [decoration-example-view]. Here is a summary:

### Creating a decoration

```coffee
range = editor.getSelectedBufferRange()
marker = editor.markBufferRange(range, invalidate: 'never')
editor.decorateMarker(marker, type: 'line', class: "my-line-class")
```

### Updating a decoration

You can change the class on a decoration if you like:

```coffee
decoration.setProperties(type: 'line', class: 'some-other-class')
```

### Destroying a decoration

There are two ways to destroy a decoration. If you own the marker and will no longer need it, you can destroy the marker, and the decoration will be destroyed. Destorying the marker is the recommended way of destroying a decoration.

```coffee
marker.destroy()
```

If you still need the marker after the decoration has been destroyed, you can destroy the decoration directly.

```coffee
decoration.destroy()
```

## Styling

There is no default styling for decorations. See the [stylesheet] for examples.

## Testing

Your package using decorations will likely need to test that the proper decorations are in place. This package's [specs] will help you test your package.


[git-diff]:https://github.com/atom/git-diff
[find-and-replace]:https://github.com/atom/find-and-replace
[bookmarks]:https://github.com/atom/bookmarks
[decoration-example-view]:https://github.com/atom/decoration-example/blob/master/lib/decoration-example-view.coffee#L40
[stylesheet]:https://github.com/atom/decoration-example/blob/master/styles/decoration-example.less
[specs]: https://github.com/atom/decoration-example/blob/master/spec/decoration-example-spec.coffee#L33
