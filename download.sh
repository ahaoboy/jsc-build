BASE_URL="$1"
TARGET="$2"

hashToRevision() {
    local hash=$1
    local response
    response=$(curl -s "https://api.github.com/repos/WebKit/WebKit/commits/${hash}")
    echo "$response" | grep -oP 'Canonical link: https://commits\.webkit\.org/(\d+)@main' | sed -E 's/.*\/([0-9]+)@main/\1/'
}

getLatestCommitHashOrRevisionFromBuilder() {
    local builderId=$1
    local url="https://build.webkit.org/api/v2/builders/${builderId}/builds?order=-number&limit=1&property=got_revision&complete=true&results=0"
    local hash
    hash=$(curl -s "$url" | jq -r '.builds[0].properties.got_revision[0]')
    echo "$hash"
}

getLatestRevisionFromBuilder() {
    local builderId=$1
    local hash
    hash=$(getLatestCommitHashOrRevisionFromBuilder "$builderId")
    hashToRevision "$hash"
}

getLatestVersion() {
    case "$TARGET" in
        "aarch64-apple-darwin")
          getLatestRevisionFromBuilder 938
          ;;
        "x86_64-apple-darwin")
          getLatestRevisionFromBuilder 706
          ;;
        # "linux64")
        #     curl -s "https://webkitgtk.org/jsc-built-products/x86_64/release/LAST-IS" |
        #         grep -oP '(\d+)@main\.zip' |
        #         sed 's/@main\.zip//'
        #     ;;
        # "win64")
        #     getLatestRevisionFromBuilder 27
        #     ;;
        # "mac64"|"mac64arm")
        #     name=$2
        #     case "$name" in
        #         "ventura")
        #             getLatestRevisionFromBuilder 706
        #             ;;
        #         "monterey")
        #             getLatestRevisionFromBuilder 368
        #             ;;
        #         "sonoma")
        #             getLatestRevisionFromBuilder 938
        #             ;;
        #         "sequoia")
        #             getLatestRevisionFromBuilder 1223
        #             ;;
        #         *)
        #             echo "Error: Unknown MacOS name: $name" >&2
        #             return 1
        #             ;;
        #     esac
        #     ;;
        # *)
        #     echo "Error: JavaScriptCore does not offer precompiled $os binaries." >&2
        #     return 1
        #     ;;
    esac
}


# NAME=$(curl -s "https://webkitgtk.org/jsc-built-products/x86_64/release/LAST-IS")
version=$(getLatestVersion)
NAME="${version}@main.zip"
echo $NAME

DOWNLOAD_URL="${BASE_URL}/${NAME}"
DIST="jsc-${TARGET}"
ARTIFACT_ZIP_NAME="jsc-${TARGET}.zip"
UNZIP_DIR="jsc-unzip-${TARGET}"

curl -L -o "${ARTIFACT_ZIP_NAME}" "$DOWNLOAD_URL"

mkdir $UNZIP_DIR
mkdir -p $DIST/bin

unzip -q "${ARTIFACT_ZIP_NAME}" -d $UNZIP_DIR

cp "./${UNZIP_DIR}/Release/JavaScriptCore.framework/Versions/A/JavaScriptCore" $DIST/bin/jsc

chmod +x $DIST/bin/jsc
ls -lh $DIST/bin

cd $DIST
tar -cJf "../jsc-${TARGET}.tar.xz" ./bin/jsc

cd ..
