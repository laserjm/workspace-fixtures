#!/usr/bin/env bash
# Seeds the records the workspace-prototype GitHub provider tests replay (laserjm/workspace-prototype#55).
#
#   seed/seed.sh [owner/repo]     # default: laserjm/workspace-fixtures
#
# Needs only `gh`, signed in with write access to the repository. Every record carries the label
# `fixture` and one `case/…` label. A case whose label is already on an issue or pull request is
# skipped, so running the script again changes nothing. The label goes on when the record is
# created: a run that stops halfway leaves that case half-seeded, so fix it by hand or start over in
# a fresh repository. The merged pull request can't be seeded twice in one repository (its files
# are on the default branch by then). Nothing here touches existing files except README.md.
set -euo pipefail

repo=${1:-laserjm/workspace-fixtures}
base=$(gh api "repos/$repo" --jq .default_branch)

# --- helpers ---------------------------------------------------------------------------------

# The number of the issue or pull request carrying a case label, or nothing.
seeded() { gh api "repos/$repo/issues?labels=$1&state=all&per_page=1" --jq '.[0].number // empty'; }

# Creates a branch from the default branch's head unless it exists.
branch() {
  gh api "repos/$repo/git/ref/heads/$1" >/dev/null 2>&1 && return
  local sha
  sha=$(gh api "repos/$repo/git/ref/heads/$base" --jq .object.sha)
  gh api -X POST "repos/$repo/git/refs" -f ref="refs/heads/$1" -f sha="$sha" >/dev/null
}

# put BRANCH PATH MESSAGE < content: one commit adding or replacing a file; prints the commit's sha.
put() {
  local sha
  sha=$(gh api "repos/$repo/contents/$2?ref=$1" --jq .sha 2>/dev/null) || sha=""
  gh api -X PUT "repos/$repo/contents/$2" -f branch="$1" -f message="$3" \
    -f content="$(base64 | tr -d '\n')" ${sha:+-f sha="$sha"} --jq .commit.sha
}

# The default branch's README.md with one more line, for a `modified` file in a pull request.
readme_plus() {
  gh api "repos/$repo/contents/README.md?ref=$base" -H 'Accept: application/vnd.github.raw+json'
  printf '\n%s\n' "$1"
}

say() { printf '%-22s %s\n' "$1" "$2"; }

# --- texts -----------------------------------------------------------------------------------
# (Functions, not heredocs inside $(…): macOS's bash 3.2 cannot parse those.)

open_issue_body() {
  cat <<'MD'
The prototype needs a small public status page: which parts are up, and what happened recently.

## Scope

- [x] List the components (app, sign-in, database)
- [ ] Show the last three incidents
- [ ] Link the page from the README

| Component | Owner |
| --- | --- |
| App | Web |
| Sign-in | Platform |

_Synthetic sample data for recorded GitHub API tests._
MD
}

merged_pr_body() {
  cat <<'MD'
Adds the status page's components and recent incidents, and points the README at them.

- `status/components.json`: three components, one degraded
- `status/incidents.md`: the last two incidents
- `status/README.md` and `README.md`: where to find them

_Synthetic sample data for recorded GitHub API tests._
MD
}

readme_line='The `status/` folder holds a synthetic status page (seed/seed.sh).'

# --- labels ----------------------------------------------------------------------------------

gh label create fixture --repo "$repo" --color 5319e7 --force \
  --description "Seeded test record for workspace-prototype; keep its state" >/dev/null
for name in open-issue not-planned merged-pr draft-pr; do
  gh label create "case/$name" --repo "$repo" --color c5def5 --force \
    --description "Seeded by seed/seed.sh" >/dev/null
done

# --- case/open-issue: an open issue with a few comments --------------------------------------

n=$(seeded case/open-issue)
if [ -n "$n" ]; then
  say case/open-issue "#$n (already seeded)"
else
  url=$(open_issue_body | gh issue create --repo "$repo" --assignee @me \
    --label fixture --label case/open-issue \
    --title "Sample: publish a status page for the prototype" --body-file -)
  n=${url##*/}
  gh issue comment "$n" --repo "$repo" --body "The component list is in \`status/components.json\` once the first pull request is merged." >/dev/null
  gh issue comment "$n" --repo "$repo" --body-file - >/dev/null <<'MD'
Proposed shape for one incident:

```json
{ "id": "2026-11-01-sign-in", "component": "sign-in", "resolved": true }
```
MD
  gh issue comment "$n" --repo "$repo" --body "> Show the last three incidents

Three is enough for now; older ones can link to the history page." >/dev/null
  say case/open-issue "#$n"
fi

# --- case/not-planned: an issue closed as not planned ----------------------------------------

n=$(seeded case/not-planned)
if [ -n "$n" ]; then
  say case/not-planned "#$n (already seeded)"
else
  url=$(gh issue create --repo "$repo" --label fixture --label case/not-planned \
    --title "Sample: send status updates by SMS" \
    --body "Subscribers could get an SMS when a component goes down.

_Synthetic sample data for recorded GitHub API tests._")
  n=${url##*/}
  gh issue comment "$n" --repo "$repo" --body "Out of scope for a prototype: it needs a paid provider and phone numbers we would have to store." >/dev/null
  gh issue close "$n" --repo "$repo" --reason "not planned" >/dev/null
  say case/not-planned "#$n"
fi

# --- case/merged-pr: merged, with a review, an inline comment, several files and CI on its head -

n=$(seeded case/merged-pr)
if [ -n "$n" ]; then
  say case/merged-pr "#$n (already seeded)"
else
  b=fixtures/status-page
  branch "$b"
  put "$b" status/components.json "Add the status page components" >/dev/null <<'JSON'
{
  "components": [
    { "id": "app", "name": "App", "status": "operational" },
    { "id": "sign-in", "name": "Sign-in", "status": "degraded" },
    { "id": "database", "name": "Database", "status": "operational" }
  ]
}
JSON
  put "$b" status/incidents.md "Add the recent incidents" >/dev/null <<'MD'
# Recent incidents

- **2026-11-01, sign-in:** Keycloak restarted during a deploy; sign-in failed for six minutes.
- **2026-10-20, database:** a long migration held a lock; writes waited for two minutes.
MD
  put "$b" status/README.md "Describe the status folder" >/dev/null <<'MD'
# Status

`components.json` lists each part of the prototype and its status;
`incidents.md` lists what happened recently. Both are synthetic.
MD
  head=$(readme_plus "$readme_line" | put "$b" README.md "Point the README at the status page")
  url=$(merged_pr_body | gh pr create --repo "$repo" --base "$base" --head "$b" \
    --label fixture --label case/merged-pr \
    --title "Sample: add the status page data" --body-file -)
  n=${url##*/}
  # Two commit statuses on the head, one passing and one failing, beside the workflow's runs.
  gh api -X POST "repos/$repo/statuses/$head" -f state=success -f context=fixtures/schema \
    -f description="components.json matches the schema" \
    -f target_url="https://github.com/$repo/blob/$head/status/components.json" >/dev/null
  gh api -X POST "repos/$repo/statuses/$head" -f state=failure -f context=fixtures/links \
    -f description="1 broken link in incidents.md" \
    -f target_url="https://github.com/$repo/blob/$head/status/incidents.md" >/dev/null
  gh api -X POST "repos/$repo/pulls/$n/reviews" --input - >/dev/null <<JSON
{
  "commit_id": "$head",
  "event": "COMMENT",
  "body": "Reads well. One question on the component list.",
  "comments": [
    {
      "path": "status/components.json",
      "line": 4,
      "body": "Should a degraded component link to its incident?"
    }
  ]
}
JSON
  gh pr comment "$n" --repo "$repo" --body "The failing \`fixtures/links\` status is deliberate: it is sample data for a red CI state." >/dev/null
  # GitHub computes mergeability after the pull request opens; retry until it can merge.
  for try in 1 2 3 4 5; do
    gh pr merge "$n" --repo "$repo" --merge >/dev/null 2>&1 && break
    [ "$try" = 5 ] && { echo "could not merge #$n" >&2; exit 1; }
    sleep 3
  done
  say case/merged-pr "#$n (head $head)"
fi

# --- case/draft-pr: an open draft pull request -----------------------------------------------

n=$(seeded case/draft-pr)
if [ -n "$n" ]; then
  say case/draft-pr "#$n (already seeded)"
else
  b=fixtures/status-history
  branch "$b"
  put "$b" status/history.md "Start the incident history" >/dev/null <<'MD'
# Incident history

Older incidents move here from `incidents.md`. Not started yet.
MD
  url=$(gh pr create --repo "$repo" --base "$base" --head "$b" --draft \
    --label fixture --label case/draft-pr \
    --title "Sample: keep older incidents on a history page" \
    --body "Work in progress: the history page that the status page links to.

_Synthetic sample data for recorded GitHub API tests._")
  say case/draft-pr "#${url##*/}"
fi
