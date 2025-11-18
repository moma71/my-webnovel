#!/bin/bash

STATUS_FILE="episode-status.md"
README_FILE="README.md"

echo "에피소드 상태 갱신 시작..."

# Markdown 표 헤더 생성
STATUS_TABLE="| Episode | Status |
|---------|--------|
"

# README용 표도 동일 구조
README_TABLE="| Episode | Status |
|---------|--------|
"

# 1~20까지 상태 체크
for i in {1..20}
do
    FOLDER="episode$i"
    if [ -f "$FOLDER/index.html" ]; then
        STATUS="완료"
    else
        STATUS="작성중"
    fi

    STATUS_TABLE+="| Episode $i | $STATUS |
"
    README_TABLE+="| Episode $i | $STATUS |
"
done

# episode-status.md 갱신
echo "에피소드 상태 파일 업데이트..."
cat > $STATUS_FILE <<EOF
# 📘 에피소드 제작 현황

${STATUS_TABLE}
EOF

# README.md 수정 (기존 내용 유지하며 상태 표 부분만 교체)
echo "README 업데이트..."

awk -v table="$README_TABLE" '
    BEGIN {printed=0}
    /## ✔ 에피소드 제작 현황/ {
        print;
        print "";
        print table;
        printed=1;
        skip=1;
        next;
    }
    # 상태 표 영역 건너뛰기
    skip && /^\| Episode/ { next }
    skip && /^\|---------/ { next }
    # 표 끝나면 skip 해제
    skip && !/^\|/ { skip=0 }

    { print }
' $README_FILE > README.tmp

mv README.tmp README.md

echo "완료!"
