# Seeding the sandbox

`seed.sh` creates the records whose GitHub API answers the
[workspace-prototype](https://github.com/laserjm/workspace-prototype) GitHub provider tests
replay ([issue 55](https://github.com/laserjm/workspace-prototype/issues/55)). It needs only `gh`,
signed in with write access:

```bash
seed/seed.sh                      # laserjm/workspace-fixtures
seed/seed.sh someone/other-repo   # another repository with a README.md
```

The Actions runs come from the repository's own workflow (here **Fixture checks**, which runs on
every push and pull request). The script adds no workflow: that would need the token's
`workflow` scope.

Each record carries the label `fixture` and one case label. A case whose label is already on a
record is skipped, so a second run changes nothing. The label goes on when the record is created,
so a run that stops halfway leaves that case half-seeded: finish it by hand, or seed a fresh
repository. An issue case can be seeded again after deleting the issue; the merged pull request
can't be seeded twice in one repository, because its files are on the default branch by then.

| Label | Record |
| --- | --- |
| `case/open-issue` | An open issue, assigned, with a Markdown body (task list, table) and three comments, one with a code block |
| `case/not-planned` | An issue with one comment, closed as **not planned** |
| `case/merged-pr` | A **merged** pull request: four changed files (three added, one modified), a `COMMENTED` review with one inline comment, a conversation comment, and on its head commit the **Fixture checks** workflow runs plus two commit statuses (`fixtures/schema` success, `fixtures/links` failure) |
| `case/draft-pr` | An open **draft** pull request with one added file |

Keep the records in these states: the recorded answers assert them. The failing
`fixtures/links` status is deliberate sample data for a red CI state, not a broken check.

The script commits through the contents API, so it needs no local checkout, and it changes no
existing file on the default branch except one added line in `README.md` (the merged pull
request's `modified` file).
