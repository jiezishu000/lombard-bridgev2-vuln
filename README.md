# Lombard Finance BridgeV2 — PayloadSpent State Ordering Vulnerability

**Severity:** Medium
**Donate:** EVM: `0x1b6C028199952eE1a8079dB02acfFCCfC881f76d`

---

In BridgeV2, `payloadSpent` is set to `true` BEFORE `_withdraw()`.
If `_withdraw()` reverts, the payload is permanently stuck.

## Root Cause
CEI violation:
```
$.payloadSpent[payload.id] = true;  // BEFORE withdraw
result = _withdraw($, chainId, payload.msgBody);  // MAY REVERT
```

## Impact
- Cross-chain LBTC permanently stuck
- No admin recovery
- Donations: `0x1b6C028199952eE1a8079dB02acfFCCfC881f76d`
