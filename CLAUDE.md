# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Curated collection of reusable Terraform modules, grouped by provider/concern. Each leaf directory under the top-level groups (`digitalocean/`, `github/`, `k8s/`, `misc/`, `spacelift/`) is an independent module with its own `main.tf`, optional `variables.tf` / `outputs.tf`, and one or more `*.tftest.hcl` test files.

## Common commands

All commands operate on a single module (use `-chdir=<module>` from repo root, or `cd` first). The repo is not a single root configuration — there is no top-level `terraform init`.

```bash
# Format / validate (lefthook runs these on commit/push)
terraform fmt -check -recursive
terraform -chdir=<module> validate

# Run a module's full test suite (requires init first)
terraform -chdir=<module> init
terraform -chdir=<module> test

# Run a single test file
terraform -chdir=<module> test -filter=<file>.tftest.hcl

# Run a specific named run block, with verbose output
terraform -chdir=<module> test -filter=<file>.tftest.hcl -verbose
```

`.terraform.lock.hcl` is intentionally gitignored at the module level so tests pull the latest providers.

## Test architecture

Modules are tested with Terraform's native `terraform test` framework (`.tftest.hcl`). Two distinct patterns coexist, often in the same module:

1. **Mocked / plan-only tests** (e.g. `spacelift/stack/stack.tftest.hcl`, `k8s/datadog/datadog.tftest.hcl`): use `mock_provider` or `command = plan` with `override_data` to assert on resource attributes without hitting any real API. These run anywhere with no external dependencies.
2. **Live e2e tests** (filenames typically `e2e.tftest.hcl`, `kind_*.tftest.hcl`): apply against a real cluster. They embed provider blocks pointing at either:
   - `kind-kind` kubeconfig context — a local Kind cluster (used by most `k8s/*` modules and `github/arc`).
   - `live-cluster` / DigitalOcean — managed via `doctl` (used by `digitalocean/*`).

The `.github/workflows/e2e.yml` workflow detects which clusters a changed module needs by `grep`-ing for the literal strings `kind-kind` and `live-cluster` in the module dir, then conditionally provisions Kind or authenticates to DigitalOcean before running `terraform test`. **Adding a new e2e test means using these exact context strings** so the matrix picks the right setup.

If a module has a `setup.sh` next to its `.tf` files, the e2e workflow runs it before `terraform test`.

## `main_override.tf` convention

Several modules ship a gitignored `main_override.tf` (see `*_override.tf` rule in `.gitignore`). These contain **local-only provider configuration** (typically pointing `kubernetes`/`helm`/`kubectl` at `kind-kind`, or a DigitalOcean token for ad-hoc runs). They are *not* part of the module contract — when authoring a new module, expect consumers to bring their own provider config, and only commit provider blocks that belong inside `.tftest.hcl` files for tests.

## CI and release flow

- **`terraform-check.yml`** — runs `terraform fmt -check -recursive` on every push touching `*.tf`.
- **`e2e.yml`** — on PRs, uses `tj-actions/changed-files` (matrix mode) to fan out one job per changed module directory, then runs the appropriate `terraform test` against Kind / DigitalOcean as described above. SOPS-encrypted secrets are decrypted using `SOPS_AGE_KEY`.
- **`actionlint.yml`** — lints workflow files (also enforced by lefthook).
- **`release-drafter.yml`** — drafts releases. PR labels drive both categorization (`feature`/`fix`/`chore`/`dependencies`) and semver bump (`major`/`minor`/`patch`). `skip-changelog` excludes a PR. Use real labels on PRs so the release notes and version resolve correctly.

## Local hooks (lefthook)

`lefthook.yml` enforces, in order:
- pre-commit: `terraform fmt` (auto-fixes staged files), `actionlint` for workflow changes.
- pre-push: `terraform fmt -check`, `terraform validate`, `actionlint`.
- post-checkout: when a `.terraform.lock.hcl` differs between branches, runs `terraform init` automatically (rare here since locks are gitignored, but applies in test/example dirs).

`lefthook run validate-all` re-runs the full pre-push set on demand. Minimum lefthook version is 1.7.0 (uses `stage_fixed`).

## Conventions when adding/modifying modules

- Keep modules self-contained: `main.tf` plus optional `variables.tf` / `outputs.tf`. Avoid cross-module `module` references; downstream consumers compose them.
- Always add at least one mocked/plan-only `*.tftest.hcl` so the module is covered by the per-PR matrix without requiring a live cluster.
- For Kubernetes modules, follow the existing pattern: a `main_override.tf` (gitignored) with the kind provider config for local iteration, and a separate `kind_*.tftest.hcl` or `e2e.tftest.hcl` that re-declares the providers inline so CI can run it.
- The `spacelift/stack` and `spacelift/context` modules pin `terraform_version = "1.5.7"` for the *managed* stacks they create — that is the runtime version Spacelift will use, not the version this repo runs under. CI uses Terraform 1.11.

<!-- claude-remote-plugin -->
## Claude Code on the web

When running inside a Claude Code web (cloud) session (`CLAUDE_CODE_REMOTE=true`),
before acting on the user's first request, run `/claude-remote:verify` to
confirm the environment is ready (runtimes installed, services up). If
verify reports failures, do not proceed with the task — follow its
recommendation to run `/claude-remote:debug` for a full diagnosis.
