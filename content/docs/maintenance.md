---
title: Maintainer guide
weight: 1250
---

This guide explains the tasks and responsibilities of maintainers.

## Useful links

- Projects
  - [Dependency upgrades](https://github.com/orgs/bank-vaults/projects/4)
  - [Community contributions](https://github.com/orgs/bank-vaults/projects/3)
  - [Backlog](https://github.com/orgs/bank-vaults/projects/2)

## Development

Please read the {{% xref "/docs/development.md" %}} guide.

## Keeping dependencies up-to-date

Bank-Vaults uses [Dependabot](https://github.com/dependabot) to automate dependency upgrades.
Dependabot opens pull requests in each repository for every dependency upgrade.

Maintainers should regularly review and merge these pull requests as a measurement to secure the software supply chain.

Dependency upgrades are automatically added to [this](https://github.com/orgs/bank-vaults/projects/4) project board.

In addition to keeping project dependencies up-to-date, the development environment needs to be updated from time to time.

This is currently a manual process:

1. Run `nix flake update` in the project repo
2. Run `versions` to see current versions of relevant dependencies
3. Update versions in the `Makefile` to reflect the output of the previous command
4. Commit and push changes

## Reviewing community contributions

As an Open Source project, Bank-Vaults often gets contributions from the community.
Community contributions do not have to go through our normal development process since we basically only need to review and accept/reject the changes.

Therefore, community contributions are added to a [separate project board](https://github.com/orgs/bank-vaults/projects/3).
Whenever someone outside of the maintainers submits a pull request, add that PR to the project board and adjust its status as appropriate.
