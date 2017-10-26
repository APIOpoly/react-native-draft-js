import {EditorState, Modifier} from '.'

export default function insertTextAtPosition(editorState, text, position) {
  const newContentState = Modifier.insertText(
  	editorState.getCurrentContent(),
  	position,
  	text,
  	editorState.getCurrentInlineStyle()
  )

  return EditorState.push(
  	editorState,
  	newContentState,
  	'insert-fragment'
  )
}
