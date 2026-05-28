#!/usr/bin/env bash

# Determine wrt_core path
if [ -d "wrt_core" ]; then
    WRT_CORE_PATH="wrt_core"
elif [ -d "../wrt_core" ]; then
    WRT_CORE_PATH="../wrt_core"
else
    WRT_CORE_PATH=$(dirname "$0")
fi

BASE_PATH=$(cd "$WRT_CORE_PATH" && pwd)
Dev=$1
INI_FILE="$BASE_PATH/compilecfg/$Dev.ini"

if [[ ! -f $INI_FILE ]]; then
    echo "INI file not found: $INI_FILE"
    exit 1
fi

read_ini_by_key() {
    local key=$1
    awk -F"=" -v key="$key" '$1 == key {print $2}' "$INI_FILE"
}

REPO_URL=$(read_ini_by_key "REPO_URL")
REPO_BRANCH=$(read_ini_by_key "REPO_BRANCH")
REPO_BRANCH=${REPO_BRANCH:-main}
BUILD_DIR="$BASE_PATH/../action_build"

echo $REPO_URL $REPO_BRANCH
echo "$REPO_URL/$REPO_BRANCH" > "$BASE_PATH/../repo_flag"
git clone --depth 1 -b $REPO_BRANCH $REPO_URL $BUILD_DIR

PROJECT_MIRRORS_FILE="$BUILD_DIR/scripts/projectsmirrors.json"
if [ -f "$PROJECT_MIRRORS_FILE" ]; then
    sed -i '/.cn\//d; /tencent/d; /aliyun/d' "$PROJECT_MIRRORS_FILE"
fi

# ====================== SSR-Plus 插件 ======================
cd $BUILD_DIR || exit 1
git clone https://github.com/fw876/helloworld.git package/helloworld
./scripts/feeds update -a
./scripts/feeds install -a
