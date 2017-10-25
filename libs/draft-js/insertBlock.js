import {EditorState, genKey, ContentBlock} from '.'
import {List, Map} from 'immutable'
import _ from 'lodash'

import makeSelectionState from './makeSelectionState'

export default function insertBlock(editorState, blockKey, options = {}) {
  _.defaults(options, {
    type: 'unstyled',
    direction: 'after',
    text: ' ',
    data: {},
    selection: editorState.getSelection(),
    focusNewBlock: false
  })
  const contentState = editorState.getCurrentContent()
  const currentBlock = contentState.getBlockForKey(blockKey)
  const blockMap = contentState.getBlockMap()

  const blocksBefore = blockMap.toSeq().takeUntil(v => v === currentBlock)
  const blocksAfter = blockMap.toSeq().skipUntil(v => v === currentBlock).rest()
  const newBlockKey = genKey()
  const newBlock = new ContentBlock({
    key: newBlockKey,
    type: options.type,
    text: options.text,
    characterList: List(),
    data: Map(options.data)
  })

  let newBlocks = options.direction === 'before' ? [
    [newBlockKey, newBlock],
    [currentBlock.getKey(), currentBlock],
  ] : [
    [currentBlock.getKey(), currentBlock],
    [newBlockKey, newBlock],
  ]

  let nextSelection

  if (options.focusNewBlock === true) {
    nextSelection = makeSelectionState(newBlockKey, newBlockKey, 0, 0)
  } else {
    nextSelection = options.selection
  }

  const newBlockMap = blocksBefore.concat(newBlocks, blocksAfter).toOrderedMap()
  const newContentState = contentState.merge({
    blockMap: newBlockMap,
    selectionBefore: nextSelection,
    selectionAfter: nextSelection,
  })
  let newState = EditorState.push(editorState, newContentState, 'insert-fragment')
  newState = EditorState.acceptSelection(newState, nextSelection)
  return newState
}
