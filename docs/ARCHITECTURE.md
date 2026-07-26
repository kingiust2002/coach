# Architecture Decision Record — Foundation

## هدف

ساخت دو اپ مستقل مربی و ورزشکار با هسته داده سازگار، عملکرد آفلاین و امکان افزودن Cloud Sync بدون بازنویسی منطق محصول.

## لایه‌ها

### Presentation

صفحه‌ها، Controllerها و Widgetها. این لایه فقط با Repository interface کار می‌کند.

### Domain

Entityها، قوانین اعتبارسنجی و قرارداد Repository. این لایه نباید Flutter، SQLite یا فایل را بشناسد.

### Data

پیاده‌سازی Repository، Mapper و Data Source. SQLite اولین Data Source است و Transport فایل در مرحله بعد اضافه می‌شود.

### Core

دیتابیس، خطاها، تنظیمات، شناسه‌ها، نسخه‌بندی و قرارداد Sync.

## قواعد غیرقابل مذاکره

- همه شناسه‌ها پایدار و مستقل از شناسه عددی دیتابیس‌اند.
- همه زمان‌ها با UTC ذخیره می‌شوند.
- UI هیچ Query خام SQL ندارد.
- Migration تخریبی بدون Backup ممنوع است.
- برنامه منتشرشده درجا ویرایش نمی‌شود؛ Revision جدید ساخته می‌شود.
- Import باید Transactional و Idempotent باشد.
- فایل تبادل داده نسخه Schema مستقل از نسخه اپ دارد.

## ساختار هدف

```text
lib/
  app/
  core/
  features/
    athletes/
      data/
      domain/
      presentation/
    exercises/
    programs/
    progress/
  shared/
```

## مسیر نسخه‌ها

- V0.1: Foundation و Athlete CRUD
- V0.2: کتابخانه حرکات و Migration تست‌شده
- V0.3: برنامه‌ساز و Program Revision
- V0.4: بسته خروجی مربی به ورزشکار
- V0.5: ورود گزارش ورزشکار و History
