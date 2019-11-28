REM *** Minify js files (code) ***

java -jar yuicompressor-2.4.8.jar js/lib.js -o js/lib-min.js
java -jar yuicompressor-2.4.8.jar js/person.js -o js/person-min.js
java -jar yuicompressor-2.4.8.jar js/rankings.js -o js/rankings-min.js

COPY /b js\lib-min.js+js\person-min.js+js\rankings-min.js js\common-min.js

REM *** Minify css files ***

java -jar yuicompressor-2.4.8.jar css/main.css -o css/main-min.css

PAUSE
