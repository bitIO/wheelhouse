# Installing a release

wheelhouse ships versioned releases two ways: as a **Claude Code plugin** and as a **one-line installer** that covers Claude Code, OpenCode and Pi. Both come from the same release. Cloning the repo (see the [README](../README.md#install)) is still the way to work on wheelhouse itself; cutting a release is in [release.md](release.md).

| | Claude Code plugin | One-line installer | Git clone |
|---|---|---|---|
| For | Claude Code users | Anyone, any of the three tools | Contributors |
| Needs | Claude Code 2.1.275+ | `bash`, `curl`, `tar` | `git` |
| Updates | `/plugin marketplace update wheelhouse` or auto-update | Re-run the line | `git pull` |
| Commands look like | `/wheelhouse:lead` | `/lead` | `/lead` |

Pick one per tool. Installing both the plugin and the installer for Claude Code gives you every skill twice (`lead` and `wheelhouse:lead`).

## Claude Code plugin

Inside Claude Code:

```text
/plugin install wheelhouse --marketplace bitIO/wheelhouse
```

That adds the `wheelhouse` marketplace and installs the plugin for your user. The two-step form, and the per-project form, from a terminal:

```bash
claude plugin marketplace add bitIO/wheelhouse
claude plugin install wheelhouse@wheelhouse                    # for your user
claude plugin install wheelhouse@wheelhouse --scope project    # only this repo; commit .claude/settings.json to share it
```

- **Names are namespaced.** Workflows run as `/wheelhouse:lead`, `/wheelhouse:story`…, and the agents are `wheelhouse:investigator` and `wheelhouse:reviewer`.
- **Updates** reach you when a new version is released. Run `/plugin marketplace update wheelhouse`, or turn on **Enable auto-update** for the marketplace under **Marketplaces** in `/plugin`.
- **Remove it** with `claude plugin uninstall wheelhouse@wheelhouse`.

## One-line installer

```bash
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash
```

[`setup/get.sh`](../setup/get.sh) downloads the latest release into `~/.local/share/wheelhouse` and runs `setup/install.sh` from there, so everything in the [README](../README.md#install) applies. Arguments after `bash -s --` go to the installer:

```bash
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash -s -- --project ~/dev/my-app
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash -s -- --claude
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | WHEELHOUSE_VERSION=v0.1.0 bash
```

- **Update**: run the same line again, with the same arguments. It replaces the download in place, so the installer's symlinks keep working and pick up the new version. Project installs are copies: commit the updated folders in that repo.
- **Uninstall**: `~/.local/share/wheelhouse/setup/install.sh --uninstall`, then delete `~/.local/share/wheelhouse`.
- **Read it first** if you don't pipe scripts into your shell (our own `skill-advisor` rates `curl | bash` 🟡):

  ```bash
  curl -fsSLO https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh
  less get.sh && bash get.sh
  ```

| Variable | Default | Use |
|---|---|---|
| `WHEELHOUSE_VERSION` | latest release | Pin a tag such as `v0.1.0` |
| `WHEELHOUSE_HOME` | `~/.local/share/wheelhouse` | Where the release is unpacked |
| `WHEELHOUSE_URL` | `https://github.com/bitIO/wheelhouse` | A fork |

## Why not Homebrew?

A formula installs into Homebrew's prefix and must not write into `~/.claude` or `~/.config/opencode`, so users would still have to run the installer afterwards. It would also need a separate tap repository. The one-line installer gets the same result in one step.
