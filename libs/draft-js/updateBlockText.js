import {EditorState, Modifier} from '.'
import updateEditorSelection from './updateEditorSelection'

export const updateBlockText = (editorState, key, text) => {
  const contentState = editorState.getCurrentContent()
  const block = contentState.getBlockForKey(key)
  editorState = updateEditorSelection(editorState, key, 0, _.size(block.getText()))

  const newContentState = Modifier.replaceText(
    contentState,
    editorState.getSelection(),
    text,
    editorState.getCurrentInlineStyle()
  )

  return EditorState.push(
    editorState,
    newContentState,
    'insert-characters'
  )
}
