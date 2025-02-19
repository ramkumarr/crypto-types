#!/bin/bash

run_unix_cmd() {
  # $1 is the line number
  # $2 is the cmd to run
  # $3 is the expected exit code
  output=`$2 2>&1`
  exit_code=$?
  if [[ $exit_code -ne $3 ]]; then
    printf "failed (incorrect exit status code) on line $1.\n"
    printf "  - exit code: $exit_code (expected $3)\n"
    printf "  - command: $2\n"
    if [[ -z $output ]]; then
      printf "  - output: <none>\n\n"
    else
      printf "  - output: <starts on next line>\n$output\n\n"
    fi
    exit 1
  fi
}

printf "Testing ietf-crypto-types.yang (pyang)..."
command="pyang -Werror --canonical --ietf --max-line-length=69 -p ../ ../ietf-crypto-types\@20*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-crypto-types.yang (yanglint)..."
command="yanglint ../ietf-crypto-types\@20*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"


printf "Testing ex-crypto-types-usage.yang (pyang)..."
command="pyang -Werror --lint --max-line-length=69 -p ../ ../ex-crypto-types-usage\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ex-crypto-types-usage.yang (yanglint)..."
command="yanglint ../ex-crypto-types-usage\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"



printf "Testing ex-crypto-types-usage.xml..."
command="yanglint -t config ./ietf-origin.yang ./ietf-netconf-acm@2012-02-22.yang ../ietf-crypto-types\@20*.yang ../ex-crypto-types-usage\@*.yang ex-crypto-types-usage.xml"
#command="yanglint -m -t config -s ../ex-crypto-types-usage\@*.yang ../ietf-crypto-types\@20*.yang ./ietf-origin.yang  ex-crypto-types-usage.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"


printf "Testing ex-crypto-types-gcsr-rpc.xml..."
command="yanglint -t nc-rpc -O ex-crypto-types-usage.xml ../ietf-crypto-types\@*.yang ../ex-crypto-types-usage\@*.yang ex-crypto-types-gcsr-rpc.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ex-crypto-types-gcsr-rpc-reply.xml..."
command="yanglint -t nc-reply -O ex-crypto-types-usage.xml -R ex-crypto-types-gcsr-rpc.xml ../ietf-crypto-types\@*.yang ../ex-crypto-types-usage\@*.yang ex-crypto-types-gcsr-rpc-reply.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ex-crypto-types-ce-notification.xml..."
echo -e 'setns a=urn:ietf:params:xml:ns:netconf:notification:1.0\nsetns b=http://example.com/ns/example-crypto-types-usage\ncat //a:notification/b:asymmetric-keys' | xmllint --shell ex-crypto-types-ce-notification.xml | sed -e '/^\/.*/d' -e '/^ *$/d' > yanglint-notification.xml
command="yanglint -t notif -O ex-crypto-types-usage.xml ../ietf-crypto-types\@*.yang ../ex-crypto-types-usage\@*.yang yanglint-notification.xml"
run_unix_cmd $LINENO "$command" 0
rm yanglint-notification.xml
printf "okay.\n"


