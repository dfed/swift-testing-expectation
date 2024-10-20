#!/bin/zsh

set -e

pushd $(git rev-parse --show-toplevel)

swift run --only-use-versions-from-resolved-file --package-path CLI --scratch-path .build -c release swiftformat --swiftversion 6.0 .

popd
