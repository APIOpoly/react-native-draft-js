import {EditorState, convertFromRaw, convertToRaw} from '.'

export const rawToEditorState = (data: Object) =>
  EditorState.createWithContent(convertFromRaw(data))

export const editorStateToRaw = (editorState): Object =>
  convertToRaw(editorState.getCurrentContent())
