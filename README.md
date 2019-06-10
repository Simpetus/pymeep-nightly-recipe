# Conda Recipe for PyMeep Nightly Build

## Steps to update

Whenever a new official `Meep` tarball is released on GitHub, `recipe/meta.yaml` requires the following changes:

1. Increment the version number (the `version` jinja variable). The nightly build should be one minor version above the most recent official release, followed by `.dev`. For example, if the current nightly package version is `1.9.1.dev`, and a new Meep `1.10.0` is released, the the nightly package version should become `1.10.1.dev`.

2. Reset the `buildnumber` jinja variable to `0`.

3. Verify that all `build`, `host`, and `run` dependencies are up to date in the `requirements` section.

4. Verify that the build steps in `recipe/build.sh` are up to date.
