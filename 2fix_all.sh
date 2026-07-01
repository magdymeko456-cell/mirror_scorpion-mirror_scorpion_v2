#!/bin/bash
# FIX V13: إصلاح وتثبيت build.yml
echo "Mirror Scorpion Fix V13"
git pull origin main
git add .github/workflows/build.yml README.md CHANGELOG.md
git commit -m "🐛 FIX V13: build.yml + توثيق"
git push origin main
echo "✅ تم الإصلاح"
