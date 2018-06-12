source $BP_DIR/lib/binaries.sh

get_unsigned_cache_status() {
  if ! ${NODE_MODULES_CACHE:-true}; then
    echo "disabled"
  elif ! test -d "${CACHE_DIR}/node-unsigned/"; then
    echo "not-found"
  else
    echo "valid"
  fi
}

get_unsigned_cache_directories() {
  local dirs1=$(read_json "$BUILD_DIR/package.json" ".unsignedCacheDirectories | .[]?")
  local dirs2=$(read_json "$BUILD_DIR/package.json" ".unsigned_cache_directories | .[]?")

  if [ -n "$dirs1" ]; then
    echo "$dirs1"
  else
    echo "$dirs2"
  fi
}

restore_unsigned_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  for cachepath in ${@:3}; do
    if [ -e "$build_dir/$cachepath" ]; then
      echo "- $cachepath (exists - skipping)"
    else
      if [ -e "$cache_dir/node-unsigned/$cachepath" ]; then
        echo "- $cachepath"
        mkdir -p $(dirname "$build_dir/$cachepath")
        mv "$cache_dir/node-unsigned/$cachepath" "$build_dir/$cachepath"
      else
        echo "- $cachepath (not cached - skipping)"
      fi
    fi
  done
}

clear_unsigned_cache() {
  rm -rf $CACHE_DIR/node-unsigned
  mkdir -p $CACHE_DIR/node-unsigned
}

save_unsigned_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  for cachepath in ${@:3}; do
    if [ -e "$build_dir/$cachepath" ]; then
      echo "- $cachepath"
      mkdir -p "$cache_dir/node-unsigned/$cachepath"
      cp -a "$build_dir/$cachepath" $(dirname "$cache_dir/node-unsigned/$cachepath")
    else
      echo "- $cachepath (nothing to cache)"
    fi
  done
}
