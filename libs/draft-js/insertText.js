import {EditorState, Modifier} from '.'

export default function insertText(editorState, text) {
  const newContentState = Modifier.replaceText(
    editorState.getCurrentContent(),
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
