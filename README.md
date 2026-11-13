# Workspace fixtures

Public, synthetic GitHub data for the recorded provider tests in
[workspace-prototype](https://github.com/laserjm/workspace-prototype), seeded for
[issue 55](https://github.com/laserjm/workspace-prototype/issues/55).

The issues and pull requests here are deliberate test cases, not a project backlog.
Keep the open issue and draft pull request in their seeded states. Do not put
credentials or private work in this repository.

`samples/launch.json` and `docs/launch-checklist.md` give the merged pull request
several readable changed files. The **Fixture checks** workflow validates the JSON
on pushes and pull requests. A separate seeded commit status exercises the other
CI response read by the provider.

The downloaded API answers live beside the GitHub provider in
`workspace-prototype/src/modules/integrations/providers/github/fixtures/`.
Its README records the commands needed to capture fresh answers.

## Seeded records

| Record | Preserved case |
| --- | --- |
| [Issue #1](https://github.com/laserjm/workspace-fixtures/issues/1) | Open, assigned to `laserjm`, with three discussion comments |
| [Issue #2](https://github.com/laserjm/workspace-fixtures/issues/2) | Closed with `state_reason: not_planned` |
| [PR #3](https://github.com/laserjm/workspace-fixtures/pull/3) | Merged, four changed files, a discussion comment, a submitted comment review and an inline review comment |
| [PR #4](https://github.com/laserjm/workspace-fixtures/pull/4) | Open draft; leave it unmerged and in draft |

PR #3's head is `dba3c57ddfe47bde1c174183a4105817ed7ad658`. Its
[push workflow run](https://github.com/laserjm/workspace-fixtures/actions/runs/43411161412)
validates the sample JSON. The same commit has a successful
`fixtures/sample-status` commit status, explicitly seeded for replay tests; it is
not a second test runner. The author submitted a **COMMENTED** review to supply
sample review data; it is not an independent approval.

The workflow runs on `push` as well as `pull_request` so the Actions API can find a
run by the PR's actual `head.sha`; a pull-request event may use a merge commit.
Do not rewrite the seed branches or change these records' states. New scenarios
should use new issues or pull requests. GitHub may eventually expire run details;
the recorded JSON remains the offline source for tests.

The fixture capture in `workspace-prototype` contains 16 JSON responses and a
README with the exact refresh commands. It includes three searches, issue and PR
details, discussion and review comments, reviews, files, combined status, workflow
runs, a public repository page and the user profile with account-only fields omitted.
