#!/usr/bin/env bash

# A hook script to verify commit message format. Called by "git commit"
# with one argument, the name of the file that has the commit message.
# The hook exits with non-zero status after issuing an appropriate
# message if it wants to stop the commit. The hook is allowed to edit
# the commit message file.

COMMIT_FILE="$1"
COMMIT_SUBJECT=$(head -n 1 "$1")
COMMIT_SUBJECT_LENGTH=$(echo -n "$COMMIT_SUBJECT" | wc -c)
COMMIT_SUBJECT_LAST_CHAR=$(echo -n "$COMMIT_SUBJECT" | tail -c 1)

if [ "$COMMIT_SUBJECT_LENGTH" -gt "50" ]; then
  echo >&2 "Error: Commit subject should not exceed 50 characters"
  exit 1
fi

if [ "$COMMIT_SUBJECT_LAST_CHAR" = "." ]; then
  echo >&2 "Error: Commit subject should not end with a period"
  exit 1
fi

if [[ "$COMMIT_SUBJECT" =~ ^[a-zA-Z0-9_]+:\ .*$ ]]; then
  COMMIT_SUBJECT_BODY=$(echo -n "$COMMIT_SUBJECT" | cut -d ' ' -f 2-)
else
  COMMIT_SUBJECT_BODY="$COMMIT_SUBJECT"
fi

COMMIT_SUBJECT_BODY_FIRST_CHAR=$(echo -n "$COMMIT_SUBJECT_BODY" | head -c 1)
if [[ ! "$COMMIT_SUBJECT_BODY_FIRST_CHAR" =~ [A-Z] ]]; then
  echo >&2 "Error: Commit subject should be capitalized"
  exit 1
fi

while read -r LINE; do
  if [ "${LINE::1}" = "#" ]; then
    break
  fi

  LINE_LENGTH=$(echo -n "$LINE" | wc -c)
  if [ "$LINE_LENGTH" -gt "72" ]; then
    echo >&2 "Error: Commit message body should wrap at 72 characters"
    exit 1
  fi
done < "$COMMIT_FILE"
