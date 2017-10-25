import {EditorState} from '.'

import makeSelectionState from './makeSelectionState'

export default function removeBlock(editorState, blockKey) {
  const contentState = editorState.getCurrentContent()
  const blockToRemove = contentState.getBlockForKey(blockKey)
  const blocks = contentState.getBlockMap()
  const blocksBefore = blocks.toSeq().takeUntil(v => v === blockToRemove)
  const blocksAfter = blocks.toSeq().skipUntil(v => v === blockToRemove).rest()
  const newBlocks = blocksBefore.concat(blocksAfter).toOrderedMap()
  const firstBlock = newBlocks.first()
  const newContentState = contentState.merge({
    blockMap: newBlocks
  })

  let newState = EditorState.push(editorState, newContentState, 'remove-range')
  newState = EditorState.acceptSelection(newState, makeSelectionState(
    firstBlock.getKey(),
    firstBlock.getKey(),
    0,
    0,
  ))

  return newState
}
