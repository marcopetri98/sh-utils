# sh-utils

A fully reproducible way to install and configure an operating system, on **Windows** and on **Linux**.

The goal of this repository is simple: after a clean install, a handful of scripts should be enough to
get a machine back to a known, working state — the same applications, the same theming, the same
developer tooling, every time, without hunting for installers or remembering what was set up months ago.

This is not a generic dotfiles collection: **this is the exact way I set up my own PCs for daily work
and enjoyment**. Everything in here — the browser, the editors, the GNOME theme, the game launchers,
the robotics stack — reflects my personal setup. Feel free to use it as-is, or to fork it and swap the
package lists for your own; the structure is meant to make that easy.

---

## Table of contents

- [Repository layout](#repository-layout)
- [Syncing work across devices](#syncing-work-across-devices)
- [Windows setup](#windows-setup)
- [Linux setup](#linux-setup)
  - [Flags](#flags)
  - [Work profile and the Politecnico di Milano VPN](#work-profile-and-the-politecnico-di-milano-vpn)
  - [Robotics profile](#robotics-profile)
  - [What the base setup installs](#what-the-base-setup-installs)
  - [After the setup](#after-the-setup)
- [Headless / server setup](#headless--server-setup)
- [Commands installed on your PATH](#commands-installed-on-your-path)
- [Extra PowerShell utilities](#extra-powershell-utilities)
- [Notes and caveats](#notes-and-caveats)
- [License](#license)

---

## Repository layout

```
.
├── windows/                     # Entry points for a fresh Windows install
│   ├── setup.ps1                #   Base system: apps, dev tools, research tools
│   └── gaming.ps1               #   Game launchers, monitoring, gaming extras
├── powershell/                  # Standalone PowerShell utilities
│   ├── sync-devices.ps1         #   Move work-in-progress changes between devices
│   ├── disks.ps1                #   Create the standard folder structure on a data disk
│   └── poetry.ps1               #   Per-python-version Poetry environment variables
└── linux/                       # Entry points and building blocks for a fresh Linux install
    ├── setup.sh                 #   Main desktop setup (run this one)
    ├── server.sh                #   Minimal headless/server setup
    ├── work.sh                  #   Work profile (incl. Politecnico di Milano VPN)
    ├── robotics.sh              #   NVIDIA container toolkit, Vulkan, Isaac Sim
    ├── ros2.sh                  #   ROS 2 Jazzy, Nav2 and the Isaac Sim ROS workspaces
    ├── install_commands.sh      #   Installs linux/commands/* into ~/.local/bin and fixes PATH
    ├── commands/                #   Small commands that end up on your PATH
    │   ├── sync-devices         #     Move work-in-progress changes between devices
    │   └── update_system        #     apt + snap + flatpak update in one shot
    ├── installation_scripts/    #   Reusable installers (docker, discord, Isaac Sim, …)
    ├── extensions/              #   GNOME extension list + exported dconf settings
    ├── applications/            #   .desktop launchers installed for the user
    └── autostart/               #   .desktop autostart entries installed for the user
```

---

## Syncing work across devices

`sync-devices` solves a very specific, very common annoyance: you are working on a repository on one
machine, you are not ready to commit, and you want to continue on another machine.

The script **creates a git `.patch` file** that captures *every* local change in the current repository —
tracked and untracked alike — and writes it to a folder that is mirrored across your devices (a
cloud-synced folder, a Nextcloud/Dropbox directory, a Tailscale share, whatever you already use). On the
other machine you run the same script with `--apply`, and the patch is replayed onto the working tree.
Bringing changes from one PC to another therefore takes two short commands and no throwaway commits.

Under the hood it stashes everything with a timestamped message
(`git stash push -u -m "wip: sync <YYMMDDHHmmSS>"`, so repeated runs never collide) and exports the
stash with `git stash show -p -u`. Your changes stay safely in the stash on the source machine — restore
them with `git stash pop` — while the patch travels to the other device. The patch file is always called
`wip.patch` inside the sync folder.

**On Linux** the setup installs this command for you: `linux/setup.sh` runs `install_commands.sh`, which
copies everything in [`linux/commands/`](linux/commands/) into `~/.local/bin` and makes sure that
`~/.local/bin` is on your `PATH` by appending it to `~/.bashrc`. **It is therefore available as a plain
`sync-devices` command in every bash terminal**, from any directory, with no path prefix and no manual
setup.

```bash
# On the machine you are leaving — from inside the repository
sync-devices                       # writes ~/syncronizations/wip.patch
sync-devices ~/Nextcloud/sync      # …or into any folder you pass explicitly

# On the machine you are moving to — from inside the same repository
sync-devices --apply               # applies ~/syncronizations/wip.patch
sync-devices ~/Nextcloud/sync -a   # …or from the folder you pass explicitly
```

The sync folder is resolved in this order:

1. the positional `PATH` argument, whenever supplied (always wins);
2. the `SYNC_DEVICES_FOLDER` environment variable, when set;
3. `~/syncronizations` as a fallback.

**On Windows** the same tool ships as [`powershell/sync-devices.ps1`](powershell/sync-devices.ps1), with
identical behaviour and the same resolution order:

```powershell
.\sync-devices.ps1                 # writes ~/syncronizations/wip.patch
.\sync-devices.ps1 "D:\Sync"       # …or into a folder of your choice
.\sync-devices.ps1 -Apply          # applies the patch onto the working tree
.\sync-devices.ps1 "D:\Sync" -Apply
```

The PowerShell version writes the patch as UTF-8 without BOM and with LF endings, so patches created on
Windows apply cleanly on Linux and vice versa.

---

## Windows setup

**Prerequisites:** a clean Windows install with `winget` available (App Installer from the Microsoft
Store). Run the scripts from an elevated PowerShell prompt; a couple of steps (Chocolatey/FileZilla and
the Nsight Systems installer) will additionally prompt for confirmation on their own.

If script execution is blocked, allow it for the current session first:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 1. Base system — `setup.ps1`

```powershell
cd windows
.\setup.ps1
```

This installs, via `winget`:

- **System basics:** PowerShell 7, Vivaldi, Acrobat Reader, Bitwarden, 7-Zip, Greenshot, OBS Studio,
  Thunderbird, PowerToys, Nextcloud Desktop
- **Entertainment:** Spotify
- **Office and writing:** Microsoft Teams, Obsidian, LibreOffice
- **Development:** Chocolatey, Git, Docker Desktop, VS Code, Zed, Bruno, MongoDB Compass, draw.io,
  Temurin JDK 25, `fnm` (Node version manager), and `uv` for Python
- **Research:** JabRef, Tailscale, Zotero, AnyDesk, FileZilla (through Chocolatey), and NVIDIA Nsight
  Systems for GPU profiling (downloaded as an MSI and launched interactively)
- **AI:** Ollama
- **Messaging:** Telegram Desktop
- **Editing:** GIMP 3, Inkscape

It also configures your PowerShell profile: `posh-git` is installed and imported (branch/diff info in the
prompt) and `fnm env --use-on-cd` is wired in so Node versions switch automatically per directory.

### 2. Gaming — `gaming.ps1`

```powershell
.\gaming.ps1
```

This installs the launchers and the gaming-adjacent tooling: Steam, Epic Games Launcher, GOG Galaxy,
Battle.net, Playnite, Discord, RivaTuner Statistics Server (RTSS) and HWiNFO.

At the end the script prints the few things `winget` cannot install, which **must be downloaded
manually**:

- NVIDIA App — <https://www.nvidia.com/en-eu/software/nvidia-app/>
- Ryzen Master — <https://www.amd.com/en/products/software/ryzen-master.html>
- Trust GXT 155 mouse software — <https://support.trust.com/en/support/solutions/articles/9000240828-gxt-155-caldor-gaming-mouse-black-20411>

---

## Linux setup

**Target:** a clean Ubuntu install with GNOME (the theming, the GNOME extensions and the `dconf` import
assume GNOME Shell).

Everything is driven by [`linux/setup.sh`](linux/setup.sh). The script uses paths relative to the
repository root and refuses to run without root, so **run it with `sudo` from the top of the repository**:

```bash
git clone https://github.com/<your-user>/sh-utils.git
cd sh-utils
sudo bash ./linux/setup.sh [options]
```

### Flags

| Flag | Argument | Description |
| --- | --- | --- |
| `-h`, `--help` | — | Show the usage message and exit. |
| `-w`, `--work` | — | Enable the **work profile**: installs the GlobalProtect SAML VPN client aimed at Politecnico di Milano users (see below). |
| `-r`, `--robotics` | — | Enable the **robotics profile**: ROS 2 Jazzy, the NVIDIA container toolkit, Vulkan and NVIDIA Isaac Sim (full app + WebRTC livestream client + desktop launcher). |
| `-i`, `--isaac-sim-version` | `<version>` | Isaac Sim version to install. Allowed values: `6.0.0`, `5.1.0`, `5.0.0`, `4.5.0`. Default: `5.1.0`. Only meaningful together with `-r`. |

Examples:

```bash
sudo bash ./linux/setup.sh                          # plain desktop machine
sudo bash ./linux/setup.sh -w                       # desktop + work profile (VPN)
sudo bash ./linux/setup.sh -r                       # desktop + robotics stack (Isaac Sim 5.1.0)
sudo bash ./linux/setup.sh -w -r -i 6.0.0           # everything, Isaac Sim 6.0.0
```

With no flags you get the full desktop environment and nothing university- or robotics-specific.

### Work profile and the Politecnico di Milano VPN

> **If you are not a Politecnico di Milano student or member of staff, simply omit `-w`.** Nothing else
> in the setup depends on it, and the rest of the installation is completely unaffected.

`-w` / `--work` runs [`linux/work.sh`](linux/work.sh), which sets up a graphical client for the **Palo Alto
GlobalProtect VPN of Politecnico di Milano**. GlobalProtect at Polimi uses SAML/single sign-on, which the
stock Linux clients do not handle well, so the script:

- installs the GTK/WebKit dependencies needed for a browser-based SSO login
  (`python3-gi`, `gir1.2-gtk-3.0`, `gir1.2-webkit2-4.*`, `libgirepository-2.0-dev`, `libcairo2-dev`,
  `pkg-config`);
- installs [`gp-saml-gui`](https://github.com/dlenski/gp-saml-gui) as a `uv` tool;
- adds an `openvpn` shell alias pointing at the DEIB gateway, so connecting is a single word:

  ```bash
  openvpn   # → gp-saml-gui -P --gateway --clientos=Linux gp-deib-saml.vpn.polimi.it
  ```

  A browser window opens, you authenticate with your Polimi credentials, and the tunnel comes up.

The base setup already installs `network-manager-openconnect` and its GNOME integration, so the
OpenConnect backend the alias relies on is present regardless.

If your institution uses a different GlobalProtect gateway, changing the hostname in that one alias is
usually all that is needed.

### Robotics profile

`-r` / `--robotics` is a two-part installation:

1. **[`ros2.sh`](linux/ros2.sh)** — adds the ROS 2 apt source and installs **ROS 2 Jazzy**
   (`ros-jazzy-desktop`, `ros-jazzy-ros-base`, `ros-dev-tools`, `vision_msgs`, `ackermann_msgs`),
   **Nav2** (`navigation2`, `nav2-bringup`, the minimal TurtleBot assets and the Gazebo TurtleBot3
   packages), then clones **IsaacSim-ros_workspaces** into `~/programs`, resolves dependencies with
   `rosdep` and builds the `jazzy_ws` workspace with `colcon`.
2. **[`robotics.sh`](linux/robotics.sh)** — installs the **NVIDIA container toolkit** (pinned to
   `1.19.0-1`), configures Docker to use the NVIDIA runtime, installs Vulkan (`libvulkan1`), then
   downloads the **Isaac Sim WebRTC streaming client** (as an AppImage in `~/programs`, with its icon
   extracted) and the **full Isaac Sim standalone app** for the selected version. A
   `Isaac Sim WebRTC Client` launcher is installed into `~/.local/share/applications/`.

Note that the ROS workspace is cloned over SSH (`git@github.com:…`), so a working GitHub SSH key is
required for this part.

### What the base setup installs

Regardless of the flags, `setup.sh`:

- **Commands** — runs `install_commands.sh` (see [Commands installed on your PATH](#commands-installed-on-your-path)).
- **System basics** — `ca-certificates`, `curl`, `apt-transport-https`, `binutils`, `gnome-terminal`,
  `flatpak` (with Flathub added), `cmake`, `gnupg`, `gawk`, plus `gnome-tweaks`,
  `gnome-shell-extension-manager`, `gnome-themes-extra`, `gtk2-engines-murrine` and `sassc` for theming.
- **Shell** — [`ble.sh`](https://github.com/akinomyoga/ble.sh) for history-based autocompletion in bash,
  sourced from your `.bashrc`.
- **Apps** — Bitwarden, Vivaldi, Thunderbird, Spotify, LibreOffice, Telegram (snaps); Zotero, FileZilla,
  Tailscale, AnyDesk, Anytype, Claude Desktop; Bottles (Flatpak) for running Windows apps.
- **Development** — Git, Docker CE with the Compose and Buildx plugins
  ([`installation_scripts/docker.sh`](linux/installation_scripts/docker.sh)), VS Code (latest `.deb`
  straight from Microsoft) and `uv` for Python.
- **Appearance** — the Colloid and Orchis GTK themes (the latter also in a dock-tweaked `Orchis-DtD`
  variant) into `~/.themes`, and the Tela and Colloid icon themes in yellow into `~/.icons`, plus the
  Dynamic Wallpaper Editor Flatpak.
- **GNOME extensions** — installs the extensions listed in
  [`linux/extensions/extensions.txt`](linux/extensions/extensions.txt) (Top Bar Organizer, User Themes,
  Blur my Shell, Dash to Panel, Dash to Dock, ArcMenu) with `gnome-extensions-cli`, then restores their
  configuration by loading [`ext-settings.ini`](linux/extensions/ext-settings.ini) into
  `/org/gnome/shell/extensions/` with `dconf`. This is what makes the desktop look identical on every
  machine.
- **Discord auto-updater** — Discord has no apt repository, so
  [`installation_scripts/discord.sh`](linux/installation_scripts/discord.sh) is copied to `~/programs/`
  and registered as a GNOME autostart entry: at every login it checks Discord's download API and, when a
  new `.deb` exists, opens a small terminal to install it.
- **Docker permissions** — creates the `docker` group and adds your user to it.

To re-export your GNOME extension configuration after tweaking it (so the next machine inherits it):

```bash
dconf dump /org/gnome/shell/extensions/ > ./linux/extensions/ext-settings.ini
```

### After the setup

- **Log out and back in** (or reboot). This is needed for the `docker` group membership, for the GNOME
  extensions and for the new `PATH` to take effect.
- Open **GNOME Tweaks** and select the freshly installed theme and icon set — the files are in place, but
  which one is active remains a personal choice.
- The first Discord update runs automatically ~10 seconds after your next login and will ask for your
  password.

---

## Headless / server setup

[`linux/server.sh`](linux/server.sh) is the stripped-down variant for machines without a desktop —
home servers, remote workstations, lab boxes. Run it the same way, from the repository root:

```bash
sudo bash ./linux/server.sh
```

It installs only the essentials: build/network basics, OpenSSH server, Git, Docker (with the user added
to the `docker` group), Tailscale for remote access, `uv`, AnyDesk, and the `~/programs` directory. No
themes, no GNOME extensions, no desktop applications.

---

## Commands installed on your PATH

[`linux/install_commands.sh`](linux/install_commands.sh) — called automatically as the very first step of
`setup.sh` — installs every file in [`linux/commands/`](linux/commands/) into `~/.local/bin`, owned by
your user and executable, and appends `export PATH="$HOME/.local/bin:$PATH"` to your `.bashrc` if it is
not already there. **The result is that these are ordinary commands in every bash terminal**:

| Command | Description |
| --- | --- |
| [`sync-devices`](linux/commands/sync-devices) | Create or apply a `wip.patch` to move uncommitted work between devices. See [Syncing work across devices](#syncing-work-across-devices). Run `sync-devices --help` for the usage summary. |
| [`update_system`](linux/commands/update_system) | Update everything in one go: `apt-get update && apt-get upgrade`, `snap refresh` and `flatpak update`. |

Adding your own is a matter of dropping an executable file into `linux/commands/` and re-running
`sudo bash ./linux/install_commands.sh` from the repository root.

---

## Extra PowerShell utilities

These live in [`powershell/`](powershell/) and are not called by `setup.ps1`; run them when you need them.

- **[`sync-devices.ps1`](powershell/sync-devices.ps1)** — the Windows counterpart of `sync-devices`,
  described [above](#syncing-work-across-devices).
- **[`disks.ps1`](powershell/disks.ps1)** — creates the standard folder layout I use on a secondary data
  disk (`code`, `repositories`, `research`, `data`, `data/games`, `data/cloud`). `cd` to the target drive
  first, then run it.
- **[`poetry.ps1`](powershell/poetry.ps1)** — points Poetry's virtualenvs at a folder of your choice,
  keyed by Python version, so several Python versions can coexist cleanly. It sets the user-level
  `POETRY_BASE` and `POETRY_HOME` environment variables and appends
  `%POETRY_BASE%%PYTHON_VERSION%\bin` to the user `Path`. Requires `PYTHON_VERSION` to already be set.

  ```powershell
  .\poetry.ps1 "D:\Data"            # apply
  .\poetry.ps1 "D:\Data" -DryRun    # show what would change
  .\poetry.ps1 "D:\Data" -Check     # only print the current values
  ```

---

## Notes and caveats

- **Always run the Linux scripts from the repository root.** They reference their helpers as
  `./linux/...`, so `cd linux && sudo bash setup.sh` will not find them.
- **The scripts are not fully idempotent.** They are written for a clean install. Re-running `setup.sh`
  on a configured machine mostly works (apt/snap/winget skip what is present), but a few steps — cloning
  `ble.sh`, appending lines to `.bashrc`, `groupadd docker` — will complain or duplicate entries.
- **`~` under `sudo`.** Some steps append to `~/.bashrc` while running as root; depending on your `sudo`
  configuration that may resolve to root's home rather than yours. If `ble.sh` or the `openvpn` alias
  does not show up in a new terminal, copy the corresponding line into your own `~/.bashrc`.
- **Pinned versions.** Anytype, the NVIDIA container toolkit and Nsight Systems are pinned to specific
  versions/URLs, and Isaac Sim accepts a fixed set of versions. Bump them in the scripts as new releases
  land.
- **This is a personal setup.** The application lists are mine. If you fork this, the package lists in
  `windows/setup.ps1`, `windows/gaming.ps1` and `linux/setup.sh`, plus
  `linux/extensions/extensions.txt`, are the files you will want to edit first.

---

## License

This repository is released under the [PolyForm Noncommercial License 1.0.0](LICENSE) — a permissive
licence for everything *except* making money with it.

**You may**, for any noncommercial purpose:

- **Use** the scripts on your own machines, as-is.
- **Copy and redistribute** them, including a modified version.
- **Fork and modify** them freely — swap the package lists, change the themes, rewrite whatever you like.
- Use them inside a **charity, school, university, public research body, public health/safety
  organisation or government institution**: that counts as noncommercial regardless of how the
  organisation is funded.
- Use them for **personal study, hobby projects, experiments and private entertainment**.

**You may not**:

- Use them for **commercial purposes** — anything done with an anticipated commercial application,
  including internal use at a for-profit company, consulting work billed to a client, bundling them into
  a paid product or service, or selling them in any form.
- **Sublicense or transfer** your licence to anyone else. Everyone who wants to use this code gets their
  licence directly from these same terms, not from you.

**You must** keep a copy of the licence (or a link to it) with any copy of the code you pass on.

There is **no warranty**: the scripts install packages, add apt sources and change system configuration
on the machines you run them on, and they come as-is, with the licensor accepting no liability for what
happens as a result.

If you want to use any of this commercially, ask me first — the licence explicitly leaves the licensor
free to grant other terms.
