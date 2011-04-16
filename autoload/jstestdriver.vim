
if exists("g:loaded_jstd") || &cp
 finish
endif
let g:loaded_jstd = "v01"
let s:keepcpo      = &cpo
set cpo&vim

"run JsTestDriver
function! jstestdriver#RunTests() 
	let s:save_makeprg = &makeprg
	let s:save_errorformat = &errorformat
	set makeprg=run_jstests

"example test failure
".F
"Total 2 tests (Passed: 1; Fails: 1; Errors: 0) (3.00 ms)
  "Firefox 4.0 Mac OS: Run 2 tests (Passed: 1; Fails: 1; Errors 0) (3.00 ms)
    "CanvasUtilsTests.testB failed (2.00 ms): AssertError: this should be true expected true but was false
      "()@http://localhost:9876/test/tests/CanvasUtilsTest.js:10
      "@:0

"Tests failed: Tests failed. See log for details.
	"set efm=%f\ failed\ :\ %m:\ %m
"prepreocessed error:
"CanvasUtilsTests.testB failed. AssertError: this should be true expected true but was false|/Users/david/javascript/canvasteroids/test/tests/CanvasUtilsTest.js|10

	set efm=%m:%f:%l 
	:make!
	:cw
	let &makeprg = s:save_makeprg 
	let &errorformat = s:save_errorformat
endfunction
   

