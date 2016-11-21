# 3rd party
fs       = require 'fs'
path     = require 'path'
mark     = require 'commonmark'
{expect} = require 'chai'

# Main lib
Layla = require '../../lib'

describe 'Docs', ->

  base_dir = fs.realpathSync "#{__dirname}/../../doc"

  doFile = (file) ->
    name = file.substr base_dir.length + 1
    describe name, ->

      doc = null

      it 'Is valid Markdown', ->
        text = fs.readFileSync file, 'utf8'
        parser = new mark.DocParser
        doc = parser.parse text
        expect(doc).to.be.an.Object

      it 'Contains only code examples that actually work', ->
        last = null

        doNode = (node) ->
          if node.t is 'FencedCode'
            if last?.lang is 'lay' and node.info is 'css'
              expect(last.text).not.to.be.empty
              expect(node.string_content).not.to.be.empty
              source = last.text
              expected = node.string_content
              layla = new Layla
              actual = layla.compile source
              expect(actual).to.equal expected
            else
              last =
                lang: node.info
                text: node.string_content

          if node.children?
            doNode child for child in node.children

        doNode doc

      it 'Has no dead links'

  doDir = (dir) ->
    for name in fs.readdirSync dir
      if name[0] != '.'
        file = path.join dir, name
        if st = fs.statSync file
          if st.isDirectory()
            doDir file
          else if st.isFile() and name.match /.md$/
            doFile file
        else
          throw new Error "Could not stat file #{file_path}"

  doDir base_dir
