import {EditorState, Modifier} from '.'

export default function insertTextAtSelection(editorState, selection, text) {
  const newContentState = Modifier.insertText(
  	editorState.getCurrentContent(),
  	selection,
  	text,
  	editorState.getCurrentInlineStyle()
  )

  return EditorState.push(
  	editorState,
  	newContentState,
  	'insert-fragment'
  )
}
