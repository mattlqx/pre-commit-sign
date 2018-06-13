# pre-commit-sign

This is a plugin for [pre-commit](https://pre-commit.com) that will sign your commit messages with a sha256 hash to allow for other systems to verify pre-commit has been run. This is not meant as a high-barrier to ensure pre-commit was run with a specific set of rules, only as a simple way to ensure committers are aware they need to run pre-commit prior to pushing.
