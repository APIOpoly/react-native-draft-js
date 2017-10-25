/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
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
} from './libs/draft-js'

const DraftJSEditor = requireNativeComponent('RNTDraftJSEditor', null)

export default class RNDraftJs extends Component {
  constructor(props) {
    super(props);
    this.state = {
      editorState: EditorState.createEmpty()
    }
  }

  onChange = (editorState) => {
    this.setState({...this.state, editorState})
  }

  _onKeysPressed = (event) => {
    let keyCommands = event.nativeEvent.text

    var currentState = this.state.editorState
    for (let keyCommand of keyCommands) {
      console.log(`Command: ${keyCommand}`)
      var newState = null
      if (keyCommand.length > 1) {
        newState = RichUtils.handleKeyCommand(currentState, keyCommand)
      } else {
        newState = insertText(currentState, keyCommand)
      }

      if (newState) {
        currentState = newState
      }
    }

    this.onChange(currentState)
  }

  render() {
    let { editorState } = this.state

    let content = editorState.getCurrentContent()
    let selection = editorState.sel

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
          onKeysPressed={this._onKeysPressed}>
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
  header-one: {
    fontSize: 22
  },
  header-two: {
    fontSize: 22
  },
  header-three: {
    fontSize: 22
  },
  header-four: {
    fontSize: 22
  },
  header-five: {
    fontSize: 22
  },
  header-six: {
    fontSize: 22
  },
  blockquote: {
  },
  code-block: {
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
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  }
});

AppRegistry.registerComponent('RNDraftJs', () => RNDraftJs);
