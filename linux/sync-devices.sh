#!/bin/bash
#
# sync-devices.sh - Sync work-in-progress git changes between devices.
#
# Creates (or applies) a git patch named 'wip.patch' that captures every local
# change in the current repository, tracked and untracked alike.
#
# When creating, the script stashes all changes with
#     git stash push -u -m "wip: sync <YYMMDDHHmmSS>"
# (the timestamp keeps repeated runs from stacking up identically named
# stashes) and then writes the stash contents to a patch file with
#     git stash show -p -u
# The patch is stored in the sync folder (a location that is typically mirrored
# across your devices, e.g. a cloud-synced folder). On the other device, run the
# same script with --apply to replay the patch onto the working tree.
#
# The patch file is always named 'wip.patch' inside the sync folder.
#
# Usage:
#   sync-devices.sh [PATH] [--apply]
#
#   PATH        Folder in which 'wip.patch' is saved (create mode) or read from
#               (apply mode). Optional and positional. Resolution order:
#                 1. This argument, whenever supplied (definitive).
#                 2. The SYNC_DEVICES_FOLDER environment variable, when set.
#                 3. The '~/syncronizations' fallback.
#   -a, --apply Apply the existing 'wip.patch' from PATH to the current
#               repository instead of creating a new one.
#
# Examples:
#   sync-devices.sh                 # write ~/syncronizations/wip.patch
#   sync-devices.sh ~/Sync          # write ~/Sync/wip.patch
#   sync-devices.sh --apply         # apply ~/syncronizations/wip.patch
#   sync-devices.sh ~/Sync --apply  # apply ~/Sync/wip.patch

set -e

# Default variable values
APPLY=0
SYNC_PATH=""
PATH_GIVEN=0

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0 [PATH] [--apply]"
            echo "  PATH         Folder holding wip.patch (default: \$SYNC_DEVICES_FOLDER or ~/syncronizations)"
            echo "  -a, --apply  Apply wip.patch instead of creating it"
            exit 0
            ;;
        -a|--apply)
            APPLY=1
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ $PATH_GIVEN -eq 1 ]]; then
                echo "Unexpected extra argument: $1" >&2
                exit 1
            fi
            SYNC_PATH="$1"
            PATH_GIVEN=1
            shift
            ;;
    esac
done

# Determine the sync folder when the user did not pass a path. An explicit
# argument always wins; otherwise fall back to the SYNC_DEVICES_FOLDER
# environment variable, and finally to '~/syncronizations'.
if [[ $PATH_GIVEN -eq 0 ]]; then
    if [[ -n "${SYNC_DEVICES_FOLDER:-}" ]]; then
        SYNC_PATH="$SYNC_DEVICES_FOLDER"
    else
        SYNC_PATH="~/syncronizations"
    fi
fi

# Resolve a leading '~' to the user's home directory (it is not expanded when it
# comes from a variable or a quoted argument).
case "$SYNC_PATH" in
    "~")    SYNC_PATH="$HOME" ;;
    "~/"*)  SYNC_PATH="$HOME/${SYNC_PATH#\~/}" ;;
esac

# We must be inside a git work tree for any of this to make sense.
if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    echo "Not inside a git repository. Run this script from within your repo." >&2
    exit 1
fi

PATCH_FILE="$SYNC_PATH/wip.patch"

if [[ $APPLY -eq 1 ]]; then
    if [[ ! -f "$PATCH_FILE" ]]; then
        echo "Patch file not found: $PATCH_FILE" >&2
        exit 1
    fi

    echo "Applying patch $PATCH_FILE ..."
    if ! git apply --whitespace=nowarn -- "$PATCH_FILE"; then
        echo "git apply failed. The patch may not fit the current tree state." >&2
        exit 1
    fi

    echo "Done. Changes from wip.patch have been applied to the working tree."
else
    if [[ ! -d "$SYNC_PATH" ]]; then
        echo "The folder $SYNC_PATH does not exist." >&2
        exit 1
    fi

    # Stash everything, including untracked files, under a timestamped message
    # (YYMMDDHHmmSS) so repeated runs don't pile up identically named stashes.
    STASH_MSG="wip: sync $(date +%y%m%d%H%M%S)"
    if ! git stash push -u -m "$STASH_MSG"; then
        echo "git stash push failed." >&2
        exit 1
    fi

    # Nothing was stashed => nothing to export.
    TOP_STASH="$(git stash list --format='%gs' 2>/dev/null | head -n 1)"
    if [[ "$TOP_STASH" != *"$STASH_MSG"* ]]; then
        echo "No local changes to sync. Nothing was written."
        exit 0
    fi

    # Capture the stash as a unified diff (tracked + untracked). git writes its
    # raw bytes straight to the file, so a plain redirect is exactly right here.
    if ! git stash show -p -u > "$PATCH_FILE"; then
        echo "git stash show failed." >&2
        exit 1
    fi

    echo "Patch written to $PATCH_FILE"
    echo "Your changes are kept in a stash ('$STASH_MSG')."
    echo "Restore them on this device with: git stash pop"
fi
