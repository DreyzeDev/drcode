# Security

## API keys

The repository and installer do not contain an AgentRouter API key. `drcode setup`
asks for the key in a hidden terminal prompt and stores it locally at:

```text
~/.config/drcode/agentrouter.key
```

The file is created with mode `600`. OpenCode reads it through a file reference,
so the launcher does not export the key to the environment inherited by shell
tools.

Never commit this file, paste it into an issue, or pass it as a command-line
argument. Revoke the key in AgentRouter immediately if it may have been exposed.

## Reviewing the installer

Instead of piping the installer directly to Bash, download and inspect it first:

```bash
curl -fsSLO https://raw.githubusercontent.com/DreyzeDev/drcode/main/install.sh
less install.sh
bash install.sh
```

## Reporting a vulnerability

Do not publish credentials or an active exploit in a public issue. Contact the
repository owner privately through the security reporting options available on
GitHub.
