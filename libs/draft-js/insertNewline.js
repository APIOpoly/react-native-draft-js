import {EditorState, Modifier} from '.'

export default function keyCommandInsertNewline(editorState) {
  var contentState = Modifier.splitBlock(
    editorState.getCurrentContent(),
    editorState.getSelection()
  )

  return EditorState.push(
    editorState,
    contentState,
    'split-block'
  )
}
