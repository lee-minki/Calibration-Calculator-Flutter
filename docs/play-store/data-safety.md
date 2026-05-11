# Data Safety — Play Console answers

Copy these answers into Play Console → App content → Data safety. Each
section below maps 1:1 to the Play Console questionnaire.

---

## Section: Data collection and security

### Does your app collect or share any of the required user data types?

**Answer: Yes**

(Even though *we* don't run a backend, the bundled Google Mobile Ads SDK
collects data on our behalf. This requires "Yes" with full disclosure.)

### Is all of the user data collected by your app encrypted in transit?

**Answer: Yes**

(All AdMob traffic and any Google Fonts requests go over HTTPS.)

### Do you provide a way for users to request that their data is deleted?

**Answer: No** (we do not collect user data ourselves)

But state in the form:
> The app stores all user-entered values locally on the device only. Users
> can clear them by uninstalling the app or clearing app storage. Google
> AdMob data is handled per Google's policies — users can reset their
> advertising ID or opt out of personalised ads from Android system
> settings.

---

## Section: Data types — declare these

For each item below, set:

- **Collected**: Yes
- **Shared**: Yes (Google receives it for ad serving)
- **Processing**: Not processed ephemerally — Google retains for ad metrics
- **Optional**: No (required for the AdMob banner)
- **Purpose**: Advertising or marketing · Analytics

| Category | Data type | Collected | Shared | Purpose |
| --- | --- | --- | --- | --- |
| **Device or other IDs** | Device or other IDs (Advertising ID, AAID) | ✅ | ✅ | Advertising, Analytics |
| **Location** | Approximate location (derived from IP) | ✅ | ✅ | Advertising |
| **App activity** | App interactions (ad clicks/impressions) | ✅ | ✅ | Advertising, Analytics |
| **App info & performance** | Crash logs, diagnostics | ✅ | ✅ | Analytics |

**Do NOT declare:**

- Personal info (name, email, address, phone) — not collected.
- Financial info — not collected.
- Health & fitness — not collected.
- Messages, photos, audio, files — not collected.
- Calendar, contacts — not collected.
- Web browsing history — not collected.
- Precise location — not collected. (Only coarse, IP-based.)

---

## Section: Security practices

### Data is encrypted in transit

**Answer: Yes**

### Users can request that their data is deleted

**Answer: Yes** — via Google AdMob's reset advertising ID flow. Provide:

> The app does not collect user data on its own servers. For AdMob-collected
> data, users can reset their advertising identifier or opt out of
> personalised advertising in Android Settings → Google → Ads. See
> https://policies.google.com/technologies/ads for Google's data controls.

### Have you committed to follow the Play Families Policy?

**Answer: No** (the app is not targeted at children)

---

## Section: Government apps / health / sensitive data

All **No**.

---

## After submitting

1. Save the questionnaire. The "Data safety" section status should turn
   green in the Play Console dashboard.
2. The data safety form's responses appear in the **Data safety** card on
   the Play Store listing. Double-check the rendered card before
   publishing the release.
3. **AdMob policy reminder**: in App content → Ads, mark **Yes, my app
   contains ads** (banner shown via Google AdMob).

---

## Source citations (for your own audit trail)

- AdMob privacy disclosure required types: https://support.google.com/googleplay/android-developer/answer/10787469
- Mobile Ads SDK data collection: https://developers.google.com/admob/android/privacy
- AAID reset & opt-out instructions: https://policies.google.com/technologies/ads
