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


# Example usage
if __name__ == "__main__":
    ids, urls = get_github_links()
    print("IDs:", ids)
    print("URLs:", urls)

    # Example of how to access individual items
    for i, (id_val, url) in enumerate(zip(ids, urls)):
        print(f"{i + 1}. ID: {id_val}, URL: {url}")
