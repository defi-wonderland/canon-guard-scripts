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

Run with: `pnpm run <command>`

| Command | Description |
| --- | --- |
| `setupGuard` | Deploy and configure Canon Guard on your Safe |
| `removeGuard` | Remove Canon Guard from your Safe |
| `isGuardSetup` | Check whether a guard is configured |
| `queueTransaction` | Queue an action builder into the entrypoint |
| `signTransaction` | Approve (sign) a queued action in the Safe |
| `executeTransaction` | Execute a queued action when ready |
| `approveTransaction` | Approve an action builder for a duration |
| `approveHub` | Approve an action hub for a duration |
| `deploySimpleAction` | Create arbitrary call(s) via `SimpleActions` builder |
| `deploySimpleTransfer` | Create ERC20 transfer(s) via `SimpleTransfers` builder |
| `deployCappedTokenTransferHub` | Deploy a Capped Token Transfers Hub |
| `deployCappedTokenTransfer` | Create a capped transfer action from a Hub |

Each command is interactive and will optionally guide you to queue and/or approve in your Safe.
