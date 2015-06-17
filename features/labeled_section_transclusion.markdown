## Labeled Section Transclusion

Similar to
`https://www.mediawiki.org/wiki/Extension:Labeled_Section_Transclusion`

Basically, we want to be able to transclude parts of other pages within a
page.

An example of this might be that we have an overview page where we'd like to
pull quotes from within their original source pages without copying them. We
also want the reference from the caller to the labeled section to be tracked.

There can be arbitrary numbers of sections, which can also overlap
arbitrarily.

### Considerations

#### Label name changes

You might think you have a great name for a label, but then you come up with
a better one.  You should be able to change the name of the label without
causing any of the transclusions to break.  To accomplish this, we use
an internal id-based format.
