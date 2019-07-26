#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for testSuite in $CURRENT_DIR/tests/suites/* ; do
    $testSuite
done
