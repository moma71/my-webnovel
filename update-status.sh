#!/bin/bash

# 1) Episode 폴더 리스트 읽기
episodes=()
for dir in episode*/ ; do
  if [[ $dir =~ episode([0-9]+) ]]; then
    episodes+=("${BASH_REMATCH[1]}")
  fi
done

# 에피소드 번호 정렬
IFS=$'\n' episodes=($(sort -n <<<"${episodes[*]}"))
unset IFS

# ------------------------------
# 2) episode-status.md 자동 생성
# ------------------------------

echo "| Episode | Status |" > episode-status.md
echo "|--------|--------|" >> episode-status.md

for ep in "${episodes[@]}"; do
  if [[ -f "episode$ep/index.html" ]]; then
    echo "| Episode $ep | 완료 |" >> episode-status.md
  else
    echo "| Episode $ep | 작성중 |" >> episode-status.md
  fi
done

# ------------------------------
# 3) README.md 제작 현황 자동 업데이트
# ------------------------------

completed=$(find . -maxdepth 2 -name "index.html" -path "./episode*/index.html" | wc -l)
echo "완료된 에피소드 갯수: $completed"

# README.md 업데이트
sed -i "/^Episode 6/,\$d" README.md

echo "" >> README.md
echo "Episode 1~$completed 완료, 20화까지 제작 예정입니다." >> README.md
echo "" >> README.md

# ------------------------------
# 4) index.html 버튼 자동 생성
# ------------------------------

BUTTONS=""
for ep in "${episodes[@]}"; do
  BUTTONS+="  <a href=\"episode$ep/index.html\" class=\"ep-btn\">Episode $ep</a>\n"
done

# index.html 마커 영역 교체
awk -v buttons="$BUTTONS" '
  /<!-- AUTO_EPISODE_BUTTONS_START -->/ {print; print buttons; skip=1}
  /<!-- AUTO_EPISODE_BUTTONS_END -->/ {skip=0}
  !skip
' index.html > index_tmp.html

mv index_tmp.html index.html