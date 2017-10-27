import {EditorState} from '.'

export default function updateSelectionAnchorAndFocus(editorState, anchorKey, anchorOffset, focusKey, focusOffset) {
  let selectionState = editorState
    .getSelection()
    .merge({anchorKey, anchorOffset, focusKey, focusOffset})

  return EditorState.forceSelection(
    editorState,
    selectionState
    )
}
