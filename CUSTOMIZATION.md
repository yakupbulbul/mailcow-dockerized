# Sender Identity & Outgoing Mail Branding Guide

This document covers real sender identity infrastructure for `scenarix.online`.

> [!IMPORTANT]
> **Uploading a logo in any app does NOT make it appear in Gmail or other inbox clients.**
> Real sender logo/profile display in email clients requires domain-level infrastructure.
> This guide documents only that real path.

---

## What Controls Sender Logo / Profile Photo in Email Clients?

Sender logo/avatar display (e.g., in Gmail) is controlled at the **domain and DNS level**, not at the mail app level.

The supported standards are:

| Standard | What it does |
| :--- | :--- |
| **SPF** | Verifies the sending server is authorized |
| **DKIM** | Cryptographically signs each outgoing message |
| **DMARC** | Tells receivers what to do if SPF/DKIM fail |
| **BIMI** | Points email clients to a verified sender logo |

All four must be correctly configured before sender logo display is possible in any client.

---

## Current Status: `scenarix.online`

### SPF
- **Record present**: `v=spf1 mx a -all`
- **Status**: ✅ Basic SPF in place. The `-all` hard-fail policy is good.

### DKIM
- **Status**: ⚠️ No public DKIM DNS record found at common selectors (`mail`, `dkim`, `s1`, `default`).
- **Action Required**: Generate a DKIM key in Mailcow admin → Domains → Edit → DKIM, then publish the given TXT record to DNS.

### DMARC
- **Status**: ❌ No DMARC record found at `_dmarc.scenarix.online`.
- **Action Required**: Add a DMARC TXT record. Start with `p=none` for monitoring, then tighten.
- **BIMI Requires**: `p=quarantine` or `p=reject` with `pct=100`.

### BIMI
- **Status**: ❌ No BIMI record found at `default._bimi.scenarix.online`.
- **Action Required**: All of the above must be done first. See steps below.

---

## Step-by-Step: Real Sender Logo Readiness

### Step 1 — Ensure DKIM is generated and published

1. Go to Mailcow admin → Configuration → Domains → `scenarix.online` → Edit
2. Under **DKIM**, generate a key (2048-bit recommended)
3. Copy the public key shown
4. Add this DNS TXT record (the selector name is shown in Mailcow, e.g. `dkim`):
   ```
   dkim._domainkey.scenarix.online  TXT  "v=DKIM1; k=rsa; p=<your-public-key>"
   ```
5. Verify: `dig TXT dkim._domainkey.scenarix.online`

### Step 2 — Add DMARC record

Start in monitoring/reporting mode:
```
_dmarc.scenarix.online  TXT  "v=DMARC1; p=none; rua=mailto:admin@scenarix.online"
```

Once you confirm Mailcow is passing DKIM+SPF cleanly (check the rua reports), upgrade to:
```
_dmarc.scenarix.online  TXT  "v=DMARC1; p=quarantine; pct=100; rua=mailto:admin@scenarix.online"
```

> [!IMPORTANT]
> BIMI **requires** `p=quarantine` or `p=reject`. The `p=none` policy will not activate BIMI.

### Step 3 — Prepare a BIMI-compliant logo

Requirements:
- Square SVG, **Tiny 1.2 profile** (not regular SVG)
- Hosted at a stable public HTTPS URL
- Convert your logo before use: https://bimigroup.org/svg-conversion-tools/
- Place the source file for tracking at `data/web/branding/bimi-logo-source.svg`

### Step 4 — Add the BIMI DNS record (no VMC required for basic support)

```
default._bimi.scenarix.online  TXT  "v=BIMI1; l=https://scenarix.online/bimi/logo.svg"
```

Host your SVG at that public HTTPS path (e.g., via Nginx or any CDN).

To also get the **blue verified checkmark** in Gmail, you need a **VMC (Verified Mark Certificate)** — this is a paid certificate from an approved CA (DigiCert, Entrust). Add the `a=` authority field:
```
"v=BIMI1; l=https://scenarix.online/bimi/logo.svg; a=https://scenarix.online/bimi/vmc.pem"
```

### Step 5 — Verify

- https://bimigroup.org/bimi-generator/ — Check BIMI readiness
- https://dmarcian.com/dmarc-inspector/ — Check DMARC
- https://dkimvalidator.com/ — Send a test email to validate DKIM signing

---

## What Does NOT Control Inbox Sender Logo

- Uploading a logo in Mailcow UI admin → this only changes the Mailcow **web interface** logo
- Any app-side "sender photo" setting
- Redis `MAIN_LOGO` key — this controls the Mailcow admin panel header only

Do not confuse Mailcow UI branding with outgoing sender identity.

---

## Upstream Sync Workflow

To keep this fork aligned with upstream Mailcow:
```bash
git fetch upstream
git merge upstream/master
```

Resolve conflicts preserving your `.local` files and this guide.

---

## Postfix Local Overrides

Your server-specific Postfix settings (DNSBL, myhostname) are in:
```
data/conf/postfix/main.cf.local
```

This file stays **local only** (untracked) and is not committed to the fork.
It is not overwritten by Mailcow updates.
