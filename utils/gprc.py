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
            capture_output=True, text=True, check=True
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

# Example usage
if __name__ == "__main__":
    ids, urls = get_github_links()
    print("IDs:", ids)
    print("URLs:", urls)

    # Example of how to access individual items
    for i, (id_val, url) in enumerate(zip(ids, urls)):
        print(f"{i + 1}. ID: {id_val}, URL: {url}")

    default_branch = get_default_branch()
    if default_branch:
        print(f"Default branch: {default_branch}")
    else:
        print("Error: Not in a Git repository or couldn't determine default branch.")

    github_origin = get_github_origin()
    print(f"GitHub Origin: {github_origin}")
