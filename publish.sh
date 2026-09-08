#!/bin/bash
# =============================================================================
# publish.sh — このフォルダを GitHub の公開リポジトリ IWAOKAI/goaltore として
#              GitHub Pages で公開する（初回）。2回目以降は git push だけでOK。
#
# 公開後のURL:
#   https://iwaokai.github.io/goaltore/            トップ
#   https://iwaokai.github.io/goaltore/privacy.html プライバシーポリシー（ストア登録用）
#   https://iwaokai.github.io/goaltore/support.html サポート（ストア登録用）
#
# 使い方:  bash ~/Developer/goaltore-site/publish.sh
# =============================================================================
set -e
cd "$(dirname "$0")"

OWNER="IWAOKAI"
REPO="goaltore"

if [ ! -d .git ]; then
  git init -b main
fi
git add -A
git commit -m "GOAL! 入試トレ シリーズ: サイト初版（プライバシーポリシー・サポート）" || true

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "== gh CLI でリポジトリを作成して push します =="
  if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    gh repo create "$OWNER/$REPO" --public --source=. --remote=origin --push \
      --description "GOAL! 入試トレ シリーズ 公式サイト（プライバシーポリシー・サポート）"
  else
    git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
    git push -u origin main
  fi
  echo "== GitHub Pages を有効化（main ブランチ / ルート）=="
  gh api -X POST "repos/$OWNER/$REPO/pages" -f build_type=legacy -f "source[branch]=main" -f "source[path]=/" \
    >/dev/null 2>&1 || echo "（Pages は既に有効か、設定画面から有効化してください）"
  echo
  echo "数分後に https://iwaokai.github.io/$REPO/privacy.html を開いて表示を確認してください。"
else
  cat <<EOF
== gh CLI が無い（または未ログイン）ので、手動で公開してください ==
1. https://github.com/new を開き、Repository name に「$REPO」、Public を選んで Create。
   （README などは追加しない）
2. このターミナルで:
     git remote add origin https://github.com/$OWNER/$REPO.git
     git push -u origin main
3. GitHub のリポジトリ画面 → Settings → Pages → Build and deployment:
     Source: Deploy from a branch / Branch: main / Folder: /(root) → Save
4. 数分後に https://iwaokai.github.io/$REPO/privacy.html を開いて表示を確認。

（gh CLI を入れる場合: brew install gh && gh auth login）
EOF
fi
