# Mirror Scorpion - Termux Setup Guide

## نسخة عربية أسفل الصفحة

---

## English Version

### Prerequisites
- Termux app installed on Android device
- Git installed in Termux
- Flutter SDK (will be installed)
- 2GB+ free storage space

### Step 1: Install Git in Termux

```bash
pkg update && pkg upgrade -y
pkg install git -y
```

### Step 2: Configure Git

```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

### Step 3: Clone the Repository

```bash
cd ~
git clone https://github.com/dosoky2580/mirror_scorpion_translate1.git
cd mirror_scorpion_translate1
```

### Step 4: Verify Git Connection

```bash
git remote -v
```

### Step 5: Create a Working Branch

```bash
git checkout -b development
```

### Step 6: Make Changes and Commit

```bash
# Make your changes to the code
# Then stage changes
git add .

# Commit your changes
git commit -m "Your commit message"

# Push to GitHub
git push -u origin development
```

### Step 7: Sync with Main Branch

```bash
# Fetch latest changes
git fetch origin

# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Merge with your branch
git merge main
```

### Step 8: View Commit History

```bash
git log --oneline -10
```

### Step 9: View Current Status

```bash
git status
```

### Step 10: Create a Pull Request

After pushing your changes:
1. Go to https://github.com/dosoky2580/mirror_scorpion_translate1
2. Click "Compare & pull request"
3. Add description and submit

---

## Useful Git Commands for Termux

### View Repository Information
```bash
git remote show origin
git branch -a
git log --graph --oneline --all
```

### Undo Changes
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Discard changes in working directory
git checkout -- .
```

### Stash Changes
```bash
# Save changes temporarily
git stash

# Apply stashed changes
git stash pop

# List stashed changes
git stash list
```

### Resolve Conflicts
```bash
# After merge conflict
git status  # See conflicted files

# Edit conflicted files manually

git add .
git commit -m "Resolve merge conflicts"
git push
```

### Tag Releases
```bash
# Create a tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to GitHub
git push origin v1.0.0

# List all tags
git tag -l
```

---

## Troubleshooting

### Authentication Issues
```bash
# If you get authentication errors, use personal access token
# Generate one at: https://github.com/settings/tokens
# Instead of password, use the generated token

# Or configure SSH (recommended)
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy output and add to GitHub SSH keys
# https://github.com/settings/keys
```

### Large Files
```bash
# If file is too large to push
git rm --cached large_file.bin
echo "large_file.bin" >> .gitignore
git add .gitignore
git commit -m "Remove large file"
git push
```

### Network Issues
```bash
# Increase timeout
git config --global http.postBuffer 524288000

# Use SSH instead of HTTPS
git remote set-url origin git@github.com:dosoky2580/mirror_scorpion_translate1.git
```

---

## Best Practices

1. **Always pull before pushing**
   ```bash
   git pull origin main
   git push origin main
   ```

2. **Use meaningful commit messages**
   ```bash
   git commit -m "✨ Add feature: microphone support"
   git commit -m "🐛 Fix: translation API timeout"
   git commit -m "📚 Docs: update README"
   ```

3. **Create branches for features**
   ```bash
   git checkout -b feature/new-feature
   # Make changes
   git push -u origin feature/new-feature
   ```

4. **Keep commits small and focused**
   ```bash
   # Good: Multiple small commits
   git commit -m "Add microphone button"
   git commit -m "Implement speech recognition"
   
   # Avoid: One large commit with everything
   ```

5. **Review changes before committing**
   ```bash
   git diff          # See all changes
   git diff --staged # See staged changes
   ```

---

## Automation Script

Create a file named `sync.sh`:

```bash
#!/bin/bash

echo "🔄 Syncing Mirror Scorpion Repository..."

cd ~/mirror_scorpion_translate1

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Stage all changes
echo "📝 Staging changes..."
git add -A

# Commit with timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
git commit -m "🔄 Auto-sync: $TIMESTAMP"

# Push changes
echo "📤 Pushing changes..."
git push origin main

echo "✅ Sync complete!"
```

Run it:
```bash
chmod +x sync.sh
./sync.sh
```

---

---

## النسخة العربية

### المتطلبات الأساسية
- تطبيق Termux مثبت على جهاز Android
- Git مثبت في Termux
- مساحة تخزين 2GB+

### الخطوة 1: تثبيت Git

```bash
pkg update && pkg upgrade -y
pkg install git -y
```

### الخطوة 2: إعداد Git

```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

### الخطوة 3: استنساخ المستودع

```bash
cd ~
git clone https://github.com/dosoky2580/mirror_scorpion_translate1.git
cd mirror_scorpion_translate1
```

### الخطوة 4: التحقق من الاتصال

```bash
git remote -v
```

### الخطوة 5: إنشاء فرع عمل

```bash
git checkout -b development
```

### الخطوة 6: إجراء التغييرات والحفظ

```bash
# قم بإجراء التغييرات على الكود

# تحضير التغييرات
git add .

# حفظ التغييرات
git commit -m "رسالة الحفظ"

# رفع التغييرات
git push -u origin development
```

### الخطوة 7: المزامنة مع الفرع الرئيسي

```bash
# جلب آخر التحديثات
git fetch origin

# الانتقال للفرع الرئيسي
git checkout main

# سحب آخر التحديثات
git pull origin main

# دمج التغييرات
git merge main
```

### الخطوة 8: عرض سجل الحفظ

```bash
git log --oneline -10
```

### الخطوة 9: عرض حالة المستودع

```bash
git status
```

---

## أوامر Git المهمة

### عرض معلومات المستودع
```bash
git remote show origin
git branch -a
git log --graph --oneline --all
```

### التراجع عن التغييرات
```bash
# التراجع عن آخر حفظ (الاحتفاظ بالتغييرات)
git reset --soft HEAD~1

# التراجع عن آخر حفظ (حذف التغييرات)
git reset --hard HEAD~1

# إلغاء جميع التغييرات
git checkout -- .
```

### حفظ التغييرات مؤقتاً
```bash
# حفظ التغييرات مؤقتاً
git stash

# تطبيق التغييرات المحفوظة
git stash pop

# عرض التغييرات المحفوظة
git stash list
```

---

## أفضل الممارسات

1. **اسحب دائماً قبل الرفع**
   ```bash
   git pull origin main
   git push origin main
   ```

2. **استخدم رسائل حفظ واضحة**
   ```bash
   git commit -m "✨ إضافة: دعم الميكروفون"
   git commit -m "🐛 إصلاح: مهلة انتظار API"
   git commit -m "📚 توثيق: تحديث README"
   ```

3. **أنشئ فروع للميزات الجديدة**
   ```bash
   git checkout -b feature/new-feature
   # قم بالتغييرات
   git push -u origin feature/new-feature
   ```

---

## ملاحظات مهمة

- **لا تحمل مكتبات على Termux**: استخدم Git فقط كوسيط
- **تأكد من الاتصال بالإنترنت**: قبل أي عملية push/pull
- **احفظ التغييرات بانتظام**: لتجنب فقدان البيانات
- **استخدم رسائل واضحة**: لتتبع التغييرات بسهولة

---

## الدعم والمساعدة

للمزيد من المعلومات عن Git:
- https://git-scm.com/doc
- https://github.com/git-tips/tips

للمزيد عن Termux:
- https://termux.com/
- https://wiki.termux.com/

---

**تم إنشاؤه بواسطة:** Mirror Scorpion Development Team
**آخر تحديث:** 2024
**الإصدار:** 1.0.0
