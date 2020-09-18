#!/bin/bash

# non dovrebbe servire . cfg/natilusEnv.ksh

CHAR_TEN=$'\010'
MEW_SEPARATOR=$'\031'
DOUBLE_QUOTES='"'
OLD_SEPARATOR=';'

while read actualLine
do

  appString=$actualLine

  underQuotes=false
  exitLine=""

  for (( i=0; i<${#appString}; i++ ))
  do
    actChar=${appString:$i:1}

    if [[ "$actChar" = "$DOUBLE_QUOTES" ]]
    then

      if [[ "$underQuotes" = true ]]
      then

        underQuotes=false

      else

        underQuotes=true
      fi

    elif [[ "$actChar" =~ "$OLD_SEPARATOR" ]]
    then

      if [[ "$underQuotes" = false ]]
      then

        # exitLine+=`echo $oneC|`sed -e 's/./\x01F/'`
        exitLine+=$NEW_SEPARATOR

      else

        exitLine+=$actChar
      fi

    elif [[ "$actChar" != "$CHAR_TEN" ]]
    then

      exitLine+=$actChar
else
echo "char 10"
    fi

  done

  echo $exitLine

done
