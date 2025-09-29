#!/usr/bin/env python3
import subprocess
import re


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
    if not result:
        return {}, []

    tab_map = {}
    urls = []

    for line in result.splitlines():
        if "github.com" in line:
            id_match = re.search(r"\[(\d+)\]", line)
            parts = line.split()

            if id_match and len(parts) > 1:
                tab_id = id_match.group(1)
                url = parts[1]
                tab_map[url] = tab_id
                urls.append(url)

    return tab_map, urls


def get_github_info():
    """Get GitHub repository and branch information"""
    # Verify git repo and get origin URL
    if not run_command(
        ["git", "rev-parse", "--is-inside-work-tree"], return_stdout=False, silent=True
    ):
        print("Not in a GitHub repository.")
        exit(1)

    origin = run_command(["git", "remote", "get-url", "origin"])
    if not origin or "github.com" not in origin:
        print("Not a GitHub repository.")
        exit(1)

    # Convert origin to browser URL
    if origin.startswith("git@github.com:"):
        repo_path = origin.split("git@github.com:")[1].replace(".git", "")
        repo_url = f"https://github.com/{repo_path}"
    elif origin.startswith("https://github.com/"):
        repo_url = origin.replace(".git", "")
    else:
        print("Unsupported GitHub URL format.")
        exit(1)

    # Get branch info
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
    # Exact URL match
    if target_url in tab_map:
        return tab_map[target_url]

    # Match by repo base URL
    base_match = re.search(r"(https?://github\.com/[^/]+/[^/]+)", target_url)
    if base_match:
        base_url = base_match.group(1)
        for url, tab_id in tab_map.items():
            if base_url in url:
                return tab_id

    return None


def get_pr_url(repo_url, branch):
    """Get PR URL for the current branch"""
    try:
        # Extract owner/repo from URL
        path_parts = repo_url.split("github.com/")[1].split("/")
        owner, repo = path_parts[0], path_parts[1]

        # Check for existing PR
        pr_url = run_command(
            [
                "gh",
                "api",
                f"repos/{owner}/{repo}/pulls?head={owner}:{branch}",
                "--jq",
                ".[0].html_url",
            ]
        )

        return pr_url or f"{repo_url}/pull/{branch}"
    except Exception:
        return f"{repo_url}/pull/{branch}"


def open_url_in_chrome(url, tab_id=None):
    """Open URL in Chrome, reusing tab if possible"""
    if tab_id:
        run_command(["chrome-cli", "activate", "-t", tab_id])
        run_command(["chrome-cli", "open", url, "-t", tab_id], return_stdout=False)
    else:
        run_command(["chrome-cli", "open", url], return_stdout=False)


if __name__ == "__main__":
    # Get GitHub info from git repo
    repo_url, current_branch, default_branch = get_github_info()

    # Get GitHub tabs from Chrome
    tab_map, urls = get_github_chrome_tabs()

    # Determine target URL based on branch
    if current_branch == default_branch:
        target_url = repo_url  # Main repo page for default branch
    else:
        target_url = get_pr_url(repo_url, current_branch)  # PR page for feature branch

    # Find and open appropriate tab
    tab_id = find_matching_tab(target_url, tab_map)
    open_url_in_chrome(target_url, tab_id)
