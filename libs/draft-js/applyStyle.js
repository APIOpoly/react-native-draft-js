import {RichUtils} from '.'

export default function applyStyle(editorState, styleType) {
  return RichUtils.handleKeyCommand(editorState, styleType)
}
