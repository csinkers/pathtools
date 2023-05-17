:%v/name="\(Duration\)\|\(TextData\)/d
:%s/^\s*<Column id="[^"]*" name="[^"]*">\(.*\)<\/Column>$/\1/
:%s/&gt;/>/g
:%s/^\(.*\)\n\(\d*\)$/\2,\1
:%g/^0,/d
:%!sort
:%s/&lt;/</g
:%s/&gt;/>/g
:%s/&amp;/&/g
:%s/&apos;/'/g
:set syntax=sql
:set fileencoding=utf-8
:sav %sql

