#!/bin/bash -x
BUILD_DIR=web/out
WEB_DIR=example
rm -rf $WEB_DIR
mkdir -p $WEB_DIR
find $BUILD_DIR -maxdepth 1 -type f -print0 | xargs -0 -J % cp % $WEB_DIR
rm $WEB_DIR/*.dart

# now we need to fix up the relative URL crazy...hmm...
TO_FIND='href="..\/style.css"'
REPLACE_WITH='href="style.css"'
COMMAND=s/$TO_FIND/$REPLACE_WITH/g

TO_FIND='src="..\/dart.js"'
COMMAND2=/$TO_FIND/d

TO_FIND='type="application/dart"'
REPLACE_WITH='type="text/javascript"'
COMMAND3=s*$TO_FIND*$REPLACE_WITH*g

TO_FIND='bootstrap.dart'
REPLACE_WITH='bootstrap.dart.js'
COMMAND4=s*$TO_FIND*$REPLACE_WITH*g

# remove empty lines
COMMAND5='/^$/d'

sed -E -e $COMMAND -e $COMMAND2 -e $COMMAND3 -e $COMMAND4 -e $COMMAND5 -- $BUILD_DIR/index.html > $WEB_DIR/index.html
