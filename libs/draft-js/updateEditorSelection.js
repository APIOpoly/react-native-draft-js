import {EditorState} from '.'
import makeSelectionState from './makeSelectionState'

export default function updateEditorSelection(editorState, key, start, end, hasFocus) {
  const newSelectionState = makeSelectionState(key, key, start, end, hasFocus)
  return EditorState.forceSelection(
    editorState,
    newSelectionState
  )
}
