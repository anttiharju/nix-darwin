#!/usr/bin/env python3
import subprocess
import re
import sys


def run_command(cmd, return_stdout=True, silent=False):
    """Run a shell command and return stdout or success status"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip() if return_stdout else True
    except Exception:
        if not silent:
            print(f"Command error: {' '.join(cmd)}")
        return None if return_stdout else False


def get_github_chrome_tabs():
    """Get GitHub links from Chrome browser"""
    tabs = run_command(["chrome-cli", "list", "links"])
    tab_map = {}

    if not tabs:
        return tab_map

    # Extract tab IDs and URLs for GitHub tabs
    for line in tabs.splitlines():
        if "github.com" not in line:
            continue

        id_match = re.search(r"\[(\d+)\]", line)
        parts = line.split()

        if id_match and len(parts) > 1:
            tab_map[parts[1]] = id_match.group(1)

    return tab_map


def get_github_repo_url():
    """Get GitHub repository URL"""
    # Check if we're in a git repository
    if not run_command(
        ["git", "rev-parse", "--is-inside-work-tree"], return_stdout=False, silent=True
    ):
        print("Error: Not in a Git repository")
        sys.exit(1)

    # Get origin URL
    origin = run_command(["git", "remote", "get-url", "origin"])
    if not origin or "github.com" not in origin:
        print("Error: Not a GitHub repository")
        sys.exit(1)

    # Convert origin to browser URL
    if origin.startswith("git@github.com:"):
        repo_path = origin.split("git@github.com:")[1].replace(".git", "")
        return f"https://github.com/{repo_path}"
    elif origin.startswith("https://github.com/"):
        return origin.replace(".git", "")
    else:
        print("Error: Unsupported GitHub URL format")
        sys.exit(1)


def get_branch_info():
    """Get current and default branch names"""
    current = run_command(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    default_ref = run_command(["git", "rev-parse", "--abbrev-ref", "origin/HEAD"])
    default = default_ref.replace("origin/", "") if default_ref else "main"

    return current, default


def find_matching_tab(url, tab_map):
    """Find tab ID for a GitHub URL"""
    # Direct match
    if url in tab_map:
        return tab_map[url]

    # Base repo match (github.com/owner/repo)
    base_match = re.search(r"(https://github\.com/[^/]+/[^/]+)", url)
    if base_match:
        base_url = base_match.group(1)
        for tab_url, tab_id in tab_map.items():
            if base_url in tab_url:
                return tab_id

    return None


def get_pr_url(repo_url, branch):
    """Get PR URL for a branch"""
    try:
        path_parts = repo_url.split("github.com/")[1].split("/")
        owner, repo = path_parts[0], path_parts[1]

        # Check for existing PR using GitHub CLI
        pr_url = run_command(
            [
                "gh",
                "api",
                f"repos/{owner}/{repo}/pulls?head={owner}:{branch}",
                "--jq",
                ".[0].html_url",
            ]
        )

        if pr_url:
            return pr_url
    except Exception:
        pass

    # Default to pull URL if no PR found
    return f"{repo_url}/pull/{branch}"


def open_in_chrome(url, tab_id=None):
    """Open URL in Chrome, reusing tab if possible"""
    if tab_id:
        run_command(["chrome-cli", "activate", "-t", tab_id])
        run_command(["chrome-cli", "open", url, "-t", tab_id], return_stdout=False)
    else:
        run_command(["chrome-cli", "open", url], return_stdout=False)


if __name__ == "__main__":
    # Get repository info
    repo_url = get_github_repo_url()
    current_branch, default_branch = get_branch_info()

    # Get target URL based on branch
    if current_branch == default_branch:
        target_url = repo_url  # Use repo homepage for default branch
    else:
        target_url = get_pr_url(
            repo_url, current_branch
        )  # Use PR page for other branches

    # Find matching Chrome tab and open URL
    tab_map = get_github_chrome_tabs()
    tab_id = find_matching_tab(target_url, tab_map)
    open_in_chrome(target_url, tab_id)
