# Fix: Google "Someone Else Might Be Trying to Access Your Account" Error

## 🔴 The Problem

When trying to sign in to the new ScrumAI.org agent accounts for the first time, Google blocks the login with:

> "It looks like someone else might be trying to access your Google Account.
> For your protection, you can't sign in right now."

This happens because:
1. The accounts were **just created** and have **never been signed into**
2. Google's abuse detection flags first-time logins from "unfamiliar" devices
3. Multiple rapid sign-in attempts (switching between 6 accounts) triggers rate limiting

---

## ✅ Fix (Admin Console Method — Do This First)

### Step 1: Unlock the Account in Google Admin Console

1. Go to **https://admin.google.com** (sign in as the Workspace super admin — likely `jeff.sutherland@scrumai.org`)
2. Navigate to **Directory → Users**
3. Click on the blocked account (e.g., `agent.saturday@scrumai.org`)
4. Look for a banner or option that says **"User is locked"** or **"Unlock"**
   - If you see it, click **Unlock** or **Reset sign-in cookies**
5. While you're there:
   - Click **Security** (left sidebar for that user)
   - Check if "Sign-in challenge" is active — if so, **dismiss** it
   - Click **Reset password** and set a new temporary password
   - **UNCHECK** "Ask user to change their password at next sign-in"

### Step 2: Reduce Google's Security Level Temporarily

1. In Admin Console → **Security → Authentication → Login challenges**
   - Or: **Security → Overview → Less secure app access** (if available)
2. Set **Login challenge** to a lower level temporarily
3. In **Security → Access and data control → Less secure apps**:
   - If this option exists, **allow** it for the organizational unit containing agent accounts

### Step 3: Wait 15-30 Minutes

Google's lockout is usually **time-based**. After unlocking in Admin Console:
- Wait at least **15 minutes** before trying to sign in again
- Do NOT keep retrying — each failed attempt extends the lockout

### Step 4: Sign In One Account at a Time

1. Open a **fresh incognito/private window** (NOT the same browser session)
2. Go to `https://accounts.google.com`
3. Sign in with ONE account (e.g., `agent.saturday@scrumai.org`)
4. If prompted for verification:
   - As admin, you may be able to verify via the Admin Console
   - Or use the recovery phone/email you set on the account
5. **Complete initial sign-in fully** before moving to the next account
6. **Wait 5 minutes between each account sign-in**

---

## 🛡️ Alternative: Skip App Passwords, Use Admin SMTP Relay

If individual sign-ins remain blocked, there's a **much easier** path:

### Set Up Google Workspace SMTP Relay (One Config, All Accounts)

1. Admin Console → **Apps → Google Workspace → Gmail → Routing**
2. Under **SMTP relay service**, click **Configure** or **Add another rule**
3. Settings:
   - **Allowed senders**: Only addresses in my domains
   - **Authentication**: Require SMTP authentication
   - **Encryption**: Require TLS encryption
4. This lets you send email FROM any @scrumai.org address using ONE set of credentials

**Advantage**: No App Passwords needed. No 2FA per account. One relay credential handles all agents.

---

## 🔧 Alternative: Use OAuth2 Instead of App Passwords

For a more secure long-term solution:

1. Create an **OAuth2 service account** in Google Cloud Console
2. Enable **domain-wide delegation** for it
3. Grant it Gmail scopes for the scrumai.org domain
4. Each agent uses the service account to impersonate its email address

This eliminates the need for individual sign-ins entirely.

---

## ⏰ Timing Strategy (If Using Individual Sign-Ins)

| Time | Action |
|------|--------|
| T+0 min | Unlock all accounts in Admin Console |
| T+15 min | Sign in to `jeff.sutherland@scrumai.org` (already done) |
| T+20 min | Sign in to `agent.saturday@scrumai.org` |
| T+25 min | Sign in to `asf.deploy@scrumai.org` |
| T+30 min | Sign in to `asf.research@scrumai.org` |
| T+35 min | Sign in to `asf.social@scrumai.org` |
| T+40 min | Sign in to `asf.sales@scrumai.org` |
| T+45 min | Generate App Passwords for all accounts |

**Key**: Space out the logins. Use a fresh incognito window for each. Don't retry if it fails — wait longer.

---

## 📋 Quick Checklist

- [ ] Go to Admin Console → unlock each blocked account
- [ ] Reset password for each account (uncheck "force change at next sign-in")
- [ ] Wait 15 minutes after unlocking
- [ ] Sign in to each account one at a time, 5 min apart
- [ ] Enable 2FA on each account after first sign-in
- [ ] Generate App Password for each account
- [ ] Give App Passwords to Copilot for Himalaya configuration

---

## 💡 Fastest Path Forward

**Recommendation**: Use the **SMTP Relay** method. It requires zero individual sign-ins:

1. Set up SMTP relay in Admin Console (2 minutes)
2. Use jeff.sutherland@scrumai.org credentials for the relay
3. Configure Himalaya to route all agent emails through the relay
4. Each agent can send as its own address via the relay

This completely bypasses the individual account sign-in problem.

