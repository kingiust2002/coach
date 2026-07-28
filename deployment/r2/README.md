# Cloudflare R2 deployment

Public development base URL:

```text
https://pub-b9ff919dee094104aea521394068477a.r2.dev
```

Upload the repository file `deployment/r2/catalog/v1.json` to the bucket with this exact object key:

```text
catalog/v1.json
```

Video objects use this layout:

```text
videos/<exercise-id>-v<media-version>.mp4
```

Optional images use this layout:

```text
images/<exercise-id>-start.webp
images/<exercise-id>-end.webp
```

The Flutter app uses the public catalog URL below by default. A build-time `EXERCISE_CATALOG_URL` value may override it for staging or production.

```text
https://pub-b9ff919dee094104aea521394068477a.r2.dev/catalog/v1.json
```

Do not commit Cloudflare API tokens, R2 access keys, Supabase service-role keys, or database passwords.
