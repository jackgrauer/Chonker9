#!/bin/bash
# Fix Arrow-chrono conflict
cd ~/.cargo/registry/src/index.crates.io-*/arrow-arith-51.0.0/src/ 2>/dev/null || exit 1
sed -i.bak 's/d.quarter()/chrono::Datelike::quarter(\&d)/g' temporal.rs
echo "⚔️ Arrow conflict slashed!"
