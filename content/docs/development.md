---
title: Development
weight: 1180
---

This guide explains the steps and requirements for developing Bank-Vaults projects.

## Quickstart

Install [Nix](https://nixos.org/download.html):

```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Install [direnv](https://direnv.net/docs/installation.html):

```shell
curl -sfL https://direnv.net/install.sh | bash
```

Load direnv to your shell:

```shell
eval "\$(direnv hook bash)"
```

_Don't forget to add the above line to your shell rc file._

Clone a project and enter its directory, then run:

```shell
direnv allow
```

**You are ready to go!**

## Development environment

Bank-Vaults uses [Nix](https://nixos.org/) to create a portable development environment across developer machines and CI,
ensuring a certain level of reproducibility and minimizing environmental issues during development.

Follow the [official installation instructions](https://nixos.org/download.html) to download and install Nix.

_Alternatively, you can use [this](https://github.com/DeterminateSystems/nix-installer) installer by [Determinate Systems](https://github.com/DeterminateSystems)._

In addition to Nix, you also need to install [direnv](https://direnv.net/) by following the [installation instructions](https://direnv.net/docs/installation.html).

_Follow the onscreen instructions to add direnv's hook to your shell. You may also need to restart your shell._

After installing both Nix and direnv, you will be ready to develop Bank-Vaults projects.

Check out one of the repositories and run `direnv allow` upon entering the directory.
(You only need to do this the first time, and then every time the `.envrc` file in the project changes.)

Each project should have additional development information in its README, but generally,
you will find a `Makefile` in each project with the necessary targets for development.

Finally, each project contains instructions on how to develop the project _without_ using Nix.
However, these instructions are offered as a best-effort basis and may not always work, as maintainers do not test them regularly.
