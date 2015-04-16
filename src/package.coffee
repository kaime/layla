module.exports =
  name:             "layla"
  version:          require "./version"
  description:      ""
  author:           "Jaume Alemany <jaume@krokis.com>"
  contributors:     []
  license:          "BSD"
  readmeFilename:   "Readme.md"
  keywords:         ["css"]
  repository:
    type:           "git"
    url:            "https://github.com/krokis/layla.git"

  directories:      {}
  main:             "./index.js"

  scripts:
    test:           """
                    node ./node_modules/mocha/bin/mocha \
                      --require should \
                      --compilers coffee:coffee-script/register \
                      --slow 500 \
                      --reporter spec \
                      --inline-diffs \
                      src/test/**/index.coffee
                    """
    start:          "node ./bin/layla -i"

  bin:
    layla:          "./bin/layla"

  browser:          "./dist/layla.min.js"

  dependencies:
    "big.js":        "^2.5.1"

  devDependencies:
    "coffee-script": "~1.8.0"
    "commonmark":    "~0.12.0"
    "pascal-case":   "^1.1.0"
    "snake-case":    "^1.1.1"
    "title-case":    "^1.1.0"
    "camel-case":    "^1.1.1"
    "param-case":    "^1.1.1"
    "browserify":    "^6.1.0"
    "coffeeify":     "~1.0.0"
    "uglify-js":     "^2.4.17"
    "mkdirp":        "^0.5.0"
    "should":        "~4.1.0"
    "mocha":         "~2.2.0"
    "plist":         "^1.1.0"
    "cson":          "^1.6.1"
    "del":           "~1.1.0"
