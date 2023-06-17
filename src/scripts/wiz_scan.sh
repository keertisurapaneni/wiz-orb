#!/bin/bash

echo "BASH_ENV file: $BASH_ENV"
if [ -f "$BASH_ENV" ]; then
  echo "Exists. Sourcing into ENV"
  # shellcheck disable=SC1090
  . "$BASH_ENV"
else
  echo "Does Not Exist. Skipping file execution"
fi

./wizcli auth --id "${!WIZCLI_ID_VAL}" --secret "${!WIZCLI_SECRET_VAL}"
./wizcli docker scan --image "$IMAGE" --policy "$VULNERABILITY_POLICY" --policy-hits-only 2>&1 | tee wiz_results.txt || true

scan_passed=$(grep -q "Scan results: PASSED" wiz_results.txt; echo $?)
scan_failed=$(grep -q "Scan results: FAILED" wiz_results.txt; echo $?)
echo
echo "export IMAGE='$IMAGE'" >> "$BASH_ENV"

# echo "Scan passed value is ${scan_passed}"
# echo "Scan failed value is ${scan_failed}"

if [ "$scan_failed" = 0 ]; then 
  echo "Oops..scan contains critical/high vulnerabilities. Sending notification"
  echo "export WIZ_RESULT='failed'" >> "$BASH_ENV"
  exit 1
elif [ "$scan_passed" = 0 ]; then 
  echo "Yayy..no critical/high vulnerabilities. Great job"
  echo "export WIZ_RESULT='passed'" >> "$BASH_ENV"
fi