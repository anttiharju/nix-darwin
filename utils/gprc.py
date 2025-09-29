#!/usr/bin/env python3
import subprocess
import re


def get_github_links():
    """
    Get GitHub links from Chrome browser and return lists of IDs and URLs.

    Returns:
        tuple: (list of IDs, list of URLs)
    """
    try:
        # Run chrome-cli to get links
        result = subprocess.run(
            ["chrome-cli", "list", "links"], capture_output=True, text=True, check=True
        )

        ids = []
        urls = []

        # Process each line
        for line in result.stdout.splitlines():
            if "github.com" in line:
                # Extract ID between square brackets using regex
                id_match = re.search(r"\[(\d+)\]", line)
                id_value = id_match.group(1) if id_match else None

                # Extract URL as the second item
                parts = line.split()
                url = parts[1] if len(parts) > 1 else None

                if id_value and url:
                    ids.append(id_value)
                    urls.append(url)

        return ids, urls

    except subprocess.CalledProcessError as e:
        print(f"Error running chrome-cli: {e}")
        return [], []
    except Exception as e:
        print(f"Unexpected error: {e}")
        return [], []


def get_default_branch():
    """
    Get the default branch (e.g., main, master) of the current Git repository.

    Returns:
        str: Name of the default branch or None if not in a Git repository
    """
    try:
        # Check if we're in a Git repository
        subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            capture_output=True,
            check=True,
        )

        # Get the default branch from origin/HEAD
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "origin/HEAD"],
            capture_output=True,
            text=True,
            check=True,
        )

        # Extract the branch name from "origin/main"
        default_branch = result.stdout.strip()
        if default_branch.startswith("origin/"):
            default_branch = default_branch[len("origin/") :]

        return default_branch

    except subprocess.CalledProcessError:
        return None
    except Exception as e:
        print(f"Error determining default branch: {e}")
        return None


def get_github_origin():
    """
    Get the GitHub origin URL of the current Git repository.

    Returns:
        str: GitHub origin URL or None if not a GitHub repository
    """
    try:
        # Get the origin URL
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            check=True,
        )

        origin = result.stdout.strip()

        # Check if the origin is from GitHub
        if "github.com" in origin:
            return origin
        else:
            print("Error: Repository origin is not on GitHub.")
            return None

    except subprocess.CalledProcessError as e:
        print(f"Git error: {e}")
        return None
    except Exception as e:
        print(f"Error determining origin: {e}")
        return None


def get_repo_url(origin):
    """
    Convert a Git origin URL to a browser-friendly GitHub URL.

    Args:
        origin (str): Git origin URL (SSH or HTTPS format)

    Returns:
        str: Browser-friendly GitHub URL or None if format is not supported
    """
    if origin.startswith("git@github.com:"):
        # Convert SSH format (git@github.com:username/repo.git) to HTTPS
        repo_path = origin.split("git@github.com:")[1]
        if repo_path.endswith(".git"):
            repo_path = repo_path[:-4]  # Remove .git suffix
        return f"https://github.com/{repo_path}"

    elif origin.startswith("https://github.com/"):
        # Already HTTPS format, just remove .git if present
        if origin.endswith(".git"):
            return origin[:-4]
        return origin

    else:
        print("Error: Only SSH and HTTPS GitHub URLs are supported.")
        return None


def get_current_branch():
    """
    Get the name of the current Git branch.

    Returns:
        str: Name of the current branch or None if not in a Git repository
    """
    try:
        # Run the git command to get current branch name
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
        )

        # Return the branch name (trimming any whitespace)
        return result.stdout.strip()

    except subprocess.CalledProcessError as e:
        print(f"Git error: {e}")
        return None
    except Exception as e:
        print(f"Error determining current branch: {e}")
        return None


def find_matching_tab_id(target_url, urls, ids):
    """
    Find the ID of a Chrome tab that matches the given URL.
    First tries for exact match, then ensures it matches at least github.com/owner/repo.

    Args:
        target_url (str): The URL to match
        urls (list): List of URLs from chrome tabs
        ids (list): List of corresponding tab IDs

    Returns:
        str: The ID of the matching tab, or None if no match is found
    """
    if not target_url or not urls or not ids:
        return None

    # First, try for an exact match
    for i, url in enumerate(urls):
        if target_url == url:
            return ids[i]

    # Extract the base repository URL (github.com/owner/repo) from the target URL
    import re

    base_repo_pattern = r"(https?://github\.com/[^/]+/[^/]+)"
    base_repo_match = re.search(base_repo_pattern, target_url)

    if base_repo_match:
        base_repo_url = base_repo_match.group(1)

        # Look for URLs that contain the base repository URL
        for i, url in enumerate(urls):
            if base_repo_url in url:
                return ids[i]

    return None


def open_github_tab(url, matching_id=None):
    """
    Open a GitHub URL in Chrome, either opening an existing tab
    or creating a new one, and focus that tab.

    Args:
        url (str): The URL to open
        matching_id (str, optional): ID of an existing tab with this URL

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        if matching_id:
            # First, switch chrome to the existing tab
            subprocess.run(["chrome-cli", "activate", "-t", matching_id], check=True)
            # Then open the URL in that tab
            subprocess.run(["chrome-cli", "open", url, "-t", matching_id], check=True)
        else:
            # For new tabs, chrome-cli open will automatically focus the tab
            subprocess.run(["chrome-cli", "open", url], check=True)
            print(f"Opened new tab with URL: {url}")

        return True

    except subprocess.CalledProcessError as e:
        print(f"Error opening Chrome tab: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False


def get_pr_url(repo_url, branch):
    """
    Get the URL of an existing pull request for the current branch.
    If no PR exists, return a URL to create a new one.

    Args:
        repo_url (str): Repository URL in https://github.com/owner/repo format
        branch (str): Branch name

    Returns:
        str: URL to an existing PR or URL to create a new PR
    """
    try:
        # Extract owner and repo from the repository URL
        path_parts = repo_url.split("github.com/")[1].split("/")
        owner = path_parts[0]
        repo = path_parts[1] if len(path_parts) > 1 else None

        if not owner or not repo:
            print("Error: Could not extract owner/repo from URL")
            return None

        # Query GitHub API for PRs with the current branch
        result = subprocess.run(
            [
                "gh",
                "api",
                f"repos/{owner}/{repo}/pulls?head={owner}:{branch}",
                "--jq",
                ".[0].html_url",
            ],
            capture_output=True,
            text=True,
        )

        pr_url = result.stdout.strip()

        # If no PR exists, return URL to create a new one
        if not pr_url:
            return f"{repo_url}/pull/{branch}"

        return pr_url

    except subprocess.CalledProcessError as e:
        print(f"Error querying GitHub API: {e}")
        # Fall back to create PR URL
        return f"{repo_url}/pull/{branch}"
    except Exception as e:
        print(f"Error finding PR URL: {e}")
        return None


# Example usage
if __name__ == "__main__":
    ids, urls = get_github_links()
    default_branch = get_default_branch()
    github_origin = get_github_origin()
    repo_url = get_repo_url(github_origin)
    current_branch = get_current_branch()

    if current_branch == default_branch:
        matching_id = find_matching_tab_id(repo_url, urls, ids)
        open_github_tab(repo_url, matching_id)
    else:
        pr_url = get_pr_url(repo_url, current_branch)
        # Find if the PR URL is already open in a tab
        matching_id = find_matching_tab_id(pr_url, urls, ids)
        # Open or focus the tab with the PR
        open_github_tab(pr_url, matching_id)
