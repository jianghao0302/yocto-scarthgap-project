#!/bin/sh
# Lightweight BSP bootstrap entrypoint for ALPHA project.
# Usage (must be sourced): . ./bsp-setup.sh -m imx6ull14x14alpha

PROG_NAME="bsp-setup.sh"
DEFAULT_DISTRO="poky"
YOCTO_VERSION="scarthgap"
EINVAL=128

is_positive_int() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        0) return 1 ;;
        *) return 0 ;;
    esac
}

is_safe_token() {
    case "$1" in
        ''|*[!A-Za-z0-9._-]*) return 1 ;;
        *) return 0 ;;
    esac
}

usage() {
    cat <<'EOF'
Usage: . ./bsp-setup.sh -m <machine> [options]

Required:
  -m <machine>          Target machine, e.g. imx6ull14x14alpha

Optional:
  -b <builddir>         Build directory (default: build_<machine>)
  -D <distro>           Distro (default: poky)
  -d <downloads_dir>    DL_DIR path (default: <repo>/downloads)
  -c <sstate_dir>       SSTATE_DIR path (default: <builddir>/sstate-cache)
  -j <threads>          BB_NUMBER_THREADS
  -t <jobs>             PARALLEL_MAKE jobs count (PARALLEL_MAKE="-j <jobs>")
  -e <extra layers>     Extra layers (space-separated, relative to sources/ or absolute)
  -h                    Show this help
EOF
}

# Script must be sourced.
if [ -z "${ZSH_NAME}" ] && echo "$0" | grep -q "$PROG_NAME"; then
    echo "ERROR: This script needs to be sourced."
    echo "Try: . ./$PROG_NAME -m <machine>"
    exit 1
fi

# Resolve root directory.
if [ -n "${BASH_SOURCE}" ]; then
    ROOT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE}")")
elif [ -n "${ZSH_NAME}" ]; then
    ROOT_DIR=$(dirname "$(readlink -f "$0")")
else
    ROOT_DIR=$(pwd)
fi

SOURCES_DIR="${ROOT_DIR}/sources"
OE_ROOT_DIR="${SOURCES_DIR}/poky"

# Parse args.
MACHINE=""
BUILD_DIR_OPT=""
DISTRO=""
DOWNLOADS_OPT=""
SSTATE_OPT=""
BB_THREADS=""
PARALLEL_JOBS=""
EXTRA_LAYERS=""

OLD_OPTIND=$OPTIND
while getopts "m:b:D:d:c:j:t:e:h" opt; do
    case "$opt" in
        m) MACHINE="$OPTARG" ;;
        b) BUILD_DIR_OPT="$OPTARG" ;;
        D) DISTRO="$OPTARG" ;;
        d) DOWNLOADS_OPT="$OPTARG" ;;
        c) SSTATE_OPT="$OPTARG" ;;
        j) BB_THREADS="$OPTARG" ;;
        t) PARALLEL_JOBS="$OPTARG" ;;
        e) EXTRA_LAYERS="$OPTARG" ;;
        h) usage; return 0 ;;
        *) usage; return $EINVAL ;;
    esac
done
OPTIND=$OLD_OPTIND

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not use this BSP setup as root."
    return 1
fi

if [ -z "$MACHINE" ]; then
    echo "ERROR: -m <machine> is required."
    usage
    return $EINVAL
fi

if ! is_safe_token "$MACHINE"; then
    echo "ERROR: Invalid machine name: $MACHINE"
    echo "Allowed chars: A-Z a-z 0-9 . _ -"
    return $EINVAL
fi

if [ ! -d "$OE_ROOT_DIR" ]; then
    echo "ERROR: Missing poky at: $OE_ROOT_DIR"
    return 1
fi

MACHINE_CONF="${SOURCES_DIR}/meta-alpha/meta-alpha-bsp/conf/machine/${MACHINE}.conf"
if [ ! -f "$MACHINE_CONF" ]; then
    echo "ERROR: Machine not found in meta-alpha-bsp: $MACHINE"
    echo "Expected: $MACHINE_CONF"
    return $EINVAL
fi

if [ -n "$BUILD_DIR_OPT" ]; then
    case "$BUILD_DIR_OPT" in
        /*) PROJECT_DIR="$BUILD_DIR_OPT" ;;
        *) PROJECT_DIR="${ROOT_DIR}/${BUILD_DIR_OPT}" ;;
    esac
else
    PROJECT_DIR="${ROOT_DIR}/build_${MACHINE}"
fi

if [ -n "$DOWNLOADS_OPT" ]; then
    case "$DOWNLOADS_OPT" in
        /*) DOWNLOADS="$DOWNLOADS_OPT" ;;
        *) DOWNLOADS="${ROOT_DIR}/${DOWNLOADS_OPT}" ;;
    esac
else
    DOWNLOADS="${ROOT_DIR}/downloads"
fi

if [ -n "$SSTATE_OPT" ]; then
    case "$SSTATE_OPT" in
        /*) SSTATE_DIR="$SSTATE_OPT" ;;
        *) SSTATE_DIR="${ROOT_DIR}/${SSTATE_OPT}" ;;
    esac
else
    SSTATE_DIR="${PROJECT_DIR}/sstate-cache"
fi

if [ -z "$DISTRO" ]; then
    DISTRO="$DEFAULT_DISTRO"
fi

if ! is_safe_token "$DISTRO"; then
    echo "ERROR: Invalid distro name: $DISTRO"
    echo "Allowed chars: A-Z a-z 0-9 . _ -"
    return $EINVAL
fi

if [ -n "$BB_THREADS" ] && ! is_positive_int "$BB_THREADS"; then
    echo "ERROR: -j <threads> must be a positive integer."
    return $EINVAL
fi

if [ -n "$PARALLEL_JOBS" ] && ! is_positive_int "$PARALLEL_JOBS"; then
    echo "ERROR: -t <jobs> must be a positive integer."
    return $EINVAL
fi

mkdir -p "$PROJECT_DIR" "$DOWNLOADS" "$SSTATE_DIR"
DOWNLOADS=$(readlink -f "$DOWNLOADS")
SSTATE_DIR=$(readlink -f "$SSTATE_DIR")

# shellcheck disable=SC2164
cd "$OE_ROOT_DIR"
set -- "$PROJECT_DIR"
# shellcheck disable=SC1091
. ./oe-init-build-env >/dev/null

if [ ! -f conf/local.conf ] || [ ! -f conf/bblayers.conf ]; then
    echo "ERROR: Failed to initialize build directory: $PROJECT_DIR"
    return 1
fi

set_conf_var() {
    _file="$1"
    _key="$2"
    _value="$3"
    if grep -Eq "^${_key}[[:space:]]*[?]*=" "$_file"; then
        sed -i -E "s|^${_key}[[:space:]]*[?]*=.*|${_key} = \"${_value}\"|" "$_file"
    else
        printf '%s = "%s"\n' "$_key" "$_value" >> "$_file"
    fi
}

set_conf_var conf/local.conf MACHINE "$MACHINE"
set_conf_var conf/local.conf DISTRO "$DISTRO"
set_conf_var conf/local.conf DL_DIR "$DOWNLOADS"
set_conf_var conf/local.conf SSTATE_DIR "$SSTATE_DIR"

if [ -n "$BB_THREADS" ]; then
    set_conf_var conf/local.conf BB_NUMBER_THREADS "$BB_THREADS"
fi
if [ -n "$PARALLEL_JOBS" ]; then
    set_conf_var conf/local.conf PARALLEL_MAKE "-j ${PARALLEL_JOBS}"
fi

# Layer groups: keep each meta series in its own variable for readability.
# Default set is intentionally minimal for step-by-step development.
OE_LAYER_LIST="
    ${ROOT_DIR}/sources/meta-openembedded/meta-oe
    ${ROOT_DIR}/sources/meta-openembedded/meta-python
    ${ROOT_DIR}/sources/meta-openembedded/meta-networking
    "

ALPHA_LAYER_LIST="
    ${ROOT_DIR}/sources/meta-alpha/meta-alpha-bsp
    ${ROOT_DIR}/sources/meta-alpha/meta-alpha-product
"

# Optional groups (append when needed):
ARM_LAYER_LIST=""
UI_LAYER_LIST=""
SECURITY_LAYER_LIST=""

LAYER_LIST="
    ${OE_LAYER_LIST}
    ${ALPHA_LAYER_LIST}
    ${ARM_LAYER_LIST}
    ${UI_LAYER_LIST}
    ${SECURITY_LAYER_LIST}
"

add_layer_to_bblayers() {
    _layer="$1"
    _bblayers_file="conf/bblayers.conf"

    if [ ! -f "${_layer}/conf/layer.conf" ]; then
        return 0
    fi

    if grep -Fq "${_layer}" "${_bblayers_file}"; then
        return 0
    fi

    sed -i "/^[[:space:]]*\"$/i\  ${_layer} \\\\" "${_bblayers_file}"
}

for layer in $LAYER_LIST; do
    add_layer_to_bblayers "$layer"
done

for layer in $EXTRA_LAYERS; do
    case "$layer" in
        /*) resolved="$layer" ;;
        *) resolved="${ROOT_DIR}/sources/${layer}" ;;
    esac

    if echo "$resolved" | grep -q "${ROOT_DIR}/sources/nxp/"; then
        echo "Skip NXP layer by policy: $resolved"
        continue
    fi

    if [ -f "$resolved/conf/layer.conf" ]; then
        add_layer_to_bblayers "$resolved"
    else
        echo "WARNING: Extra layer not found, skipped: $resolved"
    fi
done

# Keep layer compatibility current.
for layer in $(awk '/^[[:space:]]*\//{gsub(/\\/, "", $1); print $1}' conf/bblayers.conf); do
    conf_file="$layer/conf/layer.conf"
    if [ -f "$conf_file" ] && grep -q "LAYERSERIES_COMPAT" "$conf_file"; then
        if ! grep -q "$YOCTO_VERSION" "$conf_file"; then
            sed -i -E '/LAYERSERIES_COMPAT/s/(".*)"/\1 scarthgap"/' "$conf_file"
        fi
    fi
done

if [ ! -f SOURCE_THIS ]; then
    cat > SOURCE_THIS <<EOF
#!/bin/sh
cd "$OE_ROOT_DIR"
set -- "$PROJECT_DIR"
. ./oe-init-build-env > /dev/null
echo "Back to build project $PROJECT_DIR."
EOF
    chmod +x SOURCE_THIS
fi

echo "Configured machine: $MACHINE"
echo "Build directory: $PROJECT_DIR"
echo "Current directory: $(pwd)"