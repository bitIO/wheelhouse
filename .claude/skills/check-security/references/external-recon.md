# External recon of your own app

Run this only against domains and apps you own or are authorized to test. The goal is to see what an outside attacker sees.

1. **Subdomains**: `curl -s "https://crt.sh/?q=%25.<domain>&output=json"`, extract the names and dedupe them with `sort -u`. Cross-check against the repo's deploy docs.
2. **Tech fingerprint**: read it from the response headers (`curl -sI <url>`).
3. **Security headers**: `curl -sI <url>`. Flag a missing CSP, HSTS, X-Frame-Options or Referrer-Policy.
4. **Public endpoints**: probe the documented paths (`/api`, `/admin`, `/health`, `/graphql`) for unexpected 200s, auth bypass or information disclosure.
5. **Leaked credentials**: check the repo's own git history and committed config for tokens. Report anything you find; never use it.
6. **Dangling DNS**: resolve each subdomain with `dig` and flag CNAMEs that point at deprovisioned cloud resources (a takeover vector).
7. **Dependency posture**: `pnpm audit` / `npm audit`, and look for committed config or env files in the public repo.

Report: severity, evidence (the actual response or output), exploit path, fix.
