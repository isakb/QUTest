# Test runner for phantomjs.

# Default config. Can be overridden with flags.
CONFIG =
  debug:             false
  show_colors:       true
  show_page_console: false
  show_passed_tests: false
  show_details:      true
  working_directory: '.'
  test_runner:       'test.html' # relative to working_directory

# Parse command line arguments: options for configuration, and testcases to run.
tests = []
try
  for arg in phantom.args
    m = /^--([^=]+)=(.*)/.exec(arg)
    if m
      [key, value] = m.slice(1)
      key = key?.replace(/-/g, '_')
      if CONFIG.hasOwnProperty key
        CONFIG[key] =
          if typeof CONFIG[key] is 'boolean'
            if value in ['false', '0', ''] then false else true
          else
            value
      else
        throw new Error "No such config option: #{key}"
    else if /^--/.exec(arg)
      throw new Error "Invalid argument: #{arg}"
    else
      tests.push arg
catch e
  console.error e
  console.error "Please check README for usage details."
  phantom.exit(1)

# Return a possibly (Bash) colored version of a string.
coloredStr = (color, str) ->
  if CONFIG.show_colors
    color + str + '\033[0m'
  else
    str
greenStr  = (str) -> coloredStr '\033[32m', str
redStr    = (str) -> coloredStr '\033[31m', str
yellowStr = (str) -> coloredStr '\033[33m', str
purpleStr = (str) -> coloredStr '\033[35m', str
grayStr   = (str) -> coloredStr '\033[37m', str


printTestResult = (str) ->
  matches = /\((\d+), (\d+), (\d+)\)/.exec(str)
  [failed, passed, total] = (parseInt(s, 10) for s in matches.slice(1))  if matches
  if failed? > 0
    parts = str.split('\n')
    if CONFIG.show_details
      details = '\n  ' + parts.slice(1).join('\n  ')
    else
      details = ''
    str = parts[0]
  str = if failed > 0
    redStr("[FAIL]  #{str}") + grayStr(details)
  else if total is 0
    yellowStr("[WARN] #{str}") + " <-- nothing to test"
  else if CONFIG.show_passed_tests
    greenStr "[PASS]  #{str}"
  console.log(str) if str?


waitFor = (testF, onReady, timeOut=3000) ->
  start = new Date().getTime()
  condition = false
  interval = setInterval ->
    if (new Date().getTime() - start < timeOut) and not condition
      condition = testF()
    else if not condition
      console.log "'waitFor()' timeout"
      phantom.exit(1)
    else
      onReady()
      clearInterval(interval)
  , 25


if CONFIG.debug
  console.log "Config is: " + JSON.stringify(CONFIG)
  console.log "Tests are: " + JSON.stringify(tests)

page = new WebPage()
if CONFIG.show_page_console
  page.onConsoleMessage = (msg) ->
    console.log(purpleStr(msg))

URL = "file://#{CONFIG.working_directory}/#{CONFIG.test_runner}"
console.log """If you wish to run these tests in a web browser, copy
  and go to this URL:

  #{URL}?injects=#{ encodeURIComponent(''+tests) }"""

page.open URL, (status) ->
  if status isnt 'success'
    console.error 'Unable to open test runner page.'
    console.error status
    phantom.exit 1
  else
    # _injectTests is via lib/helper.js included in test.html.
    page.evaluate "_injectTests('#{tests}')"
    waitFor ->
        page.evaluate ->
          el = document.getElementById('qunit-testresult')

          el and /completed/.test(el.innerText)

    , ->
      [text, testcases] = page.evaluate ->
        tests = document.getElementById('qunit-tests').childNodes
        texts = []
        for node in tests
          text = node.innerText
          if /Rerun\s*$/m.test(text)
            text = text.replace(/Rerun(\s*)$/m, '$1')
          texts.push text

        el = document.getElementById('qunit-testresult')
        [el.innerText, texts]

      console.log "\nTest name (failed, passed, total)"  if testcases.length
      printTestResult(tc) for tc in testcases


      re = /completed in (\d+) milliseconds\.\n(\d*) tests? of (\d*) passed, (\d*) failed\./
      matches = re.exec(text)
      [ms, passed, total, failed] = (parseInt(m, 10) for m in matches.slice(1))

      f = if failed > 0 or passed isnt total
        redStr
      else if total is 0
        yellowStr
      else
        greenStr

      console.log f "\n#{passed} / #{total} passed tests, #{failed} failed tests.  (#{ms} ms)"

      phantom.exit(if failed > 0 or total is 0 then 1 else 0)
