# Online exercise video architecture

## Product decisions

- The APK does not bundle exercise videos.
- The library exposes one complete instructional video per exercise.
- Short loops and medium-length preview videos are intentionally excluded.
- Coaches and athletes choose which individual videos to download.
- Downloads are device-local and removable without deleting the exercise.
- Up to two optional still-image URLs may exist in the manifest, but images are not automatically downloaded or bundled.
- Exercise and athlete data remain offline-first in SQLite.

## Recommended free-tier topology

- Supabase: authentication, coach/athlete relationships, exercise metadata and sync records.
- Cloudflare R2: public instructional video objects.
- A small JSON manifest connects stable exercise IDs to R2 object URLs.

This keeps large media traffic away from the application database and lets the app remain usable when the metadata service is temporarily unavailable.

## Build configuration

Provide the media manifest URL as a compile-time define:

```bash
flutter build apk \
  --dart-define=EXERCISE_MEDIA_MANIFEST_URL=https://example.com/exercise-media-v1.json
```

When the variable is absent, the app shows the local exercise library normally and reports that no video has been published.

## Manifest format

```json
{
  "version": 1,
  "items": [
    {
      "exercise_id": "sys_back_squat",
      "full_video_url": "https://media.example.com/exercises/sys_back_squat/v1.mp4",
      "image_urls": [],
      "version": 1,
      "size_bytes": 18432000,
      "duration_seconds": 92,
      "sha256": "lowercase-hex-sha256",
      "updated_at": "2026-07-28T00:00:00Z"
    }
  ]
}
```

Rules:

- `exercise_id` must match the stable local catalog ID.
- `full_video_url` is the only video rendition exposed to the product.
- `version` must increase whenever the file changes.
- `size_bytes` allows download validation and UI estimates.
- `sha256` is optional but recommended for integrity verification.
- `image_urls` accepts zero, one or two items and is currently metadata-only.

## Offline behavior

1. The app tries to refresh the manifest.
2. A successful manifest is cached locally.
3. If refresh fails, cached metadata is used.
4. Streaming uses the remote full-video URL.
5. Downloaded files are stored under the application support directory.
6. A newer media version uses a new filename and removes the old version only after a successful download.
7. Removing a download never removes the exercise or its history.

## Content requirements

- MP4 container, H.264 video and AAC audio.
- 720p is the default delivery target unless technique detail requires higher resolution.
- Stable framing, lighting, clothing and terminology across the library.
- No third-party media without explicit redistribution rights.
- Persian instruction text and safety notes remain available without downloading the video.
