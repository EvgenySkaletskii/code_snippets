# Branching

## Master branch
- Current production state.
- All feature branches should be created from the master branch.
- All PRs should be targeted to the master branch.
- **WE DO NOT MERGE PRs into the master branch.**

## QA branch
- A branch that is deployed to QA env and contains a number of features that should be reviewed/tested by QA.
- To deploy your feature to QA env you should merge your feature branch into the qa branch and start deployment from the qa branch.
- **DO NOT create feature branches from the qa branch.**
- **DO NOT create release branches from the qa branch cause it can contain features that SHOULD NOT be released.**

## Feature and bugfix branches
- Branches for developing features/bugfixes.
- It should be created from the master branch.
- It should be targeted to the master branch.
- Merge your feature/bugfix branch into qa for further deployment to QA env.

### Naming conventions:
- `feature/<azure-ticket-number>-<short title>`
  - e.g. `feature/9238-create-default-b2b-tiers`
- `bugfix/<azure-ticket-number>-<short title>`
  - e.g. `bugfix/8234-fix-trial-plans`

## Release/hotfix branches
- A branch that contains features that should be released to production.
- It should be created from the master branch.
- All features that should be released should be merged into a release branch.

### Naming conventions:
- `release/<name-of-release>` can be determined from the main feature name that should be released.
- Major version 1.1.0 → 2.0.0 - when releasing major features like B2B2C.
- Minor version 2.0.0 → 2.1.0 - when releasing minor features or bugfixes.
- Hotfix version 2.1.0 → 2.1.1 - when releasing a hotfix.

# Transition flow
- Rename staging to master - DONE
- Remove production branch - DONE

# Pull Requests

## Naming conventions for commits
- `[<Azure ticket number>] <ticket summary>`

### Azure ticket number
- 92345

### Short ticket summary
- WRONG - Added tests, Adding tests.
- RIGHT - Add tests.

#### Example
- `[92345] Update trial plans`
- `[12345] Add new promo codes to admin panel`

## Naming conventions for Pull Requests (PRs)
- `[<Azure ticket number>] <ticket title>`
- Could be prepended with `[WIP]` tag in case it is still in progress.
- Add description for PR.
- Any info that can help teammates get into your changes quickly.
- Any deployment notes such as migrations or scripts SHOULD BE ADDED HERE.

# Environments

## Production
- Client web app with the current release version.

## Staging
- Env for testing upcoming release in isolation.

## QA
- Env for feature testing.

# Developers workflow

## Creating a new feature branch
- Create a branch from the master branch with `git checkout -b feature/<your-ticket-number><short-description>`.
- After completing development open a PR to master branch `git push origin feature/<your-ticket-number><short-description>`.
- Never merge features directly into the master branch.

## Deploying features on QA for testing
- Checkout to the qa branch `git checkout qa`.
- Pull the qa branch from the remote to get the latest updates `git pull origin qa`.
- Merge your feature into the qa branch `git merge feature/<your-ticket-number><short-description>`.
- Push the updated qa branch to the remote `git push origin qa`.
- Start the deployment process (from qa branch) with `cap qa deploy`.

## Preparing release to push it to staging/production
- When releasing multiple features that should be gathered together.
- Checkout to the master branch `git checkout master`.
- Pull the master branch from the remote to get the latest updates `git pull origin master`.
- Create a release branch `git checkout -b release/x.y.z` follow the release naming conventions to determine the new version.
- Change the major/minor release version with rake task `bundle exec rake version:update VERSION=x.y.z` e.g., `bundle exec rake version:update VERSION=1.7.0` (version is stored in config/initializers/version.rb). Then commit the updated release version.
- Gather features that should be released and merge them into the release branch.
- N times do `git merge feature/<feature-for-release>`.
- In case the release should be verified on staging env - deploy the release branch on staging `cap staging deploy` (from the release branch).
- In case the release is verified - merge the release branch to master.
- `git checkout master`.
- `git pull origin master`.
- `git merge release/<name-of-release>`.
- Start deploy to production (from the master branch).
- `git push origin master`.
- `git push <client-remote> master`.
- `cap production deploy`.
- Delete feature branches from GitLab that were released.

## Creating a hotfix
- Checkout to the master branch `git checkout master`.
- Pull the master branch from the remote to get the latest updates `git pull origin master`.
- Create a hotfix branch `git checkout -b hotfix/<name-of-hotfix>`.
- Change the hotfix release version with rake task `bundle exec rake version:update VERSION=x.y.z` e.g., `bundle exec rake version:update VERSION=1.7.1` (version is stored in config/initializers/version.rb, follow the release naming conventions). Then commit the updated release version.
- Make changes for the hotfix and commit them.
- In case the hotfix should be verified on staging env - deploy the hotfix branch on staging `cap staging deploy` (from the hotfix branch).
- In case the hotfix is verified - merge the hotfix branch to master.
- `git checkout master`.
- `git pull origin master`.
- `git merge hotfix/<name-of-hotfix>`.
- Start deploy to production (from the master branch).
- `git push origin master`.
- `git push <client-remote> master`.
- `cap production deploy`.

# FAQ
TBD
