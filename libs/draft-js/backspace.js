import {keyCommandPlainBackspace, keyCommandBackspaceWord, keyCommandBackspaceToStartOfLine} from '.'

export default function backspace(editorState, command) {
  if (!command) {
    return keyCommandPlainBackspace(editorState);
  }

  switch (command) {
    // I do not believe you need delete or delete-word but leaving just it to your discretion
    // case 'delete':
    //   return keyCommandPlainDelete(editorState);
    // case 'delete-word':
    //   return keyCommandDeleteWord(editorState);
    case 'backspace':
      return keyCommandPlainBackspace(editorState);
    case 'backspace-word':
      return keyCommandBackspaceWord(editorState);
    case 'backspace-to-start-of-line':
      return keyCommandBackspaceToStartOfLine(editorState);
    default:
      return null;
  }
}
