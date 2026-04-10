# Mailcow Customization & Branding Guide

This document outlines the safe paths for branding and identity work in this fork.

## Branding Boundary

To maintain a clean sync path with upstream, follow these rules for customizations:

### 1. Logo and UI Branding
- **Custom Logos**: Place your custom logos in `data/conf/sogo/`.
    - `custom-fulllogo.svg` / `custom-fulllogo.png`
    - `custom-shortlogo.svg`
- **Custom CSS**: Use `data/web/css/build/0081-custom-mailcow.css` for UI overrides. This file is ignored by git in the default configuration to prevent server-specific UI drift from entering the fork unless explicitly tracked.

### 2. Postfix & Dovecot Overrides
- **Postfix**: Use `data/conf/postfix/main.cf.local`. This is where server-specific hostnames and DNSBL settings should live.
- **Dovecot**: Use `data/conf/dovecot/extra.conf`.

### 3. BIMI and Sender Identity
- **VMC Certificates**: Should be placed in `data/assets/ssl/` if used for the main identity, or a custom subdirectory. Ensure they are NOT tracked in git.
- **BIMI Logo**: Should be a square SVG (Tiny 1.2 profile) hosted on a public URL. Place your source SVG in `data/web/branding/` to track it in your fork.
- **UI Customization**: Use `data/web/templates/custom/` to override Mailcow's web interface templates safely.

> [!IMPORTANT]
> **BIMI Readiness**: To enable BIMI, your DNS must have a DMARC record with a policy of `p=quarantine` or `p=reject`.
> Example DMARC record: `v=DMARC1; p=quarantine; pct=100; rua=mailto:admin@scenarix.online`

### 4. SSL Certificates
- Certificates are managed by Certbot and synced via `/etc/letsencrypt/renewal-hooks/deploy/mailcow-sync.sh`.
- Do NOT commit certificates to the repository.

## Upstream Sync Workflow

To keep this fork aligned with Mailcow official:
1. `git fetch upstream`
2. `git merge upstream/master`
3. Resolve conflicts (preferring upstream for core files, and keeping your `.local` files).

## Tracked vs. Local
| File Type | Tracked in Fork? | Location |
| :--- | :--- | :--- |
| Core Logic | Yes | `data/web/inc/...` |
| Safe Templates | Yes | `data/web/templates/custom/...` |
| Branding Assets | Yes | `data/web/branding/...` |
| Server Secrets | **NO** | `mailcow.conf`, `*.pem` |
| Local Overrides | Optional | `*.local` |

## Branding Bootstrap

This fork includes a helper script to quickly apply branding from disk to the running Mailcow instance.

1. Place your `logo.png` in `data/web/branding/`.
2. Run the bootstrap script:
   ```bash
   ./helper-scripts/apply-branding.sh
   ```
This will inject the logo into Redis and update the Mailcow UI immediately.
