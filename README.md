<h1 align="center">DrCode</h1>

<p align="center">
  <strong>Agentic coding assistant for Linux.</strong><br>
  Powered by <a href="https://opencode.ai/v2/docs/">OpenCode V2</a> and configured for AgentRouter coding models.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Linux-0e1111?style=flat-square&amp;logo=linux&amp;logoColor=white" alt="Linux">
  <img src="https://img.shields.io/badge/engine-OpenCode_V2-3dd68c?style=flat-square" alt="OpenCode V2">
  <img src="https://img.shields.io/badge/license-MIT-0e1111?style=flat-square" alt="MIT License">
</p>

DrCode is a small, security-conscious Linux distribution layer around OpenCode. It installs an isolated launcher, a dedicated configuration, a green terminal theme, and AgentRouter model aliases without embedding API keys.

## Features

- OpenCode's terminal coding workflow and tools.
- AgentRouter models including GPT-6.1 Sol, GPT-6 Astra, and GPT-5.6 Sol.
- Dedicated configuration and session database, separate from a regular OpenCode setup.
- API key stored in a local file with mode `600`, not committed or exported by the launcher.
- Short model aliases: `sol`, `astra`, and `gpt5`.
- User-local installation: root access is not required.
- Linux x64, x64 baseline, and ARM64 support on glibc and musl systems.

Model availability and usage limits depend on the connected AgentRouter account.

## Install

### One command

```bash
curl -fsSL https://raw.githubusercontent.com/DreyzeDev/drcode/main/install.sh | bash
```

The installer downloads the latest official OpenCode V2 Linux binary over HTTPS and places all DrCode files under the current user account. It does not use `sudo` and does not modify shell startup files.

For a review-first installation, see [Security](SECURITY.md#reviewing-the-installer).

### Configure AgentRouter

After installation, enter your API key in the hidden prompt:

```bash
drcode setup
```

The key is stored at `~/.config/drcode/agentrouter.key` with permissions `600`. It is never part of this repository.

### Start DrCode

Run DrCode in the current directory:

```bash
drcode
```

Or open a specific project:

```bash
drcode ~/code/my-project
```

If `~/.local/bin` is not in `PATH`, add it to your shell configuration:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
# Full terminal interface
drcode

# Minimal interface
drcode mini

# Non-interactive prompt
drcode run "Explain this repository"

# Continue the previous session
drcode --continue

# Select models with aliases
drcode --model sol
drcode --model astra
drcode --model gpt5

# Verify the installation without revealing secrets
drcode doctor
```

OpenCode commands, tools, sessions, permissions, and project configuration remain available. See the [OpenCode V2 documentation](https://opencode.ai/v2/docs/) for the full reference.

## Files

| Path | Purpose |
| --- | --- |
| `~/.local/bin/drcode` | DrCode launcher. |
| `~/.local/share/drcode/bin/opencode` | Official OpenCode engine. |
| `~/.local/share/drcode/data/drcode.db` | Dedicated session database. |
| `~/.config/drcode/opencode/` | OpenCode and terminal configuration. |
| `~/.config/drcode/agentrouter.key` | Local AgentRouter key, mode `600`. |

Interactive and model-execution commands use a private OpenCode server by default, preventing another OpenCode installation from supplying a different global configuration. Explicit `--server` and `--standalone` options are respected.

## Updating

Update the launcher, configuration assets, and OpenCode engine:

```bash
drcode self-update
```

Existing `opencode.json`, `cli.json`, and `AGENTS.md` files are preserved. The managed DrCode theme and launcher are refreshed.

## Uninstalling

Remove the launcher and engine while preserving configuration and the API key:

```bash
drcode self-uninstall
```

Remove everything, including configuration, sessions, and the API key:

```bash
drcode self-uninstall --purge
```

## Development

Run the checks locally:

```bash
bash -n install.sh uninstall.sh bin/drcode tests/test-installer.sh
python3 -m json.tool config/opencode.json >/dev/null
python3 -m json.tool config/cli.json >/dev/null
python3 -m json.tool assets/drcode.json >/dev/null
bash tests/test-installer.sh
```

The installer supports local and offline testing through `DRCODE_SOURCE_DIR` and `DRCODE_ENGINE_ARCHIVE`. See `bash install.sh --help` for details.

## Attribution

DrCode is an independent community configuration and installer built on [OpenCode](https://github.com/anomalyco/opencode), which is distributed under the MIT License. It is not an official OpenCode or AgentRouter release.

## License

DrCode's original installer and configuration files are available under the [MIT License](LICENSE). OpenCode and other downloaded components retain their own licenses and notices.
