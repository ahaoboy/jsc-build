https://github.com/WebKit/WebKit


## env
```bash
JSC_DIR="$(dirname "$(which jsc)")"
echo "DYLD_FRAMEWORK_PATH=$JSC_DIR" >> "$GITHUB_ENV"
echo "DYLD_LIBRARY_PATH=$JSC_DIR" >> "$GITHUB_ENV"


LINE1="export DYLD_FRAMEWORK_PATH=\"$JSC_DIR\""
LINE2="export DYLD_LIBRARY_PATH=\"$JSC_DIR\""

if ! grep -Fxq "$LINE1" ~/.bashrc; then
  echo "$LINE1" >> ~/.bashrc
fi

if ! grep -Fxq "$LINE2" ~/.bashrc; then
  echo "$LINE2" >> ~/.bashrc
fi
```