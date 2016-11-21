fs           = require 'fs'
path         = require 'path'
markdownlint = require 'markdownlint'
rules        = require '../../markdownlint.json'

describe 'Markdown', ->
  base_dir = fs.realpathSync "#{__dirname}/../.."

  doFile = (file) ->
    it (file.substr base_dir.length + 1), ->
      options =
        resultVersion: 1
        files: file
        config: rules

      res = markdownlint.sync options

      if res
        for f of res
          if typeof res[f] is 'object'
            err = res[f][0]

            message = """
              #{err.errorDetail} @ \
              #{file}:#{err.lineNumber}
              """

            throw new Error message

  doDir = (dir) ->
    for name in fs.readdirSync dir
      if name[0] != '.'
        file = path.join dir, name
        if st = fs.statSync file
          if st.isDirectory()
            doDir file
          else if st.isFile() and name.match /\.md$/
            doFile file
        else
          throw new Error "Could not stat file #{file_path}"

  doDir base_dir
