#!/usr/bin/env python3
import subprocess
import sys


def run(cmd, get_output=True, silent=False):
    """Run command and return output or status"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip() if get_output else True
    except Exception:
        if not silent:
            print(f"Error: {' '.join(cmd)}")
        return None if get_output else False


def get_repo_info():
    """Get repository URL and branch information"""
    # Verify git repo
    if not run(
        ["git", "rev-parse", "--is-inside-work-tree"], get_output=False, silent=True
    ):
        print("Error: Not in a Git repository")
        sys.exit(1)

    # Get origin URL and convert to browser URL
    origin = run(["git", "remote", "get-url", "origin"])
    if not origin or "github.com" not in origin:
        print("Error: Not a GitHub repository")
        sys.exit(1)

    if origin.startswith("git@github.com:"):
        repo_url = f"https://github.com/{origin.split('git@github.com:')[1].replace('.git', '')}"
    elif origin.startswith("https://github.com/"):
        repo_url = origin.replace(".git", "")
    else:
        print("Error: Unsupported GitHub URL format")
        sys.exit(1)

    # Get branch information
    current = run(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    default_ref = run(["git", "rev-parse", "--abbrev-ref", "origin/HEAD"])
    default = default_ref.replace("origin/", "") if default_ref else "main"

    return repo_url, current, default


def get_target_url(repo_url, branch, is_default_branch):
    """Get target URL based on branch"""
    if is_default_branch:
        return repo_url

    # For feature branches, get PR URL
    try:
        owner, repo = repo_url.split("github.com/")[1].split("/")[:2]
        pr_url = run(
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

    return f"{repo_url}/pull/{branch}"


def find_github_tab(url):
    """Find matching Chrome tab for GitHub URL"""
    tabs = run(["chrome-cli", "list", "links"])
    if not tabs:
        return None

    # Build map of GitHub tabs
    tab_map = {}
    for line in tabs.splitlines():
        if "github.com" not in line:
            continue

        # Parse line format: [tab_id] url
        parts = line.split(None, 1)  # Split on first whitespace
        if len(parts) == 2:
            tab_id_part = parts[0]
            url_part = parts[1]

            # Extract tab ID from [123] format
            if tab_id_part.startswith("[") and tab_id_part.endswith("]"):
                tab_id = tab_id_part[1:-1]  # Remove brackets
                tab_map[url_part] = tab_id

    # Try direct match
    if url in tab_map:
        return tab_map[url]

    # Try base repo match - using string operations
    url_parts = url.split("/")
    if len(url_parts) >= 5 and "github.com" in url_parts[2]:
        # Extract base repo URL (https://github.com/owner/repo)
        base_url = "/".join(url_parts[:5])
        for tab_url, tab_id in tab_map.items():
            if base_url in tab_url:
                return tab_id

    return None


def open_in_browser(url, tab_id=None):
    """Open URL in Chrome browser"""
    if tab_id:
        run(["chrome-cli", "activate", "-t", tab_id])
        run(["chrome-cli", "open", url, "-t", tab_id], get_output=False)
    else:
        run(["chrome-cli", "open", url], get_output=False)


if __name__ == "__main__":
    # Get repository and branch info
    repo_url, current_branch, default_branch = get_repo_info()

    # Determine target URL
    target_url = get_target_url(
        repo_url, current_branch, current_branch == default_branch
    )

    # Find and open in browser
    tab_id = find_github_tab(target_url)
    open_in_browser(target_url, tab_id)
