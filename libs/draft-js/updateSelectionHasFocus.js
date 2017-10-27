import {EditorState} from '.'

export default function updateSelectionHasFocus(editorState, hasFocus) {
  let selectionState = editorState
    .getSelection()
    .merge({hasFocus})

  return EditorState.forceSelection(
    editorState,
    selectionState
    )
}
