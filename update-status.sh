#!/bin/bash

echo "🔧 update-status.sh start"

###############################################
# 1) Episode 상태 스캔 (완료 / 작성중 판단)
###############################################

EPISODE_STATUS=""
COMPLETED_LIST=()

for i in {1..20}; do
  FOLDER="episode$i"
  FILE="$FOLDER/index.html"

  if [[ -f "$FILE" ]]; then
    CONTENT=$(cat "$FILE")

    if [[ -z "$CONTENT" ]] || [[ "$CONTENT" == *"작성중"* ]]; then
      STATUS="⏳ 작성중"
    else
      STATUS="✅ 완료"
      COMPLETED_LIST+=($i)
    fi
  else
    STATUS="⏳ 작성중"
  fi

  EPISODE_STATUS+="| Episode $i | $STATUS |\n"
done


###############################################
# 2) episode-status.md 자동 생성
###############################################

echo "📝 Writing episode-status.md"
cat > episode-status.md <<EOF
# Episode Status

| Episode | Status |
|--------:|:------:|
$(echo -e "$EPISODE_STATUS")
EOF


###############################################
# 3) README.md 제작 현황 자동 업데이트
###############################################

echo "📝 Updating README.md statuses"

README_TABLE=$(echo -e "$EPISODE_STATUS")

# 완료 구간 계산
if [[ ${#COMPLETED_LIST[@]} -gt 0 ]]; then
  FIRST=${COMPLETED_LIST[0]}
  LAST=${COMPLETED_LIST[-1]}
  COMPLETE_RANGE="Episode ${FIRST}~${LAST}까지 완료, 20화까지 제작 예정입니다."
else
  COMPLETE_RANGE="아직 완료된 에피소드가 없습니다."
fi

# README 갱신
awk -v table="$README_TABLE" -v range="$COMPLETE_RANGE" '
  BEGIN { in_table=0 }
  /Episode [0-9]+~[0-9]+까지 완료/ {
    print range
    next
  }
  /^## ✔ 에피소드 제작 현황/ { 
    print; getline; print ""; print "| Episode | Status |"; print "|--------:|:------:|"
    in_table=1; next 
  }
  in_table==1 && /^\| Episode/ { next }
  in_table==1 && NF==0 { 
    print table
    in_table=0
    next
  }
  { print }
' README.md > README_tmp.md

mv README_tmp.md README.md


###############################################
# 4) index.html 자동 버튼 상태 갱신 (draft 처리)
###############################################

echo "📝 Updating index.html auto buttons area"

AUTO_BUTTONS=""

for i in {1..20}; do
  if [[ " ${COMPLETED_LIST[*]} " == *" $i "* ]]; then
    AUTO_BUTTONS+="  <a class=\"ep-btn\" href=\"episode$i/index.html\">Episode $i</a>\n"
  else
    AUTO_BUTTONS+="  <a class=\"ep-btn draft\" href=\"episode$i/index.html\">Episode $i</a>\n"
  fi
done

# index.html 치환
sed -i.bak "/AUTO_EPISODE_BUTTONS_START/,/AUTO_EPISODE_BUTTONS_END/c\
<!-- AUTO_EPISODE_BUTTONS_START -->\
$AUTO_BUTTONS<!-- AUTO_EPISODE_BUTTONS_END -->
" index.html

rm -f index.html.bak


###############################################
# Finish
###############################################

echo "✅ update-status.sh finished"