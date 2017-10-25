import {SelectionState} from '.'

export default function makeSelectionState(startKey, endKey, start, end, hasFocus) {
  return SelectionState
    .createEmpty(startKey)
    .merge({
      anchorKey: startKey,
      anchorOffset: start,
      focusKey: endKey,
      focusOffset: end,
      hasFocus: hasFocus || false,
      isBackward: false
    })
}
