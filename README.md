![app_icon](android/app/src/main/res/mipmap-xhdpi/ic_launcher.png)

# url_launcher

Simple app to save and launch urls

<a href='https://play.google.com/store/apps/details?id=com.oleksii_lemeshinskyi.url_launcher&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/></a>

### App features
- [X] Basic HTTP links
- [ ] Email addresses
- [ ] Phone numbers
- [ ] Translation

## Android releases

Pushing a tag in the form `vMAJOR.MINOR.PATCH+BUILD_NUMBER` runs the
[Android release workflow](.github/workflows/android-release.yml). For example,
`v1.0.1+2` builds an app bundle with Android version name `1.0.1` and version
code `2`. The tag determines both values, regardless of the `pubspec.yaml`
version. Use a new version code greater than every code already uploaded to
Google Play; a used code cannot be uploaded again.

Before the first run:

1. Make sure this app (`com.oleksii_lemeshinskyi.url_launcher`) already exists
   in Play Console and that you have its **upload keystore**. The keystore must
   contain the upload key registered for this app.
2. Enable the Google Play Developer API in a Google Cloud project. Create a
   service account and grant it access to this app in Play Console, including
   permission to manage production releases.
3. Add these GitHub Actions repository secrets under **Settings → Secrets and
   variables → Actions**:

   | Secret | Value |
   | --- | --- |
   | `ANDROID_KEYSTORE_BASE64` | Single-line Base64 of the upload keystore |
   | `ANDROID_KEY_ALIAS` | Alias of the upload key in that keystore |
   | `ANDROID_KEY_PASSWORD` | Password for the upload key |
   | `ANDROID_STORE_PASSWORD` | Password for the keystore |
   | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Full JSON contents of the service account key |

   To encode the keystore as a single line, run:

   ```sh
   base64 < /path/to/upload-keystore.jks | tr -d '\n'
   ```

Once the workflow is on the commit you want to release, push a tag, for example:

```sh
git tag v1.0.1+2
git push origin v1.0.1+2
```

The workflow analyzes the app, builds a signed `.aab`, saves it as a GitHub
Actions artifact, and uploads it to a **draft production release** in Google
Play. Open that draft in Play Console to review the bundle, add release notes,
and submit or roll out the release yourself. Pushing the tag does not publish
the app to users.
