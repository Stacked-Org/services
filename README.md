# New Package for Stacked

Created from the `package-template`.

After creating the repository, proceed with the following instructions:

- Update the repository settings to adhere to the conventions:
  - General:
    - No Wikis
    - No Issues
    - No Sponsorships
    - Preserve this repository
    - No Discussions
    - No Projects
    - Don't allow merge commits
    - Allow squash merging with default commit message set to "Default to pull request title and commit details"
    - Don't allow rebase merging
    - Always suggest updating pull requests
    - Allow auto-merge
    - Automatically delete head branches
  - Branch protection rule (`main`):
    - Require a pull request before merging
    - Dismiss stale pull request approvals when new commits are pushed
    - Allow specified actors to bypass required pull requests -> `Dane Mackier` (or whoever is the current owner of the personal access token in the organization secrets `REPO_DEPLOYMENT_TOKEN`)
    - Require status checks to pass before merging
    - Require branches to be up to date before merging
    - Add status check `Linting and Testing` (to select this, the workflow must have been run at least once. This can be done manually since the workflow has "workflow_dispatch" as a trigger)
    - Require conversation resolution before merging
    - Require linear history
- Create the flutter package with `flutter create -t package --project-name NAME .`
- Update the content in the `README` file.
