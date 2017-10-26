import {EditorState, Modifier} from '.'

function keyCommandInsertNewline(editorState) {
  var contentState = DraftModifier.splitBlock(
    editorState.getCurrentContent(),
    editorState.getSelection()
  )

  return EditorState.push(
    editorState,
    contentState,
    'split-block'
  )
}
