# The old address's bridge (holdfastrts.github.io/Holdfast/)

Why: apps (Android and Windows) built BEFORE 0.35.5 look for updates only at
`https://holdfastrts.github.io/Holdfast/version.json`. When the repository moved to `triumviwar/triumviwar.github.io`
(2026-11-13), GitHub moved the git address (it redirects) but NOT the GitHub Pages site: the old address answers 404,
so those apps never show "A NEW VERSION IS OUT". Apps from 0.35.5 on ask `https://triumviwar.github.io/` first and are
fine.

The fix, once (the owner; Claude can't create repositories):

1. On GitHub, in the organization `holdfastrts`, create a PUBLIC repository named exactly `holdfastrts.github.io`
   (an organization site: it does not clash with the moved `holdfast` repository, whose git redirect keeps working).
2. Upload the contents of this folder to it (root): `404.html`, `index.html`, `Holdfast/version.json`,
   `Holdfast/index.html`.
3. Settings > Pages: deploy from the branch `main`, folder `/ (root)`.

Then an old app sees version 0.38.63 at the old address, shows the box, and DOWNLOAD opens
`holdfastrts.github.io/Holdfast/Holdfast.apk`, which does not exist: the site's 404 page sends the browser on to the
newest `https://triumviwar.github.io/Triumviwar.apk` (or `Triumviwar_windows.zip`). After installing it the app asks the
new address. The number in `version.json` never needs changing (any number above the old app's makes the box show; the
download is always the newest).
