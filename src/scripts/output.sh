#!/bin/bash

echo "Wiz scan result: ${WIZ_RESULT}"
if [ "$WIZ_RESULT" = "failed" ]; then
  echo "Scan failed..exiting step with error"
  exit 1
fi