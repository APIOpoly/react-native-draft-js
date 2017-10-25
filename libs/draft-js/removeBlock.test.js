import test from 'ava'
import {rawToEditorState} from './rawConversions'
import removeBlock from './removeBlock'

test('removes image block that is first', (t) => {
  const es = rawToEditorState({
    "blocks" : [
      {
        "data" : {
          "url" : "files/1.jpg",
          "type" : "image"
        },
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "atomic",
        "text" : " ",
        "key" : "1"
      },
      {
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "unstyled",
        "text" : "This is my text",
        "key" : "2"
      },
      {
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "unstyled",
        "text" : "My awesome text",
        "key" : "3"
      },
    ],
    "entityMap": {}
  })
  const newEs = removeBlock(es, '1')
  t.is(newEs.getCurrentContent().getBlocksAsArray().length, 2)
  t.is(newEs.getCurrentContent().getBlockForKey('2').getText(), 'This is my text')
  t.is(newEs.getCurrentContent().getBlockForKey('3').getText(), 'My awesome text')
})

test('removes image block that is second', (t) => {
  const es = rawToEditorState({
    "blocks" : [
      {
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "unstyled",
        "text" : "This is my text",
        "key" : "1"
      },
      {
        "data" : {
          "url" : "files/1.jpg",
          "type" : "image"
        },
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "atomic",
        "text" : " ",
        "key" : "2"
      },
      {
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "unstyled",
        "text" : "My awesome text",
        "key" : "3"
      },
    ],
    entityMap: {}
  })
  const newEs = removeBlock(es, '2')
  t.is(newEs.getCurrentContent().getBlocksAsArray().length, 2)
  t.is(newEs.getCurrentContent().getBlockForKey('1').getText(), 'This is my text')
  t.is(newEs.getCurrentContent().getBlockForKey('3').getText(), 'My awesome text')
})

test('removes image block that is last', (t) => {
  const es = rawToEditorState({
    "blocks" : [
      {
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "unstyled",
        "text" : "This is my text",
        "key" : "1"
      },
      {
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "unstyled",
        "text" : "My awesome text",
        "key" : "2"
      },
      {
        "data" : {
          "url" : "files/1.jpg",
          "type" : "image"
        },
        "entityRanges" : [
        ],
        "inlineStyleRanges" : [
        ],
        "depth" : 0,
        "type" : "atomic",
        "text" : " ",
        "key" : "3"
      }
    ],
    entityMap: {}
  })
  const newEs = removeBlock(es, '3')
  t.is(newEs.getCurrentContent().getBlocksAsArray().length, 2)
  t.is(newEs.getCurrentContent().getBlockForKey('1').getText(), 'This is my text')
  t.is(newEs.getCurrentContent().getBlockForKey('2').getText(), 'My awesome text')
})
