# أذكاري 🌙

تطبيق Flutter للأذكار والقرآن والمسبحة. بدون إعلانات، ويعمل بدون إنترنت (عدا تحميل خط Cairo/Amiri أول مرة).

## المميزات
- أذكار الصباح والمساء والنوم وبعد الصلاة
- أذكاري: أضف/احذف أذكارك بنفسك (اسحب الذكر لحذفه)
- القرآن الكريم كامل (114 سورة) + متابعة القراءة + تكبير الخط
- إشعارات تذكير بمواعيد الأذكار (تعديل الوقت من الإعدادات)
- الورد اليومي مع هدف وسلسلة أيام متتالية
- مسبحة بعداد وهدف واهتزاز
- حديث جديد كل يوم
- وضع فاتح/داكن حسب نظام الهاتف، وألوان هادئة
- حركات انتقال سلسة

## التشغيل
```bash
flutter create . --org com.example --project-name azkar_app
flutter pub get
flutter run
```

> شغّل `flutter create .` داخل هذا المجلد أولاً ليولّد مجلدات android و ios (ملفات lib و pubspec الحالية تبقى كما هي).

## إعدادات الأندرويد (مهمة للإشعارات)
في `android/app/build.gradle(.kts)`:
```
compileOptions { coreLibraryDesugaringEnabled true }
dependencies { coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4' }
```
وفي `android/app/src/main/AndroidManifest.xml` داخل `<manifest>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```
وداخل `<application>`:
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```
تأكد أن `minSdkVersion` لا يقل عن 21.

## ملاحظات
- الأحاديث والأذكار المضمنة في `lib/data/` فراجع النصوص قبل النشر النهائي، ويمكنك التوسع بإضافة المزيد.
- لإضافة أيقونة للتطبيق: حزمة `flutter_launcher_icons`.
