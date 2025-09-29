#!/usr/bin/env python3
import subprocess
import re
import sys


def run_command(cmd, return_stdout=True, silent=False):
    """Run a shell command and return stdout or success status"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip() if return_stdout else True
    except Exception as e:
        if not silent:
            print(f"Command error ({' '.join(cmd)}): {e}")
        return None if return_stdout else False


def get_github_chrome_tabs():
    """Get GitHub links from Chrome browser"""
    result = run_command(["chrome-cli", "list", "links"])
    tab_map = {}

    if result:
        for line in result.splitlines():
            if "github.com" in line:
                id_match = re.search(r"\[(\d+)\]", line)
                parts = line.split()

                if id_match and len(parts) > 1:
                    tab_map[parts[1]] = id_match.group(1)

    return tab_map


def get_github_info():
    """Get GitHub repository and branch information"""
    # Check if we're in a git repository
    if not run_command(
        ["git", "rev-parse", "--is-inside-work-tree"], return_stdout=False, silent=True
    ):
        print("Error: Not in a Git repository.")
        sys.exit(1)

    # Get origin URL
    origin = run_command(["git", "remote", "get-url", "origin"])
    if not origin or "github.com" not in origin:
        print("Error: Not a GitHub repository.")
        sys.exit(1)

    # Convert origin to browser URL
    if origin.startswith("git@github.com:"):
        repo_path = origin.split("git@github.com:")[1].replace(".git", "")
        repo_url = f"https://github.com/{repo_path}"
    elif origin.startswith("https://github.com/"):
        repo_url = origin.replace(".git", "")
    else:
        print("Error: Unsupported GitHub URL format.")
        sys.exit(1)

    # Get branch info in one call
    current_branch = run_command(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    default_branch_ref = run_command(
        ["git", "rev-parse", "--abbrev-ref", "origin/HEAD"]
    )
    default_branch = (
        default_branch_ref.replace("origin/", "") if default_branch_ref else "main"
    )

    return repo_url, current_branch, default_branch


def find_matching_tab(target_url, tab_map):
    """Find tab ID for a GitHub URL"""
    # Direct match
    if target_url in tab_map:
        return tab_map[target_url]

    # Base repo match
    base_match = re.search(r"(https?://github\.com/[^/]+/[^/]+)", target_url)
    if base_match:
        base_url = base_match.group(1)
        for url, tab_id in tab_map.items():
            if base_url in url:
                return tab_id

    return None


def get_target_url(repo_url, current_branch, default_branch):
    """Get the target URL based on branch"""
    if current_branch == default_branch:
        return repo_url

    # Get PR URL for non-default branch
    try:
        path_parts = repo_url.split("github.com/")[1].split("/")
        owner, repo = path_parts[0], path_parts[1]

        pr_url = run_command(
            [
                "gh",
                "api",
                f"repos/{owner}/{repo}/pulls?head={owner}:{current_branch}",
                "--jq",
                ".[0].html_url",
            ]
        )

        return pr_url if pr_url else f"{repo_url}/pull/{current_branch}"
    except Exception:
        return f"{repo_url}/pull/{current_branch}"


def open_in_chrome(url, tab_id=None):
    """Open URL in Chrome, reusing tab if possible"""
    if tab_id:
        run_command(["chrome-cli", "activate", "-t", tab_id])
        run_command(["chrome-cli", "open", url, "-t", tab_id], return_stdout=False)
    else:
        run_command(["chrome-cli", "open", url], return_stdout=False)


if __name__ == "__main__":
    # Get GitHub repository info
    repo_url, current_branch, default_branch = get_github_info()

    # Determine target URL based on branch
    target_url = get_target_url(repo_url, current_branch, default_branch)

    # Find and open appropriate Chrome tab
    tab_map = get_github_chrome_tabs()
    tab_id = find_matching_tab(target_url, tab_map)
    open_in_chrome(target_url, tab_id)
