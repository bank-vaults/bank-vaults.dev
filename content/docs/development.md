---
title: Development
weight: 1300
---

This guide explains the requirements for developing Bank-Vaults projects.

## Requirements

Each Bank-Vaults project is a Go module with its own `Makefile`. The Makefile is the entry point for all common development tasks (building, testing, linting, generating code, etc.).

Common prerequisites across the projects:

- A recent [Go toolchain](https://go.dev/dl/) (see each project's `.go-version` file for the exact version).
- [Docker](https://docs.docker.com/get-docker/) for building container images and running integration tests.
- [`kind`](https://kind.sigs.k8s.io/) for running Kubernetes-based acceptance tests locally.

Additional tools (`kubectl`, `helm`, `kustomize`, `controller-gen`, `golangci-lint`, etc.) are installed automatically into the project's `bin/` directory the first time you run `make deps`.

## Getting started

1. Clone the project you want to work on, for example:

   ```shell
   git clone https://github.com/bank-vaults/vault-operator.git
   cd vault-operator
   ```

2. Install local dependencies:

   ```shell
   make deps
   ```

3. Run the test suite:

   ```shell
   make test
   ```

4. See `make help` for the full list of available targets, and refer to the project's `README.md` and `CONTRIBUTING.md` for project-specific guidance.
