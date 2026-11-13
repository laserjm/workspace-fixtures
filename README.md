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

The `status/` folder holds a synthetic status page (seed/seed.sh).
