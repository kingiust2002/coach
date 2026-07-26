# امضای نسخه‌های Android و iOS

## شناسه ثابت برنامه

- Android applicationId: `com.kingiust.coach`
- iOS bundle identifier: `com.kingiust.coach`

این شناسه‌ها نباید بعد از انتشار تغییر کنند.

## Android

فایل خصوصی `android/key.properties` و فایل keystore نباید وارد Git شوند. قالب موردنیاز در `android/key.properties.example` قرار دارد.

ساختار پیشنهادی محلی:

```text
android/
  key.properties
  keystore/
    coach-upload.jks
```

همه نسخه‌های Release باید با همان keystore و همان alias امضا شوند. تغییر کلید باعث می‌شود Android نسخه جدید را به‌عنوان آپدیت نسخه قبلی نپذیرد و خطای ناسازگاری امضا نمایش دهد.

در نبود `key.properties`، Buildهای توسعه با کلید Debug امضا می‌شوند. این حالت فقط برای تست و نصب موقت است و برای انتشار یا آپدیت پایدار مناسب نیست.

## iOS

پروژه از Automatic Signing استفاده می‌کند و Bundle ID آن `com.kingiust.coach` است. برای ساخت IPA قابل نصب، یکی از این مسیرها لازم است:

- Apple Development certificate + development provisioning profile
- Apple Distribution certificate + Ad Hoc/App Store provisioning profile
- اتصال مستقیم حساب Apple Developer و انتخاب Team برای Automatic Signing

گواهی، کلید خصوصی `.p12`، رمز آن و provisioning profile اطلاعات محرمانه هستند و نباید در مخزن قرار بگیرند.
