import insertBlock from './insertBlock'

export default function insertAtomicBlock(editorState, type, url) {
  let insertAfterKey
  const selectedBlockKey = editorState.getSelection().getAnchorKey()
  let lastBlockKey = editorState.getCurrentContent().getLastBlock().getKey()

  // If no input has yet been focused, insert image at the end of the content state
  if (this.state.focusedBlock === undefined) {
    insertAfterKey = lastBlockKey
  } else {
    insertAfterKey = selectedBlockKey
  }

  let newEditorState = insertBlock(
    this.state.editorState,
    insertAfterKey,
    {
      type: 'atomic',
      data: {
        type: type,
        url: url
      },
      focusNewBlock: true
    }
  )

  // Get the key of the new block
  const newFocusedBlock = editorState.getCurrentContent().getBlockAfter(insertAfterKey).getKey()

  // If inserted at the bottom, insert a blank text box after it
  if (lastBlockKey === insertAfterKey) {
    newEditorState = insertBlock(
      editorState,
      newFocusedBlock
    )
  }

  return newEditorState
}
