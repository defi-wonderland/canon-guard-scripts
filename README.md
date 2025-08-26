# Canon Guard Scripts

### Overview
Scripts to deploy and operate Canon Guard components against a Safe: guard setup, action builders, hubs, and utility flows. Scripts are interactive and guide you via prompts.

### Prerequisites
- Foundry installed (forge, cast)
- Node.js + pnpm (for npm scripts)
- An RPC endpoint with archive access recommended

### Environment (.env)
Copy the example file and fill in your values:

```
cp .env.example .env
```

### Import the signer
Import the account used by scripts (keystore name must match the npm scripts):

```
cast wallet import canon-guard-tester --interactive
```

You can verify with:
```
cast wallet list
```

### Install
```
pnpm install
```

### Running scripts

| Command | Description |
| --- | --- |
| `pnpm run setupGuard` | Deploy and configure Canon Guard on your Safe |
| `pnpm run removeGuard` | Remove Canon Guard from your Safe |
| `pnpm run isGuardSetup` | Check whether a guard is configured |
| `pnpm run queueTransaction` | Queue an action builder into the entrypoint |
| `pnpm run signTransaction` | Approve (sign) a queued action in the Safe |
| `pnpm run executeTransaction` | Execute a queued action when ready |
| `pnpm run approveTransaction` | Approve an action builder for a duration |
| `pnpm run approveHub` | Approve an action hub for a duration |
| `pnpm run deploySimpleAction` | Create arbitrary call(s) via `SimpleActions` builder |
| `pnpm run deploySimpleTransfer` | Create ERC20 transfer(s) via `SimpleTransfers` builder |
| `pnpm run deployCappedTokenTransferHub` | Deploy a Capped Token Transfers Hub |
| `pnpm run deployCappedTokenTransfer` | Create a capped transfer action from a Hub |

Each command is interactive and will optionally guide you to queue and/or approve in your Safe.
