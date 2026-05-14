# Lombard BridgeV2 — Remediation Guide

**Severity:** Medium (CEI Violation — Permanent Fund Freezing)
**Affected:** `BridgeV2.handlePayload()`

---

## The Bug

In `BridgeV2.handlePayload()` at approximately line 593:

```solidity
// BUG: State change BEFORE external interaction
$.payloadSpent[payload.id] = true;

// External call that can revert
result = _withdraw($, chainId, payload.msgBody);
```

## The Fix

```solidity
// First: perform the external interaction
result = _withdraw($, chainId, payload.msgBody);

// Then: update state (Effects after Interactions)
$.payloadSpent[payload.id] = true;
```

## Verification Checklist

After applying the fix:

- [ ] `payloadSpent` is only set after successful `_withdraw`
- [ ] If `_withdraw` reverts, the entire transaction reverts
- [ ] Users can retry failed withdrawals (payload not marked spent)
- [ ] No replay attacks possible (standard CEI protection)
- [ ] All existing tests pass
- [ ] No storage collision with upgradeable proxy pattern

## Hardening Recommendations

1. **Add a maximum gas limit check** before `_withdraw` to prevent out-of-gas scenarios
2. **Emit a `WithdrawalAttempted` event** before the external call (Checks-Effects-Interactions-Monitoring pattern)
3. **Consider a withdrawal queue** with admin override capability for edge cases
4. **Add integration tests** that simulate failed withdrawals to verify the fix

---

## Donation

If this guide saved you time or protected your protocol:

**Wallet:** `0x1b6C028199952eE1a8079dB02acfFCCfC881f76d`
**Network:** Polygon (USDT preferred)
**Suggested:** 1 USDT

---

*Always follow the CEI pattern in your Solidity code.*
