import {RichUtils} from '.'

export default function toggleStyle(editorState, style) {
  return RichUtils.toggleBlockType(editorState, style)
}
