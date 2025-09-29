#!/usr/bin/env python3
import subprocess
import re


def run_command(cmd, return_stdout=True, silent=False):
    """Run a shell command and return stdout or success status"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if return_stdout:
            return result.stdout.strip()
        return True
    except Exception as e:
        if not silent:
            print(f"Command error ({' '.join(cmd)}): {e}")
        return None if return_stdout else False


def get_github_links():
    """Get GitHub links from Chrome browser and return lists of IDs and URLs."""
    result = run_command(["chrome-cli", "list", "links"])
    if not result:
        return [], []

    ids = []
    urls = []

    for line in result.splitlines():
        if "github.com" in line:
            id_match = re.search(r"\[(\d+)\]", line)
            parts = line.split()

            if id_match and len(parts) > 1:
                ids.append(id_match.group(1))
                urls.append(parts[1])

    return ids, urls


def get_git_info():
    """Get git repository information in a single function"""
    # Check if we're in a git repository
    if not run_command(
        ["git", "rev-parse", "--is-inside-work-tree"], return_stdout=False, silent=True
    ):
        return None, None, None

    # Get origin URL
    origin = run_command(["git", "remote", "get-url", "origin"])
    if not origin or "github.com" not in origin:
        return None, None, None

    # Get current branch
    current_branch = run_command(["git", "rev-parse", "--abbrev-ref", "HEAD"])

    # Get default branch
    default_branch_ref = run_command(
        ["git", "rev-parse", "--abbrev-ref", "origin/HEAD"]
    )
    default_branch = (
        default_branch_ref.replace("origin/", "") if default_branch_ref else None
    )

    return origin, current_branch, default_branch


def get_repo_url(origin):
    """Convert a Git origin URL to a browser-friendly GitHub URL."""
    if origin.startswith("git@github.com:"):
        # Convert SSH format to HTTPS
        repo_path = origin.split("git@github.com:")[1].replace(".git", "")
        return f"https://github.com/{repo_path}"
    elif origin.startswith("https://github.com/"):
        # Already HTTPS format, just remove .git if present
        return origin.replace(".git", "")
    return None


def find_matching_tab(target_url, urls, ids):
    """Find tab ID for a GitHub URL, matching either exactly or by repository base."""
    if not target_url or not urls:
        return None

    # First try exact match
    for i, url in enumerate(urls):
        if target_url == url:
            return ids[i]

    # Try matching repository base (github.com/owner/repo)
    base_repo_match = re.search(r"(https?://github\.com/[^/]+/[^/]+)", target_url)
    if base_repo_match:
        base_repo_url = base_repo_match.group(1)
        for i, url in enumerate(urls):
            if base_repo_url in url:
                return ids[i]

    return None


def open_github_tab(url, tab_id=None):
    """Open a GitHub URL in Chrome in new or existing tab."""
    if tab_id:
        # Focus and navigate existing tab
        run_command(["chrome-cli", "activate", "-t", tab_id])
        return run_command(
            ["chrome-cli", "open", url, "-t", tab_id], return_stdout=False
        )
    else:
        # Open in new tab
        return run_command(["chrome-cli", "open", url], return_stdout=False)


def get_pr_url(repo_url, branch):
    """Get URL for existing PR or create new PR for the branch."""
    if not repo_url or not branch:
        return None

    try:
        # Extract owner and repo
        path_parts = repo_url.split("github.com/")[1].split("/")
        owner, repo = path_parts[0], path_parts[1]

        # Query GitHub API
        pr_url = run_command(
            [
                "gh",
                "api",
                f"repos/{owner}/{repo}/pulls?head={owner}:{branch}",
                "--jq",
                ".[0].html_url",
            ]
        )

        # Return PR URL if found, otherwise return new PR URL
        return pr_url if pr_url else f"{repo_url}/pull/{branch}"

    except Exception:
        return f"{repo_url}/pull/{branch}"


if __name__ == "__main__":
    # Get GitHub tabs from Chrome
    ids, urls = get_github_links()

    # Get git repository information
    origin, current_branch, default_branch = get_git_info()
    if not origin:
        print("Not in a GitHub repository.")
        exit(1)

    # Convert git origin to browser URL
    repo_url = get_repo_url(origin)
    if not repo_url:
        print("Could not determine repository URL.")
        exit(1)

    # Open appropriate URL based on branch
    if current_branch == default_branch:
        # For default branch, open repository main page
        tab_id = find_matching_tab(repo_url, urls, ids)
        open_github_tab(repo_url, tab_id)
    else:
        # For feature branch, open PR page
        pr_url = get_pr_url(repo_url, current_branch)
        tab_id = find_matching_tab(pr_url, urls, ids)
        open_github_tab(pr_url, tab_id)
