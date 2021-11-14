#!/usr/bin/env bash
set -e

while getopts t:r:b:v:c: flag
do
    case "${flag}" in
        t) test=${OPTARG};;
        r) runs=${OPTARG};;
        b) build=${OPTARG};;
        c) config=${OPTARG};;
    esac
done

runs=$([ -z "$runs" ] && echo "10" || echo "$runs")
build=$([ -z "$build" ] && echo "1" || echo "$build")
config=$([ -z "$config" ] && echo "./config/dev.json" || echo "$config")
skip_build=$([ "$build" == "0" ] && echo "1" || echo "0")

[[ $SKIP_MAINNET_CHECK || "$ETH_RPC_URL" && "$(seth chain)" == "ethlive" ]] || { echo "Please set a mainnet ETH_RPC_URL"; exit 1; }

# Wednesday, October 27, 2021 12:58:18 PM UTC
export DAPP_TEST_TIMESTAMP=1636858937
export DAPP_TEST_NUMBER=13611498

export DAPP_SOLC_VERSION=0.6.12
# export DAPP_SRC="contracts"
# export DAPP_LINK_TEST_LIBRARIES=0
# export DAPP_STANDARD_JSON=$config
export DAPP_TEST_ADDRESS=0xfeb4acf3df3cdea7399794d0869ef76a6efaff52 

if [ "$skip_build" = "1" ]; then export DAPP_SKIP_BUILD=1; fi

if [ -z "$test" ]; then match="[contracts/test/*.t.sol]"; dapp_test_verbosity=2; else match=$test; dapp_test_verbosity=2; fi

echo LANG=C.UTF-8 dapp test --match "$match" --rpc-url "$ETH_RPC_URL" --verbosity $dapp_test_verbosity --fuzz-runs $runs

LANG=C.UTF-8 dapp test --match "$match" --rpc-url "$ETH_RPC_URL" --verbosity $dapp_test_verbosity --fuzz-runs $runs #--cache cache/cts-cache
