#!/bin/bash -x
BUILD_DIR=web/out
WEB_DIR=example/component
rm -rf $WEB_DIR
mkdir -p $WEB_DIR
find $BUILD_DIR -maxdepth 1 -type f -print0 | xargs -0 -J % cp % $WEB_DIR
rm $WEB_DIR/*.dart

# now we need to fix up the relative URL crazy...hmm...
TO_FIND='href="..\/style.css"'
REPLACE_WITH=href="style.css"
COMMAND=s/$TO_FIND/$REPLACE_WITH/g
sed -e $COMMAND $BUILD_DIR/index.html > $WEB_DIR/index.html
