import urllib.request
import json
import os
import sys

# إعدادات مستودع مشروعك
OWNER = "magdymeko456-cell"
REPO = "mirror_scorpion-mirror_scorpion_v2"

print("==================================================")
print("   🧹 نظام تنظيف قائمة GitHub Actions الفاشلة   ")
print("==================================================")

# طلب التوكن (Token) الخاص بحسابك لإعطاء صلاحية الحذف
TOKEN = os.environ.get("GH_TOKEN")
if not TOKEN:
    print("🔑 لمرة واحدة، يرجى لصق الـ Personal Access Token (PAT) الخاص بك.")
    print("(تأكد أن التوكن يحتوي على صلاحية actions:write أو repo)")
    TOKEN = input("ادخل التوكن هنا واضغط Enter: ").strip()

if not TOKEN:
    print("❌ خطأ: التوكن مطلوب للوصول إلى GitHub API وتطهير القائمة.")
    sys.exit(1)

headers = {
    "Authorization": f"token {TOKEN}",
    "Accept": "application/vnd.github.v3+json",
    "User-Agent": "Termux-Actions-Cleaner"
}

# 1. جلب أول 10 عمليات بناء فاشلة فقط
url = f"https://api.github.com/repos/{OWNER}/{REPO}/actions/runs?status=failure&per_page=10"
req = urllib.request.Request(url, headers=headers)

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        runs = data.get("workflow_runs", [])
        
    if not runs:
        print("\n🎉 مفيش أي بناءات فاشلة حالياً في المستودع! صفحتك رايقة ونظيفة.")
        sys.exit(0)
        
    print(f"\n🔍 تم رصد {len(runs)} بناء فاشل كحد أقصى لهذه الجولة. جاري الحذف الآن...\n")
    
    # 2. حلقة التكرار لحذف الـ 10 بناءات المحددة
    for run in runs:
        run_id = run["id"]
        run_num = run["run_number"]
        title = run.get("display_title", "بدون عنوان")
        
        delete_url = f"https://api.github.com/repos/{OWNER}/{REPO}/actions/runs/{run_id}"
        del_req = urllib.request.Request(delete_url, headers=headers, method="DELETE")
        
        try:
            with urllib.request.urlopen(del_req) as del_res:
                if del_res.status == 204:
                    print(f"✅ تم نسف البناء رقم #{run_num} بنجاح [{title}]")
        except Exception as e:
            print(f"❌ تعذر حذف البناء #{run_num}: {e}")
            
    print("\n✨ انتهت جولة التنظيف! ارفع رأسك وافتح صفحة الـ Actions وهتلاقيها بقت رايقة وتفتح النفس.")
    
except Exception as e:
    print(f"\n❌ حدث خطأ أثناء الاتصال بسيرفر GitHub: {e}")
    print("تأكد من اتصال الإنترنت أو صحة التوكن المستخدم.")
