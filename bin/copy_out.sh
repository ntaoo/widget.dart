#!/bin/bash -x
BUILD_DIR=web/out
WEB_DIR=example
rm -rf $WEB_DIR
mkdir -p $WEB_DIR
find $BUILD_DIR -maxdepth 1 -type f -print0 | xargs -0 -I % cp % $WEB_DIR
rm $WEB_DIR/*.dart

# Since we're using the JS file directly, remove the dart.js helper
TO_FIND='packages\/browser\/dart.js"'
COMMAND2=/$TO_FIND/d

# Remove imports from output
# DARTBUG, WEB-UI BUG: https://github.com/dart-lang/web-ui/issues/514
TO_FIND='rel="import"'
COMMAND3=/$TO_FIND/d

# fix the type of the script from dart to js
TO_FIND='type="application/dart"'
REPLACE_WITH='type="text/javascript"'
COMMAND4=s*$TO_FIND*$REPLACE_WITH*g

# change reference to dart file to use the corresponding js file
TO_FIND='bootstrap.dart'
REPLACE_WITH='bootstrap.dart.js'
COMMAND5=s*$TO_FIND*$REPLACE_WITH*g

# remove empty lines
COMMAND6='/^[[:blank:]]*$/d'

sed -E -e $COMMAND2 -e $COMMAND3 -e $COMMAND4 -e $COMMAND5 -e $COMMAND6 -- $BUILD_DIR/index.html > $WEB_DIR/index.html
