# 🛡️ MikroTik CHR Installer

> نصب خودکار **آخرین نسخه MikroTik CHR** روی هر سرور Ubuntu 24 — Ubuntu رو کاملاً جایگزین میکنه.

---

## ⚡ نصب با یه خط

### با `curl`:
```bash
curl -fsSL https://raw.githubusercontent.com/oskouie/mikrotik-chr-installer/main/run.sh | sudo bash
```

### با `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/oskouie/mikrotik-chr-installer/main/run.sh | sudo bash
```

### اجرای مستقیم:
```bash
sudo bash run.sh
```

---

## چه کاری انجام میده؟

- ✅ آخرین نسخه stable CHR رو از سایت رسمی MikroTik دانلود میکنه
- ✅ دیسک بوت رو خودکار پیدا میکنه
- ✅ URL دانلود رو قبل از شروع verify میکنه
- ✅ Ubuntu رو کاملاً پاک و CHR رو جایگزین میکنه
- ✅ سیستم ریبوت میشه و مستقیم وارد MikroTik میشه
- ✅ هم با `curl | bash` و هم با `wget | bash` و هم مستقیم کار میکنه

---

## بعد از نصب

| پارامتر | مقدار |
|---------|-------|
| Default User | `admin` |
| Default Pass | *(خالی — فوری تغییر بده!)* |
| اتصال | WinBox یا SSH |

---

## ⚠️ هشدارها

> **این عملیات برگشت‌پذیر نیست.** تمام دیتای موجود روی سرور پاک میشه.

- قبل از اجرا دسترسی **KVM / IPMI / Out-of-Band** داشته باش
- روی **VPS** کار میکنه اگه پروایدر virtualization از CHR ساپورت کنه
- روی **Dedicated Server** بدون مشکل کار میکنه

---

## ساختار فایل‌ها

```
mikrotik-chr-installer/
├── run.sh           # نقطه ورود — این رو اجرا کن
├── install-chr.sh   # اسکریپت اصلی نصب
└── README.md        # همین فایل
```

---

## نحوه کار داخلی

```
run.sh
  │
  ├── چک میکنه root هست یا نه
  ├── curl/wget رو نصب میکنه اگه نبود
  ├── install-chr.sh رو دانلود میکنه
  ├── stdin رو از /dev/tty میگیره (fix مشکل pipe)
  └── install-chr.sh رو اجرا میکنه
        │
        ├── آخرین نسخه CHR رو detect میکنه
        ├── URL رو verify میکنه
        ├── دیسک بوت رو پیدا میکنه
        ├── از کاربر تأییدیه میگیره (YES)
        ├── ایمیج رو دانلود و extract میکنه
        ├── با dd روی دیسک مینویسه
        └── ریبوت میکنه
```

---

## License

MIT
