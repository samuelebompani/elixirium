# Elixirium
![tests](https://github.com/samuelebompani/elixirium/actions/workflows/ci.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/samuelebompani/elixirium/badge.svg?branch=main)](https://coveralls.io/github/samuelebompani/elixirium?branch=main)

Elixirium is an experimental blockchain prototype built in Elixir on the BEAM VM.

## Features (Current)

- Proof-of-Work mining
- Full chain validation
- Asynchronous mining using Task.Supervisor
- OTP-based architecture
- (WIP) Supervised Mempool (transaction pool)
- Deterministic async tests
- GitHub Actions CI

## Architecture

- `Chain` – maintains blockchain state
- `Block` – hashing & validation logic
- `Miner` – proof-of-work engine
- `Mempool` – pending transactions
- `Task.Supervisor` – supervised mining workers

## Status

Single-node prototype.
Networking and distributed consensus coming next.
