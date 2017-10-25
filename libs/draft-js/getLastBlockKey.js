export default function getLastBlockKey(editorState) {
  return editorState.getCurrentContent().getLastBlock().getKey()
}
