# Test runner for phantomjs.

# Default config. Can be overridden with flags.
CONFIG =
  debug:             false
  show_colors:       true
  show_page_console: false
  show_passed_tests: false
  show_details:      false
  working_directory: '.'
  test_page:         "test.html" # can be a full URL (file://..., or http://...); otherwise a file relative to working directory
  tests:             []
  poll_interval:     50

# Parse command line arguments: options for configuration, and testcases to run.
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
      CONFIG.tests.push arg
catch e
  console.error e
  console.error "Please check README for usage details."
  console.error "These are the possible config options with current values:"
  console.error("  --#{key}=#{val}") for own key, val of CONFIG
  phantom.exit 1

# Return a possibly (Bash) colored version of a string.
coloredStr = (color, str) ->
  if CONFIG.show_colors
    color + str + '\033[0m'
  else
    str
boldStr   = (str) -> coloredStr '\033[1m', str
greenStr  = (str) -> coloredStr '\033[32m', str
redStr    = (str) -> coloredStr '\033[31m', str
yellowStr = (str) -> coloredStr '\033[33m', str
purpleStr = (str) -> coloredStr '\033[35m', str
grayStr   = (str) -> coloredStr '\033[37m', str

symbol =
  pass: "✔"
  fail: "✘"
  warn: "•"

prettierErrorMessage = (msg) ->
  res = ''
  re = /^(\s*Died .+?: )([^$]+?) - (\{[^]+?\n    "name": ".+?"\n  \})/mg
  while m = re.exec(msg)
    base = m[1] + m[2]
    try
      details = JSON.parse(m[3])
      details.sourceURL or= '[unknown sourceURL]'
      details = "\n  - '#{details.name}' at #{details.sourceURL}:#{details.line}"
    catch e
      details = " - " + m[3]
    res += base + details + '\n'
  res

printTestResult = (str) ->
  str = '' + str
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
    redStr("[FAIL]  #{str}") + grayStr(prettierErrorMessage((details)))
  else if total is 0
    yellowStr("[WARN] #{str}") + " <-- nothing to test"
  else if CONFIG.show_passed_tests
    greenStr "[PASS]  #{str}"
  console.log(str) if str?

if CONFIG.debug
  console.log "Config is: " + JSON.stringify(CONFIG)

page = new WebPage()
page.mainStatus = ""

if CONFIG.show_page_console
  page.onConsoleMessage = (msg) ->
    console.log(purpleStr(msg))

url = CONFIG.test_page
# Check if test page url is absolute or relative (then assume file://)
if not (/^[^:]+:\/\//).test(url)
  url = "file://#{CONFIG.working_directory}/#{url}"

console.log """If you wish to run these tests in a web browser, copy
  and go to this URL:

  #{url}?injects=#{ encodeURIComponent('' + CONFIG.tests)}"""
run = ->
  page.open "#{url}?injects=#{CONFIG.tests}", (status) ->
    # Callback is called per document loading, so ignore anything past the 1st "main" document
    # see http://code.google.com/p/phantomjs/issues/detail?id=122
    return  if page.mainStatus isnt ""
    page.mainStatus = status
    if status isnt 'success'
      console.error 'Unable to open test runner page.'
      console.error status
      phantom.exit 1
    else
      coverage.isRunning = !! page.evaluate -> window.$$_1
      startTime = new Date
      page.injectJs "lib/phantomjs-console-hook.js"
      fun = ->
        messages = page.evaluate ->
          _phantomJSMessageQueue.splice(0)
        messages.forEach handlePageMessage
      page.poll = setInterval fun, CONFIG.poll_interval

handlePageMessage = (message) ->
  action = message.action || 'undefined'
  handle = pageMessageHandlers[action]
  if handle?
    handle message
  else
    console.warn "Unexpected page message received: #{JSON.stringify(message)}"

# Code coverage done with node-coverage
coverage =
  isRunning: false
  moduleCount: 0

summary =
  tests:
    total: 0
    failed: 0
    passed: 0
    warned: 0
  assertions:
    failed: 0
    passed: 0

maybeLog = (str) ->
  console.log(str)  if CONFIG.show_details

pageMessageHandlers =
  begin: (m) ->
    console.log ("BEGIN")
    phantom.exit()
    startTime = new Date

  moduleStart: (m) ->
    coverage.moduleCount += 1
    maybeLog " #{boldStr(m.name)}:"

  moduleDone: (m) ->
    coverage.moduleCount -= 1
    maybeLog ""
    if coverage.isRunning and coverage.moduleCount is 0
      coverage.timeout = setTimeout ->
        page.evaluate -> window.$$_1.submit('qutest')
        setTimeout ->
          phantom.exit 1
        , 2500
      , 1000

  testStart: (m) ->
    maybeLog "    ↪ #{m.name}"
    summary.tests.total += 1

  log: (m) ->
    if m.result
      summary.assertions.passed += 1
    else
      summary.assertions.failed += 1
    # Log a single assertion
    name = m.message or (if m.result then '' else 'NOT  ') + 'OK (unnamed assertion)'
    indent = "        "
    extra = if typeof m.expected isnt 'undefined'
      grayStr(", Expected: #{ JSON.stringify m.expected }; Actual: #{ JSON.stringify m.actual }")
    else
      ''
    str = if m.result is false
      redStr("#{symbol.fail} #{name}") + extra
    else if CONFIG.show_passed_tests
      greenStr "#{symbol.pass} #{name}"
    maybeLog(indent + str)  if str?

  testDone: (m) ->
    printCompactTestResult(m)  if not CONFIG.show_details
    if m.failed
      summary.tests.failed += 1
    else
      summary.tests.passed += 1
      if not m.total or m.total isnt m.passed
        summary.tests.warned += 1
        maybeLog yellowStr "        #{symbol.warn} No assertions?"

  done: (m) ->
    duration = new Date - page.evaluate -> QUnit.config.started
    # Give the page message poller time to finish up before exiting.
    setTimeout ->
      a = summary.assertions
      t = summary.tests
      msg = "\n#{a.passed} / #{a.passed + a.failed} assertions ok, in #{duration} ms."
      msg += "\n#{t.passed} / #{t.total} testcases passed (#{t.warned} with warnings); #{t.failed} testcases failed."

      if summary.tests.failed
        code = summary.tests.failed
        console.error redStr msg
      else if summary.tests.warned
        code = summary.tests.warned
        console.warn yellowStr msg
      else
        code = 0
        console.log greenStr msg

      phantom.exit(code)  unless coverage.isRunning

    , 2 * CONFIG.poll_interval

printCompactTestResult = (m) ->
  name = m.module + ': ' + m.name
  str = if m.failed > 0
    redStr "[FAIL] #{name}"
  else if m.total is 0
    yellowStr("[WARN] #{name}") + grayStr(" - nothing to test")
  else if CONFIG.show_passed_tests
    greenStr "[PASS] #{name}"
  console.log(str) if str?

run()
