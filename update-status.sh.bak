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

  EPISODE_STATUS+="$i : $STATUS\n"
done


###############################################
# 2) _readme_status.md 자동 생성
###############################################

echo "📝 Writing _readme_status.md"
cat > _readme_status.md <<EOF
# Episode 상태 요약

$EPISODE_STATUS

완료된 에피소드: ${COMPLETED_LIST[*]}
EOF


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