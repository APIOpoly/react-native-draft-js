/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Dimensions,
  AppRegistry,
  StyleSheet,
  Text,
  View,
  requireNativeComponent
} from 'react-native'

import {
  EditorState,
  RichUtils,
  convertToRaw,
  insertText,
  insertTextAtPosition,
  backspace,
  insertNewline,
} from './libs/draft-js'

const DraftJSEditor = requireNativeComponent('RNTDraftJSEditor', null)
const { width } = Dimensions.get('window')

export default class RNDraftJs extends Component {
  constructor(props) {
    super(props);
    this.state = {
      editorState: EditorState.createEmpty()
    }
  }

  onChange = (editorState) => {
    if (editorState) {
      this.setState({...this.state, editorState})
    }
  }

  _onInsertTextRequest = (event) => {
    let { editorState } = this.state
    let text = event.nativeEvent.text
    let position = event.nativeEvent.position

    if (!text) {
      return
    }

    if (position) {
      this.onChange(insertTextAtPosition(editorState, text, position))
    } else {
      this.onChange(insertText(editorState, text))
    }
  }

  _onBackspaceRequest = () => {
    this.onChange(backspace(this.state.editorState))
  }

  _onNewlineRequest = () => {
    this.onChange(insertNewline(this.state.editorState))
  }

  _onFocusChanged = (event) => {
    let { editorState } = this.state
    let { hasFocus } = event

    // Set hasFocus on editorState selectionState
  }

  _onSelectionChangeRequest = (event) => {
    let { startKey, startOffset, endKey, endOffset } = event

    // Set selection range on editorState selectionState
  }

  render() {
    let { editorState } = this.state

    let content = editorState.getCurrentContent()
    let selection = editorState.getSelection()
    let selectionState = {
      hasFocus: selection.getHasFocus(),
      startKey: selection.getStartKey(),
      startOffset: selection.getStartOffset(),
      endKey: selection.getEndKey(),
      endOffset: selection.getEndOffset(),
    }

    let rawContent = convertToRaw(content)

    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
        <DraftJSEditor 
          content={rawContent}
          style={styles.draftTest}
          blockFontTypes={blockFontTypes}
          inlineStyleFontTypes={inlineStyleFontTypes} 
          onInsertTextRequest={this._onInsertTextRequest}
          onBackspaceRequest={this._onBackspaceRequest}
          onNewlineRequest={this._onNewlineRequest}
          onFocusChanged={this._onFocusChanged}
          onSelectionChangeRequest={this._onSelectionChangeRequest}
          selectionState={selectionState}>
        </DraftJSEditor>
      </View>
    );
  }
}

// Uses naming from https://github.com/facebook/draft-js/blob/master/docs/Advanced-Topics-Custom-Block-Render.md
// List items not supported
// Styles property is treated as the base and more specific types are applied on top of that
// Can add other types as needed
const blockFontTypes = {
//  supportedValues: { // see https://facebook.github.io/react-native/docs/text.html
//          fontFamily: string
//            fontSize: number
//          fontWeight: enum('normal', 'bold', '100', '200', '300', '400', '500', '600', '700', '800', '900')
//           fontStyle: enum('normal', 'italic')
//         fontVariant: [enum('small-caps', 'oldstyle-nums', 'lining-nums', 'tabular-nums', 'proportional-nums')]
//       letterSpacing: number
//               color: color
//     backgroundColor: color
//             opacity: number
//           textAlign: enum('auto', 'left', 'right', 'center', 'justify')
//          lineHeight: number
//  textDecorationLine: enum('none', 'underline', 'line-through', 'underline line-through')
// textDecorationStyle: enum('solid', 'double', 'dotted', 'dashed')
// textDecorationColor: color
//    textShadowOffset: {width: number, height: number}
//    textShadowRadius: number
//     textShadowColor: color
//    allowFontScaling: boolean
//  },
  unstyled: { // No real need to use since values from styles are already used
  },
  headerOne: {
    fontSize: 22
  },
  headerTwo: {
    fontSize: 22
  },
  headerThree: {
    fontSize: 22
  },
  headerFour: {
    fontSize: 22
  },
  headerFive: {
    fontSize: 22
  },
  headerSix: {
    fontSize: 22
  },
  blockquote: {
  },
  codeBlock: {
  },
  atomic: {
  },
}

// See https://github.com/facebook/draft-js/blob/master/docs/Advanced-Topics-Inline-Styles.md
// Applied on top of font settings from blockFontTypes above
// Keep in mind that inline styles can possibly overlap, so 
//    if they override the same value it is undefined which one it will use
//    (for example UNDERLINE and STRIKETHROUGH)
const inlineStyleFontTypes = {
  ITALIC: {
    fontStyle: 'italic',
  },
  BOLD: {
    fontWeight: '600',
  },
  UNDERLINE: {
    textDecorationLine: 'underline',
  },
  STRIKETHROUGH: {
    textDecoration: 'line-through',
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  draftTest: {
    width: width,
    textAlign: 'left',
    color: '#333333',
    marginBottom: 5,
    minHeight: 35,
  }
});

AppRegistry.registerComponent('RNDraftJs', () => RNDraftJs);
