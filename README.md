# pre-commit-sign

This is a plugin for [pre-commit](https://pre-commit.com) that will sign your commit messages with a sha256 hash to allow for other systems to verify pre-commit has been run. This is not meant as a high-barrier to ensure pre-commit was run with a specific set of rules, only as a simple way to ensure committers are aware they need to run pre-commit prior to pushing.

### Usage

To sign commits as part of your pre-commit flow, just run the sign-commit hook of this repo. Note that you **must** have pre-commit installed as a commit-msg hook in order for this to run.

    - repo: https://github.com/mattlqx/pre-commit-sign
      rev: v1.1.1
      hooks:
      - id: sign-commit

If you would like to verify the signature of a commit, you can use the gem:

    require 'pre-commit-sign'
    pcs = PrecommitSign.from_message(commit_message)
    pcs.date = Time.at(12345678)
    pcs.valid_signature?
