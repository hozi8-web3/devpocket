class GitCommandEntry {
  final String command;
  final String description;
  final String category;

  const GitCommandEntry({
    required this.command,
    required this.description,
    required this.category,
  });
}

const List<GitCommandEntry> gitCommands = [
  // Setup
  GitCommandEntry(command: 'git config --global user.name "Name"', description: 'Set your global username', category: 'Setup'),
  GitCommandEntry(command: 'git config --global user.email "email@example.com"', description: 'Set your global email', category: 'Setup'),
  GitCommandEntry(command: 'git config --list', description: 'View all config settings', category: 'Setup'),
  GitCommandEntry(command: 'git config --global core.editor "code --wait"', description: 'Set VS Code as default editor', category: 'Setup'),

  // Starting a Repo
  GitCommandEntry(command: 'git init', description: 'Initialize a new local repository', category: 'Initialize'),
  GitCommandEntry(command: 'git clone <url>', description: 'Clone a remote repository', category: 'Initialize'),
  GitCommandEntry(command: 'git clone <url> --depth 1', description: 'Shallow clone (latest commit only)', category: 'Initialize'),

  // Staging & Committing
  GitCommandEntry(command: 'git status', description: 'Check status of working directory', category: 'Basics'),
  GitCommandEntry(command: 'git add .', description: 'Stage all changes', category: 'Basics'),
  GitCommandEntry(command: 'git add <file>', description: 'Stage a specific file', category: 'Basics'),
  GitCommandEntry(command: 'git add -p', description: 'Interactively stage chunks', category: 'Basics'),
  GitCommandEntry(command: 'git commit -m "message"', description: 'Commit staged changes', category: 'Basics'),
  GitCommandEntry(command: 'git commit --amend', description: 'Modify the last commit', category: 'Basics'),
  GitCommandEntry(command: 'git commit --amend --no-edit', description: 'Amend last commit without changing message', category: 'Basics'),

  // Branching
  GitCommandEntry(command: 'git branch', description: 'List all local branches', category: 'Branching'),
  GitCommandEntry(command: 'git branch -a', description: 'List all branches including remote', category: 'Branching'),
  GitCommandEntry(command: 'git branch <name>', description: 'Create a new branch', category: 'Branching'),
  GitCommandEntry(command: 'git checkout <branch>', description: 'Switch to a branch', category: 'Branching'),
  GitCommandEntry(command: 'git checkout -b <branch>', description: 'Create and switch to new branch', category: 'Branching'),
  GitCommandEntry(command: 'git switch <branch>', description: 'Switch branches (modern syntax)', category: 'Branching'),
  GitCommandEntry(command: 'git switch -c <branch>', description: 'Create and switch (modern syntax)', category: 'Branching'),
  GitCommandEntry(command: 'git branch -d <branch>', description: 'Delete a merged branch', category: 'Branching'),
  GitCommandEntry(command: 'git branch -D <branch>', description: 'Force delete a branch', category: 'Branching'),
  GitCommandEntry(command: 'git merge <branch>', description: 'Merge branch into current', category: 'Branching'),
  GitCommandEntry(command: 'git merge --no-ff <branch>', description: 'Merge with a merge commit always', category: 'Branching'),
  GitCommandEntry(command: 'git rebase <branch>', description: 'Rebase onto another branch', category: 'Branching'),
  GitCommandEntry(command: 'git rebase -i HEAD~3', description: 'Interactive rebase last 3 commits', category: 'Branching'),

  // Remote
  GitCommandEntry(command: 'git remote -v', description: 'List remote connections', category: 'Remote'),
  GitCommandEntry(command: 'git remote add origin <url>', description: 'Add remote named origin', category: 'Remote'),
  GitCommandEntry(command: 'git fetch', description: 'Download remote changes without merging', category: 'Remote'),
  GitCommandEntry(command: 'git fetch --all', description: 'Fetch all remotes', category: 'Remote'),
  GitCommandEntry(command: 'git pull', description: 'Fetch and merge remote changes', category: 'Remote'),
  GitCommandEntry(command: 'git pull --rebase', description: 'Fetch and rebase instead of merge', category: 'Remote'),
  GitCommandEntry(command: 'git push', description: 'Push to remote', category: 'Remote'),
  GitCommandEntry(command: 'git push -u origin <branch>', description: 'Push and set upstream', category: 'Remote'),
  GitCommandEntry(command: 'git push --force-with-lease', description: 'Force push safely (checks remote)', category: 'Remote'),
  GitCommandEntry(command: 'git push origin --delete <branch>', description: 'Delete remote branch', category: 'Remote'),

  // History
  GitCommandEntry(command: 'git log --oneline --graph', description: 'Compact visual log', category: 'History'),
  GitCommandEntry(command: 'git log --author="Name"', description: 'Filter log by author', category: 'History'),
  GitCommandEntry(command: 'git log -p <file>', description: 'Show changes to a file over time', category: 'History'),
  GitCommandEntry(command: 'git diff', description: 'Show unstaged changes', category: 'History'),
  GitCommandEntry(command: 'git diff --staged', description: 'Show staged changes', category: 'History'),
  GitCommandEntry(command: 'git blame <file>', description: 'Show who changed each line', category: 'History'),
  GitCommandEntry(command: 'git show <commit>', description: 'Show a specific commit', category: 'History'),

  // Undoing
  GitCommandEntry(command: 'git restore <file>', description: 'Discard working directory changes', category: 'Undoing'),
  GitCommandEntry(command: 'git restore --staged <file>', description: 'Unstage a file', category: 'Undoing'),
  GitCommandEntry(command: 'git reset HEAD~1', description: 'Undo last commit, keep changes staged', category: 'Undoing'),
  GitCommandEntry(command: 'git reset --hard HEAD~1', description: 'Undo last commit, discard changes', category: 'Undoing'),
  GitCommandEntry(command: 'git revert <commit>', description: 'Create revert commit safely', category: 'Undoing'),
  GitCommandEntry(command: 'git clean -fd', description: 'Remove untracked files and directories', category: 'Undoing'),

  // Stashing
  GitCommandEntry(command: 'git stash', description: 'Stash current changes', category: 'Stashing'),
  GitCommandEntry(command: 'git stash push -m "message"', description: 'Stash with a description', category: 'Stashing'),
  GitCommandEntry(command: 'git stash list', description: 'List all stashes', category: 'Stashing'),
  GitCommandEntry(command: 'git stash pop', description: 'Apply and remove latest stash', category: 'Stashing'),
  GitCommandEntry(command: 'git stash apply stash@{2}', description: 'Apply specific stash without removing', category: 'Stashing'),
  GitCommandEntry(command: 'git stash drop stash@{0}', description: 'Remove a specific stash', category: 'Stashing'),

  // Tags
  GitCommandEntry(command: 'git tag', description: 'List all tags', category: 'Tags'),
  GitCommandEntry(command: 'git tag v1.0.0', description: 'Create a lightweight tag', category: 'Tags'),
  GitCommandEntry(command: 'git tag -a v1.0.0 -m "Release"', description: 'Create annotated tag', category: 'Tags'),
  GitCommandEntry(command: 'git push origin --tags', description: 'Push all tags to remote', category: 'Tags'),
  GitCommandEntry(command: 'git tag -d v1.0.0', description: 'Delete a tag locally', category: 'Tags'),
];
