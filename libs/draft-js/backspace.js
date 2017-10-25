import {keyCommandPlainBackspace, keyCommandBackspaceWord, keyCommandBackspaceToStartOfLine} from '.'

/*
when called in draftJS the command is defined with:
var command = editor.props.keyBindingFn(e)

Here is associated comment:
  * Intercept keydown behavior to handle keys and commands manually, if desired.
  *
  * Keydown combinations may be mapped to `DraftCommand` values, which may
  * correspond to command functions that modify the editor or its contents.
  *
  * See `getDefaultKeyBinding` for defaults. Alternatively, the top-level
  * component may provide a custom mapping via the `keyBindingFn` prop.

See editOnKeyDown file
*/
export default function onKeyCommand(command, editorState) {
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
      return editorState;
  }
}
