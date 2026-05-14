# Lombard Finance BridgeV2 — CEI Vulnerability Disclosure

**Severity:** Medium — Permanent Freezing of Cross-Chain LBTC

**Donate:** `0x1b6C028199952eE1a8079dB02acfFCCfC881f76d` (Polygon USDT)

---

## The Bug

In `BridgeV2.handlePayload()`, `$.payloadSpent[payload.id] = true` is set **BEFORE** `_withdraw()`.
If `_withdraw()` reverts (out-of-gas, recipient rejection, rate limit), the payload is permanently
marked as spent but funds were never delivered. Result: LBTC stuck forever.

## Contents

- `index.html` — Full article with technical details (GitHub Pages)
- `FIX.md` — Remediation guide with verification checklist
- `PoC/` — Solidity proof of concept with Foundry tests

## Quick Fix

```diff
- $.payloadSpent[payload.id] = true;
- result = _withdraw($, chainId, payload.msgBody);
+ result = _withdraw($, chainId, payload.msgBody);
+ $.payloadSpent[payload.id] = true;
```

## Donate

If this disclosure helped protect your protocol, send 1 USDT (Polygon) to:

```
0x1b6C028199952eE1a8079dB02acfFCCfC881f76d
```

---

*Always follow Checks-Effects-Interactions in your Solidity code.*
