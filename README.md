# 🛡️ MikroTik CHR Installer

> Automatically installs the **latest MikroTik CHR** on any Ubuntu 24 server — replaces Ubuntu entirely.

---

## ⚡ One-Line Install

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/oskouie/mikrotik-chr-installer/main/run.sh)
```

یا با `wget`:

```bash
sudo bash <(wget -qO- https://raw.githubusercontent.com/oskouie/mikrotik-chr-installer/main/run.sh)
```

---

## چه کاری انجام میده؟

- ✅ آخرین نسخه stable CHR رو از سایت رسمی MikroTik دانلود میکنه  
- ✅ دیسک بوت رو خودکار پیدا میکنه  
- ✅ Ubuntu رو کاملاً پاک و CHR رو جایگزین میکنه  
- ✅ سیستم ریبوت میشه و مستقیم وارد MikroTik میشه  

---

## بعد از نصب

| پارامتر | مقدار |
|---------|-------|
| Default User | `admin` |
| Default Pass | *(خالی)* |
| اتصال | WinBox یا SSH |

---

## ⚠️ هشدار

> **این عملیات برگشت‌پذیر نیست.** تمام دیتای موجود روی سرور پاک میشه.

- قبل از اجرا دسترسی **KVM / IPMI / Out-of-Band** داشته باش  
- روی **VPS** کار میکنه اگه پروایدر CHR رو ساپورت کنه  

---

## ساختار فایل‌ها

```
mikrotik-chr-installer/
├── run.sh          # نقطه ورود - این رو اجرا کن
└── install-chr.sh  # اسکریپت اصلی نصب
```
