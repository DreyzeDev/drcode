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
- AgentRouter models (GPT-6.1 Sol, GPT-6 Astra, GPT-5.6 Sol) and OxionAI models (Claude Opus 5.5, GPT-5.5 Pro, GPT-5.6 Sol, GLM 5.3, Kimi K3 and more).
- Dedicated configuration and session database, separate from a regular OpenCode setup.
- Built-in connection dialogs: every user enters their own API key locally.
- Short model aliases: `sol`, `astra`, `gpt5`, `oxion-sol`, `oxion-astra`, `oxion-gpt5`, `oxion-opus`.
- User-local installation: root access is not required.
- Linux x64, x64 baseline, and ARM64 support on glibc and musl systems.

Model availability and usage limits depend on the connected AgentRouter account.

## Install

One command (Linux, user-local, no `sudo`):

```bash
curl -fsSL https://raw.githubusercontent.com/DreyzeDev/drcode/main/install.sh | bash
```

Then add the launcher to your PATH if needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Review-first installation

```bash
git clone https://github.com/DreyzeDev/drcode
cd drcode
bash install.sh
```

The installer downloads the branded DrCode engine release over HTTPS (falling back to the official OpenCode V2 Linux binary) and places all DrCode files under the current user account. It does not use `sudo` and does not modify shell startup files.

For a review-first installation, see [Security](SECURITY.md#reviewing-the-installer).

### Start DrCode

Run DrCode in the current directory:

```bash
drcode
```

Or open a specific project:

```bash
drcode ~/code/my-project
```

Enter your prompt — if no integration is connected, the connection window opens immediately:
choose **AgentRouter (DrCode)** and/or **OxionAI** and enter the Base URL (`https://agentrouter.org/v1` / `https://oxionai.com/v1`)
and **your own API key**. Then open `/models` and choose a model.

Base URLs are preconfigured; only the key belongs to the user. If the connection window was dismissed,
reopen it with `/connect`. Credentials stay in DrCode's dedicated local database and are never stored in this repository.

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

# Select models with aliases (AgentRouter)
drcode --model sol
drcode --model astra
drcode --model gpt5

# OxionAI
drcode --model oxion-sol
drcode --model oxion-astra
drcode --model oxion-gpt5

# Verify the installation without revealing secrets
drcode doctor
```

OpenCode commands, tools, sessions, permissions, and project configuration remain available. See the [OpenCode V2 documentation](https://opencode.ai/v2/docs/) for the full reference.

## Files

| Path | Purpose |
| --- | --- |
| `~/.local/bin/drcode` | DrCode launcher. |
| `~/.local/share/drcode/bin/opencode` | DrCode engine (or official OpenCode fallback). |
| `~/.local/share/drcode/data/drcode.db` | Dedicated sessions and provider accounts. |
| `~/.config/drcode/opencode/` | OpenCode and terminal configuration. |

Interactive and model-execution commands use a private OpenCode server by default, preventing another OpenCode installation from supplying a different global configuration. Explicit `--server` and `--standalone` options are respected.

## Updating

Update the launcher, configuration assets, and OpenCode engine. GitHub CLI must be authenticated with an account that can access the private repository:

```bash
drcode self-update
```

Existing `opencode.json`, `cli.json`, and `AGENTS.md` files are preserved. The managed DrCode theme and launcher are refreshed.

## Uninstalling

Remove the launcher and engine while preserving configuration, sessions, and connected accounts:

```bash
drcode self-uninstall
```

Remove everything, including configuration, sessions, and connected accounts:

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
