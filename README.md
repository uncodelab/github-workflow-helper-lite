
# Github workflow helper - Lite 🚀

A Bash script designed for managing Git repositories interactively. This script uses the **GitHub Flow** method, where there is one main branch (`main`) and two supported branch types: `hotfix` and `feature`.

GitHub Flow is a lightweight, branch-based workflow that supports teams and projects where work happens in small, incremental changes. Here's how it works:

- **Main Branch**: This is the primary branch where the production code resides. All changes eventually merge into this branch.
- **Feature Branches**: These are created for new features or enhancements. They are prefixed with `feature/`.
- **Hotfix Branches**: Used for immediate fixes to the main branch. These are prefixed with `hotfix/`.

This GitHub workflow helper script is essential for streamlining Git repository management, especially when adhering to the GitHub Flow method.
It simplifies the process of managing branches, committing changes, and handling merges by automating these tasks. This not only reduces the likelihood of human error in complex Git operations but also significantly cuts down the time spent on routine repository maintenance.
By automating branch creation, merging, and cleanup, the script ensures that developers can focus more on coding rather than on Git management, while still maintaining the integrity of the GitHub Flow process where Pull Requests must be managed through GitHub's web interface.

## Features ✨

### Lite Version

-  **Setup Repository**: Initialize new or clone existing repositories.
-  **Commit Changes**: Stage and commit changes with semantic versioning.
-  **Feature Branching**: Start new feature or hotfix branches.
-  **Finish Branch (Paid)**: Merge, tag, and clean up branches after work is done.
-  **Switch Branch**: Easily switch between local and remote branches.

### Paid Version (Upgrade for Advanced Features)

The **Paid Version** of this script includes additional advanced features to further enhance your workflow:

- **Finish Branch**: Automatically merge changes, tag releases, and clean up branches once work is completed.
- **Advanced Committing**: Gain more control over staging with options like staging only modified files, staging untracked files, and unstaging all changes.
- **Header Statistics**: Key statistics are displayed in the header for quick and easy access.
- **Advanced Branch Checkout**: Effortlessly switch to remote branches, automatically setting them as tracking branches if they don’t exist locally.

The paid version of GitHub Workflow Helper is available for purchase here:
https://buymeacoffee.com/uncodelab/e/376427

## Installation 🛠️

1.  **Copy the script files to your server or git clone:**
```bash
git clone git@github.com:uncodelab/github-workflow-helper-lite.git
```
2.  **Add the scripts directory to your PATH:**
Add the following line to your `.bashrc`, `.zshrc`, or equivalent shell configuration file:
```bash
export PATH="$HOME/github-workflow-helper-lite:$PATH"
```
3.  **Reload your shell:**
```bash
source  ~/.bashrc  # or source ~/.zshrc
```
4. Navigate to the scripts directory directory
```bash
cd /path/to/github-workflow-helper-lite
```
5. Make main script executable
```bash
chmod  +x  github-helper-lite.sh
```

## Usage 💻

### Basic Commands

```bash
# Run the main script
./github-helper-lite.sh

# Follow the interactive prompts to:
# - Setup Repository
# - Commit Changes
# - Feature Start
# - And more...
```

### Main Menu Options

1. **Setup Repository** - Choose to initialize a new repository or clone an existing one.
2. **Commit Changes** - Stage changes, commit with a message, and push to remote if desired.
3. **Feature Start** - Create a new feature branch.
4. **Hotfix Start** - Create a new hotfix branch for urgent fixes.
5. **Finish Current Branch (Paid)** - Complete work on the current branch, merge, and optionally tag a release.
6. **Switch Branch** - Switch between branches or checkout a new one from remote (Paid).
7. **Exit** - Terminate the script.

### Requirements

- Git must be installed on your system.
- Bash version 4 or higher.

### Script Structure

- github-helper.sh: The main script file.
- utils.sh: Contains utility functions for operations like printing messages, managing Git commands, etc.
- functions.sh: Includes functions for various Git operations used by the script.
- operations.sh: Defines the main operational logic for each menu option.

### Example Workflow

1. Start the script
2. Enter your commit message when prompted
3. The script will automatically:
	- Stage your changes
	- Create a commit
	- Push to your remote repository

## Project Status 🏗️

This project is currently under active development. New features and improvements are being added regularly.

## License 🔒

#### License Agreement

This script is provided as a lite version and is not freely redistributable. By using this script, you agree to the following terms:

- **Use**: You may use this script for personal or commercial purposes on one server only unless otherwise specified by additional licensing terms.
- **Copying**: You may not copy, reproduce, or distribute this script or any part of it without explicit written permission from the copyright holder.
- **Modification**: Any modifications to the script must be kept confidential and cannot be redistributed or sold.
- **Support**: No support is provided unless specified in the purchase agreement.

**Important**: We strongly recommend testing all functions of this script on a test server before deploying it in a production environment to ensure compatibility and functionality.

This script is offered as-is without any warranty. For further information on licensing, support questions, or any other inquiries, please contact  - [admin@uncodelab.com](mailto:admin@uncodelab.com)

© uncodelab 2025. All rights reserved.