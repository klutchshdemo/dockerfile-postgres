#!/usr/bin/env bash
set -euo pipefail

# This wrapper runs as root, fixes perms, then chains to the official entrypoint.
PGDATA_DIR="${PGDATA:-/var/lib/postgresql/data}"

# Resolve UID/GID of postgres dynamically (avoid hardcoding 999:999 across distros)
POSTGRES_UID="$(id -u postgres)"
POSTGRES_GID="$(id -g postgres)"

# Ensure directory exists (safe if already there)
mkdir -p "$PGDATA_DIR"

# If permissions/ownership aren’t strict enough, fix them
# Postgres requires: owned by postgres and not group/world-writable.
need_fix=0

# If not owned by postgres user/group, mark for fix
if [ "$(stat -c '%u' "$PGDATA_DIR")" != "$POSTGRES_UID" ] || [ "$(stat -c '%g' "$PGDATA_DIR")" != "$POSTGRES_GID" ]; then
  need_fix=1
fi

# If mode allows group/world write, mark for fix
mode="$(stat -c '%a' "$PGDATA_DIR")"
# numeric compare: allow 700 or 750 (if you want to let the group read/exec). Adjust as desired.
if [[ "$mode" != "700" && "$mode" != "750" ]]; then
  need_fix=1
fi

if [ "$need_fix" -eq 1 ]; then
  echo "[permfix] Fixing ownership and permissions on $PGDATA_DIR"
  chown -R "$POSTGRES_UID:$POSTGRES_GID" "$PGDATA_DIR"
  # Choose one:
  chmod 700 "$PGDATA_DIR"       # strict (recommended by Postgres)
  # chmod 750 "$PGDATA_DIR"     # slightly relaxed (group readable/enterable)
fi

# Chain to the official entrypoint (which will handle initdb, env vars, etc.)
exec /usr/local/bin/docker-entrypoint.sh "$@"
