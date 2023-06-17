#!/bin/bash

echo "BASH_ENV file: $BASH_ENV"
if [ -f "$BASH_ENV" ]; then
  echo "Exists. Sourcing into ENV"
  # shellcheck disable=SC1090
  . "$BASH_ENV"
else
  echo "Does Not Exist. Skipping file execution"
fi

if  [ "$WIZ_RESULT" = "failed" ]; then
  cat_results=$(awk '/scan analysis ready/,0' wiz_results.txt)
  cat_results=$(sed '/LOW,/,+1d;/MEDIUM,/,+1d;/INFORMATIONAL,/,+1d' <<<"$cat_results")
  WIZ_OUTPUT=$(echo "$cat_results" | sed '/Failed policy/d' | sed 's/SUCCESS: //' | sed -z 's/\n/\\n/g' | sed -z 's/\r/\\r/g')
  WIZ_OUTPUT=$(echo "$WIZ_OUTPUT" | sed 's/$/\\n/' | tr -d '\n' | sed -e 's/"/"/g' -e 's/"/"/g' | sed '$ s/\\n$//')
  echo "export WIZ_OUTPUT='$WIZ_OUTPUT'" >> "$BASH_ENV"
  echo
  echo "Successfully parsed failed Wiz results"
else
  echo
  echo "Scan was successful..nothing to parse"
fi