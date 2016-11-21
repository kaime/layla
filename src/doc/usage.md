# Usage

## From the command-line

If you have installed Layla globally using NPM, you should have a `layla` command available. Enter `layla -h` to see available options:

~~~
Usage:
  layla [options] file...|< [>]

Options:
  -u, --use <plugin>      Use a plugin
  -o, --out-file <file>   Write compiled code to a file instead of printing it
  -i, --interactive       Start an interactive console
  -c, --colors            Use colors on the output
  -C, --no-colors         Don't use colors on the output
  -v, --version           Print out Layla version
  -h, --help              Show this help
~~~

Run `layla` followed by one or more file names and they all will be compiled into a single CSS document and output to `stdout`:

~~~
$ layla styles.lay > styles.css
~~~

Or use the `--out-file` option to write compiled CSS to a file instead of printing it to `stdout`:

~~~
$ layla base.lay forms.lay -o styles.css
~~~

If you don't provide at least one file, Layla will try to read from `stdin`:

~~~
$ cat styles.lay | layla > styles.css
~~~

Load one or more plugins before compilation with the `--use` option:

~~~ sh
$ layla --use "css/extras,npm" base.lay frontend.lay
~~~

The interactive mode allows you to play around with layla from the command line:

~~~ sh
$ layla --interactive
~~~

During an interactive session, the following control sequences are available:

- <kbd>ctrl</kbd> + <kbd>C</kbd> discards current line and start a new one.
- <kbd>ctrl</kbd> + <kbd>L</kbd> clears the screen.
- <kbd>ctrl</kbd> + <kbd>D</kbd> exits.

You can load plugins and import external `.lay` files before the prompt:

~~~ sh
$ layla -i -u npm -u css/extras mixins.lay
~~~

Use the `--colors` or `--no-colors` options to enable or disable ANSI colors on the output. By default, Layla will enable colors only in the interactive mode, if the console supports them.

~~~ sh
$ layla --interactive --no-colors
~~~

Type `layla --version` to print out installed Layla version.

~~~
$ layla version
0.0.0
~~~

## On the browser

You can include Layla on your page to compile your code directly on the client side. You can use this method to develop or play around with Layla, but **don't use it in production** unless you have a good reason:

- The browserified version of Layla is quite a big piece of JS to download.
- Client-side compilation can become *very* slow as your codebase grows.
- All imports are made *synchronously*, so the whole stylesheets can take a while to download if they are split in many files.
- Until the compilation is completed, an uncharming [FOUC](https://en.wikipedia.org/wiki/Flash_of_unstyled_content) will frequently appear.

Include the browserified bundle `layla.min.js` in your HTML:

~~~ html
<script src="/path/to/layla.min.js" type="text/javascript"></script>
~~~

Now you can write `<style>` tags with Layla code and `<link>` to external `.lay `files. Just make sure you set the `type` attribute to `text/lay`:

~~~ html
<html>
  <head>
    <script src="/path/to/layla.min.js"></script>
    <link rel="stylesheet/layla" type="text/lay" href="./config.lay">
    <style type="text/lay">
      $background |= white

      body {
        background-color: $background
      }
    </style>
  </head>
</html>
~~~

> Use the `stylesheet/layla` (or any other invalid) `rel` value in `<link>` tags to prevent some browsers to download the files twice.

All code will be compiled on the same context and added to the document with a standard `<style type="text/css>` element: in the snippet above, the `$background` variable could have been declared in the external `config.lay` file.

## With gulp

## With Grunt
