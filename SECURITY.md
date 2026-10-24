# Security

## API keys

The repository and installer do not contain an AgentRouter API key. Each user
connects their own account through DrCode's built-in `/connect` dialog. OpenCode
stores the credential in DrCode's dedicated local SQLite database under
`~/.local/share/drcode/data/`.

The launcher does not export the key to shell tools or write it to project
configuration. Never paste a key into an issue or pass it as a command-line
argument. Revoke the key in AgentRouter immediately if it may have been exposed.

## Reviewing the installer

Clone the repository, inspect the installer, and then run it:

```bash
git clone https://github.com/DreyzeDev/drcode
cd drcode
less install.sh
bash install.sh
```

## Reporting a vulnerability

Do not publish credentials or an active exploit in a public issue. Contact the
repository owner privately through the security reporting options available on
GitHub.
