#!/usr/bin/env bash
set -euo pipefail

# Git PR Chrome:
# Use chrome-cli to easily access GitHub PRs in Google Chrome without polluting tabs
# $ chrome-cli list links
# [1641357594] https://calendar.google.com/calendar/u/0/r
# [1641357598] https://smartlyio.atlassian.net/jira/software/c/projects/DOPS/boards/580?assignee=712020%3A98d9cca5-ecc5-4aa3-b20b-1df77656ed34&isEligibleForUserSurvey=true
# [1641357572] https://github.com/smartlyio/typescript-nodejs-smartly-starter
# [1641357579] https://github.com/anttiharju/nix-darwin

chrome-cli list links
