#!/bin/bash

echo "🔄 Updating episode status..."

# ------------------------------------------
# 1) Episode 폴더 목록 수집
# ------------------------------------------

episodes=()
for dir in episode*/ ; do
  if [[ $dir =~ episode([0-9]+) ]]; then
    episodes+=("${BASH_REMATCH[1]}")
  fi
done

# 번호 정렬
IFS=$'\n' episodes=($(sort -n <<<"${episodes[*]}"))
unset IFS

# ------------------------------------------
# 2) episode-status.md 생성
# ------------------------------------------

echo "📄 Updating episode-status.md"

{
  echo "| Episode | Status |"
  echo "|--------|--------|"
  for ep in "${episodes[@]}"; do
    if [[ -f "episode$ep/index.html" ]]; then
      echo "| Episode $ep | 완료 |"
    else
      echo "| Episode $ep | 작성중 |"
    fi
  done
} > episode-status.md

# ------------------------------------------
# 3) README.md 업데이트
# ------------------------------------------

completed=$(find . -maxdepth 2 -name "index.html" -path "./episode*/index.html" | wc -l)

echo "📄 Updating README.md (완료: $completed)"

# Episode 상태 표가 시작되는 라인 이후를 재작성
sed -i "/^## ✔ 에피소드 제작 현황$/q" README.md

{
  echo ""
  echo "| Episode | Status |"
  echo "|--------|--------|"
  for ep in "${episodes[@]}"; do
    if [[ -f "episode$ep/index.html" ]]; then
      echo "| Episode $ep | 완료 |"
    else
      echo "| Episode $ep | 작성중 |"
    fi
  done
} >> README.md

# ------------------------------------------
# 4) index.html Episode 버튼 자동 생성
# ------------------------------------------

echo "🌐 Updating index.html episode buttons..."

buttons=""
for ep in "${episodes[@]}"; do
  buttons+="  <a href=\"episode$ep/index.html\" class=\"ep-btn\">Episode $ep</a>\n"
done

# 마커 영역 교체
awk -v buttons="$buttons" '
  /<!-- AUTO_EPISODE_BUTTONS_START -->/ {
    print;
    print buttons;
    skip=1;
    next;
  }
  /<!-- AUTO_EPISODE_BUTTONS_END -->/ {
    skip=0;
  }
  skip==0 { print }
' index.html > index_tmp.html

mv index_tmp.html index.html

echo "✅ All updates done!"
