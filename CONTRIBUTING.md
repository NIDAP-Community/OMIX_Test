# Contributing

## Adding or Updating a Module

1. Work inside `modules/<module>/`.
2. Keep shared helper code in `core/` only when multiple modules need it.
3. Declare the module's starter environment in `module.yml`.
4. Keep module tests local to `modules/<module>/tests/`.
5. Update the module `CHANGELOG.md`.

## Adding a Starter Environment

1. Add a folder under `starter-environments/`.
2. Include a `Dockerfile`, `renv.lock`, and `README.md`.
3. Update `.github/workflows/starter-environments.yml`.
4. Update the starter environment table in the root `README.md`.

## Repository Rule of Thumb

Modules are self-contained capsules:

```text
Code + Environment + Tests + Container Layer + One Code Ocean Capsule
```

