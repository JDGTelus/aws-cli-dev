# Changelog - Container Setup Updates

## 2025-10-05 - Major Configuration Update

### Changed Working Directory
- **Before:** Container started in `/git` (isolated workspace)
- **After:** Container starts in `/root` (home directory)
- **Projects Location:** `/root/git` (mounted to `./workspace` on host)

### Benefits
1. **Standard Unix Layout:** Follows conventional home directory structure
2. **Better Tool Integration:** Neovim, tmux, and OpenCode work naturally from home
3. **Persistent Projects:** `/root/git` auto-saves to `./workspace` on host
4. **Clean Separation:** Configuration in `/root/.config`, projects in `/root/git`

### File Persistence
- `/root/git` → Persists to `./workspace` on host ✅
- `/root/.aws` → Docker volume (persists) ✅
- `/root/.config` → Lost on container removal ⚠️
- Other home files → Lost on container removal ⚠️

### Updated Prompt
The zsh prompt now shows:
- Current directory (uses `%~` for proper home directory display)
- Git branch and status
- AWS region (when configured)

Example: `aws-cli-env ➜ ~/git/myproject <us-east-1>`

### Container Technology
- **Base:** Ubuntu 24.04 LTS
- **AWS CLI:** v2 (official binary)
- **Python:** 3.12.3
- **Node.js:** 20.19.5 LTS
- **Neovim:** 0.12.0-dev
- **OpenCode:** 0.14.3
- **Tmux:** 3.4

### Documentation
- Updated README.md with new directory structure
- Created QUICKREF.md for essential commands
- Updated entrypoint.sh to show project location

### Docker Compose Changes
```yaml
volumes:
  - aws-config:/root/.aws          # AWS credentials (volume)
  - ./workspace:/root/git           # Your projects (host mount)
  - ./scripts:/scripts:ro           # Setup scripts (read-only)
```

### Dockerfile Changes
```dockerfile
WORKDIR /root                       # Changed from /git
RUN mkdir -p /root/git              # Created git subdirectory
```

### Migration Notes
If you have existing work in the old container:
```bash
# Backup from old container
docker cp ai-practitioner-aws-env:/git ./old-workspace

# Copy to new location
cp -r ./old-workspace/* ./workspace/

# Start new container
docker-compose up -d
```

### Compatibility
- All tools (AWS CLI, Neovim, tmux, OpenCode) fully functional ✅
- UTF-8 locale configured ✅
- 256-color tmux support ✅
- Port mappings unchanged ✅
- AWS credentials isolated ✅
