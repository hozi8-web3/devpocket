class LinuxCommandEntry {
  final String command;
  final String description;
  final String flags;
  final String category;

  const LinuxCommandEntry({
    required this.command,
    required this.description,
    this.flags = '',
    required this.category,
  });
}

const List<LinuxCommandEntry> linuxCommands = [
  // File System
  LinuxCommandEntry(command: 'ls', description: 'List directory contents', flags: '-la (long + hidden), -h (human sizes)', category: 'Files'),
  LinuxCommandEntry(command: 'cd <dir>', description: 'Change directory', flags: '- (previous dir), ~ (home)', category: 'Files'),
  LinuxCommandEntry(command: 'pwd', description: 'Print working directory', flags: '', category: 'Files'),
  LinuxCommandEntry(command: 'mkdir <dir>', description: 'Create directory', flags: '-p (create parents)', category: 'Files'),
  LinuxCommandEntry(command: 'rm <file>', description: 'Remove file', flags: '-rf (recursive force)', category: 'Files'),
  LinuxCommandEntry(command: 'cp <src> <dst>', description: 'Copy file or directory', flags: '-r (recursive)', category: 'Files'),
  LinuxCommandEntry(command: 'mv <src> <dst>', description: 'Move or rename file', flags: '', category: 'Files'),
  LinuxCommandEntry(command: 'touch <file>', description: 'Create empty file or update timestamp', flags: '', category: 'Files'),
  LinuxCommandEntry(command: 'find <dir> -name "*.txt"', description: 'Find files by name', flags: '-type f/d, -mtime, -size', category: 'Files'),
  LinuxCommandEntry(command: 'locate <file>', description: 'Fast file search using database', flags: '', category: 'Files'),
  LinuxCommandEntry(command: 'ln -s <target> <link>', description: 'Create symbolic link', flags: '-s (symbolic)', category: 'Files'),
  LinuxCommandEntry(command: 'chmod 755 <file>', description: 'Set file permissions', flags: '+x (add execute), -w (remove write)', category: 'Files'),
  LinuxCommandEntry(command: 'chown user:group <file>', description: 'Change file owner', flags: '-R (recursive)', category: 'Files'),

  // Text & Search
  LinuxCommandEntry(command: 'cat <file>', description: 'Print file contents', flags: '-n (line numbers)', category: 'Text'),
  LinuxCommandEntry(command: 'less <file>', description: 'Paginate file viewing', flags: 'q (quit), /search', category: 'Text'),
  LinuxCommandEntry(command: 'head <file>', description: 'Show first lines of file', flags: '-n 20 (first 20 lines)', category: 'Text'),
  LinuxCommandEntry(command: 'tail <file>', description: 'Show last lines of file', flags: '-f (follow), -n 50', category: 'Text'),
  LinuxCommandEntry(command: 'grep "pattern" <file>', description: 'Search for pattern in file', flags: '-r (recursive), -i (case insensitive), -n (line numbers)', category: 'Text'),
  LinuxCommandEntry(command: 'sed "s/old/new/g" <file>', description: 'Stream editor / substitution', flags: '-i (in-place edit)', category: 'Text'),
  LinuxCommandEntry(command: 'awk \'{print \$1}\' <file>', description: 'Pattern scanning and processing', flags: '-F (field sep), NR (line num)', category: 'Text'),
  LinuxCommandEntry(command: 'sort <file>', description: 'Sort lines of text', flags: '-r (reverse), -n (numeric), -u (unique)', category: 'Text'),
  LinuxCommandEntry(command: 'uniq <file>', description: 'Report or filter repeated lines', flags: '-c (count), -d (only duplicates)', category: 'Text'),
  LinuxCommandEntry(command: 'wc <file>', description: 'Word, line, character count', flags: '-l (lines), -w (words), -c (bytes)', category: 'Text'),
  LinuxCommandEntry(command: 'cut -d "," -f 1', description: 'Extract sections of lines', flags: '-d (delimiter), -f (field)', category: 'Text'),
  LinuxCommandEntry(command: 'xargs', description: 'Build and execute commands from stdin', flags: '-I {} (replace), -P (parallel)', category: 'Text'),
  LinuxCommandEntry(command: 'diff <file1> <file2>', description: 'Compare files line by line', flags: '-u (unified format)', category: 'Text'),

  // Process Management
  LinuxCommandEntry(command: 'ps aux', description: 'List all running processes', flags: 'aux (all users, detailed)', category: 'Processes'),
  LinuxCommandEntry(command: 'top', description: 'Interactive process viewer', flags: 'q (quit), k (kill)', category: 'Processes'),
  LinuxCommandEntry(command: 'htop', description: 'Enhanced interactive process viewer', flags: 'F10 (quit), F9 (kill)', category: 'Processes'),
  LinuxCommandEntry(command: 'kill <pid>', description: 'Kill a process by PID', flags: '-9 (force kill), -15 (graceful)', category: 'Processes'),
  LinuxCommandEntry(command: 'killall <name>', description: 'Kill processes by name', flags: '-9 (force)', category: 'Processes'),
  LinuxCommandEntry(command: 'bg', description: 'Resume suspended job in background', flags: '', category: 'Processes'),
  LinuxCommandEntry(command: 'fg', description: 'Bring background job to foreground', flags: '', category: 'Processes'),
  LinuxCommandEntry(command: 'jobs', description: 'List current shell jobs', flags: '', category: 'Processes'),
  LinuxCommandEntry(command: 'nohup <cmd> &', description: 'Run command immune to hangups', flags: '>> output.log for logging', category: 'Processes'),

  // Networking
  LinuxCommandEntry(command: 'curl <url>', description: 'Transfer data from/to URL', flags: '-X POST, -H, -d, -o (output)', category: 'Network'),
  LinuxCommandEntry(command: 'wget <url>', description: 'Download files from web', flags: '-O (output), -q (quiet)', category: 'Network'),
  LinuxCommandEntry(command: 'ping <host>', description: 'Send ICMP echo requests', flags: '-c 4 (4 packets)', category: 'Network'),
  LinuxCommandEntry(command: 'netstat -tulpn', description: 'Show listening ports', flags: '-t (tcp), -u (udp), -l (listening)', category: 'Network'),
  LinuxCommandEntry(command: 'ss -tulpn', description: 'Socket statistics (modern netstat)', flags: '-t -u -l -p -n', category: 'Network'),
  LinuxCommandEntry(command: 'ifconfig', description: 'Network interface configuration', flags: '', category: 'Network'),
  LinuxCommandEntry(command: 'ip addr', description: 'Show IP addresses (modern)', flags: 'ip route, ip link', category: 'Network'),
  LinuxCommandEntry(command: 'ssh user@host', description: 'Secure shell connection', flags: '-p (port), -i (key), -L (tunnel)', category: 'Network'),
  LinuxCommandEntry(command: 'scp <file> user@host:/path', description: 'Secure copy over SSH', flags: '-r (recursive)', category: 'Network'),
  LinuxCommandEntry(command: 'rsync -avz src/ user@host:/dst', description: 'Sync files over SSH', flags: '--delete, --exclude', category: 'Network'),
  LinuxCommandEntry(command: 'nmap <host>', description: 'Network port scanner', flags: '-p (ports), -sV (versions)', category: 'Network'),

  // Disk & System
  LinuxCommandEntry(command: 'df -h', description: 'Disk space usage', flags: '-h (human readable)', category: 'System'),
  LinuxCommandEntry(command: 'du -sh <dir>', description: 'Directory size', flags: '-s (summary), --max-depth=1', category: 'System'),
  LinuxCommandEntry(command: 'free -h', description: 'Memory usage', flags: '-h (human readable)', category: 'System'),
  LinuxCommandEntry(command: 'uname -a', description: 'System information', flags: '-r (kernel), -m (machine)', category: 'System'),
  LinuxCommandEntry(command: 'lscpu', description: 'CPU architecture information', flags: '', category: 'System'),
  LinuxCommandEntry(command: 'uptime', description: 'System uptime and load average', flags: '', category: 'System'),
  LinuxCommandEntry(command: 'whoami', description: 'Print current user', flags: '', category: 'System'),
  LinuxCommandEntry(command: 'sudo <command>', description: 'Run command as superuser', flags: '-u (as user), -s (shell)', category: 'System'),
  LinuxCommandEntry(command: 'crontab -e', description: 'Edit user cron jobs', flags: '-l (list), -r (remove)', category: 'System'),
  LinuxCommandEntry(command: 'systemctl status <service>', description: 'Check service status', flags: 'start/stop/restart/enable/disable', category: 'System'),
  LinuxCommandEntry(command: 'journalctl -u <service>', description: 'View service logs', flags: '-f (follow), --since "1 hour ago"', category: 'System'),
  LinuxCommandEntry(command: 'env', description: 'Display environment variables', flags: '', category: 'System'),
  LinuxCommandEntry(command: 'export VAR=value', description: 'Set environment variable', flags: '', category: 'System'),
  LinuxCommandEntry(command: 'history', description: 'Command history', flags: '! (run command by number)', category: 'System'),

  // Archives
  LinuxCommandEntry(command: 'tar -czvf archive.tar.gz <dir>', description: 'Create gzip archive', flags: '-c (create), -z (gzip), -v (verbose), -f (file)', category: 'Archives'),
  LinuxCommandEntry(command: 'tar -xzvf archive.tar.gz', description: 'Extract gzip archive', flags: '-x (extract), -C (target dir)', category: 'Archives'),
  LinuxCommandEntry(command: 'zip -r archive.zip <dir>', description: 'Create zip archive', flags: '-r (recursive)', category: 'Archives'),
  LinuxCommandEntry(command: 'unzip archive.zip', description: 'Extract zip archive', flags: '-d (target dir), -l (list)', category: 'Archives'),
];
