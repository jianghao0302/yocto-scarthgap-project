#!/bin/sh
# -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
#
# Copyright (C) 2012, 2013 O.S. Systems Software LTDA.
# Authored-by:  Otavio Salvador <otavio@ossystems.com.br>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Use hardcoded name of the script here, do not attempt to determine it.
# It is the safest way, since we want to support all shells
# and practice showed that there is no simple generic way to get the
# script name when sourced (we can't rely on using built-in variables
# $0, $_, $BASH_SOURCE since they behave differently or are not always available)
PROG_NAME="bsp-setup.sh"

# This defines which machine conf files we ignore for the underlying SDK
MACHINE_EXCLUSION="^twr"


DEFAULT_DISTRO="poky"
COMPANY="ALPHA"

# Any Ubuntu machine type
UBUNTU_MACHINE=".+ubuntu"

# Supported yocto version
YOCTO_VERSION="scarthgap"

# Error codes
EINVAL=128

if [ -z "$ZSH_NAME" ] && echo "$0" | grep -q "$PROG_NAME"; then
    echo "ERROR: This script needs to be sourced."
    SCRIPT_PATH=$(readlink -f "$0")
    if is_dash_shell; then
        echo "Try run command \"set -- -h; . $SCRIPT_PATH\" to get help."
    else
        echo "Try run command \". $SCRIPT_PATH -h\" to get help."
    fi
    unset SCRIPT_PATH PROG_NAME
    exit
else
    if [ -n "$BASH_SOURCE" ]; then
        ROOT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
    elif [ -n "$ZSH_NAME" ]; then
        ROOT_DIR=$(dirname "$(readlink -f "$0")")
    else
        ROOT_DIR=$(dirname "$(readlink -f "$PWD")")
    fi
    if ! [ -e "$ROOT_DIR/$PROG_NAME" ];then
        echo "Go to where $PROG_NAME locates, then run: . $PROG_NAME <args>"
        unset ROOT_DIR PROG_NAME
        return
    fi
fi

SOURCES_DIR="sources"
BSP_LIB_DIR=${ROOT_DIR}/bsp
BSP_COMMON_UTILS_SH=${BSP_LIB_DIR}/common-utils.sh
BSP_COMMON_RUNTIME_SH=${BSP_LIB_DIR}/common-runtime.sh
BSP_VENDOR_DIR=${BSP_LIB_DIR}/vendors

if ! [ -e "$BSP_COMMON_UTILS_SH" ]; then
    echo "ERROR: missing common BSP helper file: $BSP_COMMON_UTILS_SH"
    unset ROOT_DIR PROG_NAME SOURCES_DIR BSP_LIB_DIR BSP_COMMON_UTILS_SH BSP_COMMON_RUNTIME_SH BSP_VENDOR_DIR
    return
fi

if ! [ -e "$BSP_COMMON_RUNTIME_SH" ]; then
    echo "ERROR: missing common BSP helper file: $BSP_COMMON_RUNTIME_SH"
    unset ROOT_DIR PROG_NAME SOURCES_DIR BSP_LIB_DIR BSP_COMMON_UTILS_SH BSP_COMMON_RUNTIME_SH BSP_VENDOR_DIR
    return
fi

. "$BSP_COMMON_UTILS_SH"
. "$BSP_COMMON_RUNTIME_SH"

# Check if current user is root
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not use the BSP as root. Exiting..."
    unset ROOT_DIR PROG_NAME
    return
fi

OE_ROOT_DIR=${ROOT_DIR}/${SOURCES_DIR}/poky
if [ -e ${ROOT_DIR}/${SOURCES_DIR}/oe-core ]; then
    OE_ROOT_DIR=${ROOT_DIR}/${SOURCES_DIR}/oe-core
fi
PROJECT_DIR=${ROOT_DIR}/build_${MACHINE}

clean_up()
{
     unset PROG_NAME ROOT_DIR OE_ROOT_DIR PROJECT_DIR \
    META_OE_LAYER_LIST BASE_LAYER_LIST COMMON_FEATURE_LAYER_LIST \
             PROFILE_DEFAULT_DISTRO PROFILE_COMMON_FEATURE_LAYER_LIST \
                 ALPHA_BSP_LAYER_LIST ALPHA_PRODUCT_LAYER_LIST ALPHA_LAYER_LIST \
                 VENDOR_PROFILE_LIST VENDOR_PROFILE_LAYER_LIST SELECTED_VENDOR_PROFILE \
         ACTIVE_LAYER_LIST MACHINE \
         OLD_OPTIND CPUS JOBS THREADS DOWNLOADS CACHES DISTRO \
         setup_flag setup_h setup_j setup_t setup_l setup_builddir \
         setup_download setup_sstate setup_error layer append_layer \
     extra_layers distro_override \
                 DEFAULT_DISTRO COMPANY UBUNTU_MACHINE YOCTO_VERSION EINVAL \
     SOURCES_DIR OPTIND \
                 USAGE_LIST layer_group vendor_profile supported_machines layer_machines \
                 vendor_machine_regex vendor_base_layers vendor_feature_layers vendor_profile_file \
                 BSP_LIB_DIR BSP_COMMON_UTILS_SH BSP_COMMON_RUNTIME_SH BSP_VENDOR_DIR \
                 VENDOR_MACHINE_REGEX_nxp VENDOR_DEFAULT_DISTRO_nxp VENDOR_COMMON_FEATURE_LAYERS_nxp \
                 VENDOR_BASE_LAYERS_nxp VENDOR_FEATURE_LAYERS_nxp \
                 VENDOR_MACHINE_REGEX_renesas VENDOR_DEFAULT_DISTRO_renesas VENDOR_COMMON_FEATURE_LAYERS_renesas \
                 VENDOR_BASE_LAYERS_renesas VENDOR_FEATURE_LAYERS_renesas \
                 MACHINE_LAYER MACHINE_EXCLUSION

             unset -f usage prompt_message is_dash_shell append_layers select_vendor_profile append_vendor_profile_layers resolve_vendor_profile_defaults collect_supported_machines
}

# parse the parameters
OLD_OPTIND=$OPTIND
while getopts "m:j:t:b:d:e:D:c:lh" setup_flag
do
    case $setup_flag in
        m) MACHINE="$OPTARG";
           ;;
        j) setup_j="$OPTARG";
           ;;
        t) setup_t="$OPTARG";
           ;;
        b) setup_builddir="$OPTARG";
           ;;
        d) setup_download="$OPTARG";
           ;;
        e) extra_layers="$OPTARG";
           ;;
        D) distro_override="$OPTARG";
           ;;
        c) setup_sstate="$OPTARG";
           ;;
        l) setup_l='true';
           ;;
        h) setup_h='true';
           ;;
        ?) setup_error='true';
           ;;
    esac
done
OPTIND=$OLD_OPTIND

META_OE_LAYER_LIST=" \
    meta-openembedded/meta-oe \
    meta-openembedded/meta-multimedia \
    meta-openembedded/meta-python \
    meta-openembedded/meta-networking \
    meta-openembedded/meta-gnome \
    meta-openembedded/meta-filesystems \
    meta-openembedded/meta-initramfs \
    meta-openembedded/meta-webserver \
    meta-openembedded/meta-perl \
    meta-openembedded/meta-xfce \
"

BASE_LAYER_LIST=" \
    $META_OE_LAYER_LIST \
    meta-arm/meta-arm \
    meta-arm/meta-arm-toolchain \
"

COMMON_FEATURE_LAYER_LIST=" \
    meta-virtualization \
    meta-security \
    meta-qt6 \
"

ALPHA_BSP_LAYER_LIST=" \
    meta-alpha/meta-alpha-bsp \
"

ALPHA_PRODUCT_LAYER_LIST=" \
    meta-alpha/meta-alpha-product \
"

ALPHA_LAYER_LIST=" \
    $ALPHA_BSP_LAYER_LIST \
    $ALPHA_PRODUCT_LAYER_LIST \
"

VENDOR_PROFILE_LIST=""
for vendor_profile_file in ${BSP_VENDOR_DIR}/*.sh; do
    if [ -e "${vendor_profile_file}" ]; then
        . "${vendor_profile_file}"
    fi
done

ACTIVE_LAYER_LIST=" \
    $BASE_LAYER_LIST \
    $ALPHA_LAYER_LIST \
"

select_vendor_profile
resolve_vendor_profile_defaults
append_layers "$PROFILE_COMMON_FEATURE_LAYER_LIST"
append_vendor_profile_layers "${SELECTED_VENDOR_PROFILE}"
append_layers "$extra_layers"

VENDOR_PROFILE_LAYER_LIST=""
for vendor_profile in $VENDOR_PROFILE_LIST; do
    eval "vendor_base_layers=\${VENDOR_BASE_LAYERS_${vendor_profile}}"
    eval "vendor_feature_layers=\${VENDOR_FEATURE_LAYERS_${vendor_profile}}"
    VENDOR_PROFILE_LAYER_LIST="$VENDOR_PROFILE_LAYER_LIST ${vendor_base_layers} ${vendor_feature_layers}"
done

USAGE_LIST=" \
    $BASE_LAYER_LIST \
    $ALPHA_LAYER_LIST \
    $COMMON_FEATURE_LAYER_LIST \
    $VENDOR_PROFILE_LAYER_LIST \
"

# check the "-h" and other not supported options
if test $setup_error || test $setup_h; then
    usage && clean_up && return
fi


unset DISTRO
if [ -n "$distro_override" ]; then
    DISTRO="$distro_override";
fi

if [ -z "$DISTRO" ]; then
    DISTRO="$PROFILE_DEFAULT_DISTRO"
fi

# Check the machine type specified
# Note that we intentionally do not test ${MACHINE_EXCLUSION}
unset MACHINE_LAYER
if [ -n "${MACHINE}" ]; then
    for layer in $(printf '%s\n' "$ACTIVE_LAYER_LIST" | xargs); do
        if [ -e "${ROOT_DIR}/${SOURCES_DIR}/${layer}/conf/machine/${MACHINE}.conf" ]; then
            MACHINE_LAYER="${ROOT_DIR}/${SOURCES_DIR}/${layer}"
            break
        fi
    done
else
    usage && clean_up && return $EINVAL
fi

if [ -n "${MACHINE_LAYER}" ]; then 
    echo "Configuring for ${MACHINE} and distro ${DISTRO}..."
else
    echo -e "\nThe \$MACHINE you have specified ($MACHINE) is not supported by this build setup."
    usage && clean_up && return $EINVAL
fi

# set default jobs and threads
CPUS=$(grep -c '^processor' /proc/cpuinfo)
JOBS="$(( ${CPUS} * 3 / 2))"
THREADS="$(( ${CPUS} * 2 ))"

# check optional jobs and threads
if printf '%s\n' "$setup_j" | grep -Eq '^[0-9]+$'; then
    JOBS=$setup_j
fi
if printf '%s\n' "$setup_t" | grep -Eq '^[0-9]+$'; then
    THREADS=$setup_t
fi

# set project folder location and name
if [ -n "$setup_builddir" ]; then
    case $setup_builddir in
        /*) PROJECT_DIR="${setup_builddir}" ;;
        *) PROJECT_DIR="$PWD/${setup_builddir}" ;;
    esac
else
    PROJECT_DIR=${ROOT_DIR}/build_${MACHINE}
fi

mkdir -p $PROJECT_DIR

if [ -n "$setup_download" ]; then
    case $setup_download in
        /*) DOWNLOADS="${setup_download}" ;;
        *) DOWNLOADS="$PWD/${setup_download}" ;;
    esac
else
    DOWNLOADS="$ROOT_DIR/downloads"
fi
mkdir -p $DOWNLOADS
DOWNLOADS=$(readlink -f "$DOWNLOADS")

if [ -n "$setup_sstate" ]; then
    case $setup_sstate in
        /*) CACHES="${setup_sstate}" ;;
        *) CACHES="$PWD/${setup_sstate}" ;;
    esac
else
    if printf '%s\n' "${MACHINE}" | grep -Eq "${UBUNTU_MACHINE}"; then
        CACHES="$PROJECT_DIR/sstate-cache-ubuntu"
    else
        CACHES="$PROJECT_DIR/sstate-cache"
    fi
fi
mkdir -p $CACHES
CACHES=$(readlink -f "$CACHES")

# check if project folder was created before
if [ -e "$PROJECT_DIR/SOURCE_THIS" ]; then
    echo "$PROJECT_DIR was created before."
    . $PROJECT_DIR/SOURCE_THIS
    echo "Nothing is changed."
    clean_up && return
fi

# source oe-init-build-env to init build env
cd $OE_ROOT_DIR
set -- $PROJECT_DIR
. ./oe-init-build-env > /dev/null

# if conf/local.conf not generated, no need to go further
if [ ! -e conf/local.conf ]; then
    echo "ERROR: the local.conf is not created, Exit ..."
    clean_up && cd $ROOT_DIR && return
fi

# Remove comment lines and empty lines
sed -i -e '/^#.*/d' -e '/^$/d' conf/local.conf

# Change settings according to the environment
sed -e "s,MACHINE ??=.*,MACHINE ??= '$MACHINE',g" \
        -e "s,SDKMACHINE ??=.*,SDKMACHINE ??= '$SDKMACHINE',g" \
        -e "s,DISTRO ?=.*,DISTRO ?= '$DISTRO',g" \
        -i conf/local.conf

# Clean up PATH, because if it includes tokens to current directories somehow,
# wrong binaries can be used instead of the expected ones during task execution
export PATH="$(printf '%s' "$PATH" | sed 's/\(:.\|:\)*:/:/g;s/^.?://;s/:.?$//')"

# add layers
for layer in $(printf '%s\n' "$ACTIVE_LAYER_LIST" | xargs); do
    append_layer=""
    if [ -e "${ROOT_DIR}/${SOURCES_DIR}/${layer}/conf/layer.conf" ]; then
        append_layer="${ROOT_DIR}/${SOURCES_DIR}/${layer}"
    fi
    if [ -n "${append_layer}" ]; then
        append_layer=$(readlink -f "$append_layer")
        awk '/  "/ && !x {print "'"  ${append_layer}"' \\"; x=1} 1' \
            conf/bblayers.conf > conf/bblayers.conf~
        mv conf/bblayers.conf~ conf/bblayers.conf

        # check if layer is compatible with supported yocto version.
        # if not, make it so.
        conffile_path="${append_layer}/conf/layer.conf"
        if ! grep "LAYERSERIES_COMPAT" "${conffile_path}" | grep -q "${YOCTO_VERSION}"; then
		    sed -E "/LAYERSERIES_COMPAT/s/(\".*)\"/\1 $YOCTO_VERSION\"/g" -i "${conffile_path}"
		    echo Layer ${layer} updated for ${YOCTO_VERSION}.
		fi
    fi
done

cat >> conf/local.conf <<-EOF

# Parallelism Options
BB_NUMBER_THREADS = "$THREADS"
PARALLEL_MAKE = "-j $JOBS"
DL_DIR = "$DOWNLOADS"
SSTATE_DIR = "$CACHES"
EOF

for s in $HOME/.oe $HOME/.yocto; do
    if [ -e $s/site.conf ]; then
        echo "Linking $s/site.conf to conf/site.conf"
        ln -s $s/site.conf conf
    fi
done

# option to enable lite mode for now
if test $setup_l; then
    echo "# delete sources after build" >> conf/local.conf
    echo "INHERIT += \"rm_work\"" >> conf/local.conf
    echo >> conf/local.conf
fi

if printf '%s\n' "$MACHINE" | grep -Eq '^(b4|p5|t1|t2|t4)'; then
    # disable prelink (for multilib scenario) for now
    sed -i s/image-mklibs.image-prelink/image-mklibs/g conf/local.conf
fi

# make a SOURCE_THIS file
if [ ! -e SOURCE_THIS ]; then
    echo "#!/bin/sh" >> SOURCE_THIS
    echo "cd $OE_ROOT_DIR" >> SOURCE_THIS
    echo "set -- $PROJECT_DIR" >> SOURCE_THIS
    echo ". ./oe-init-build-env > /dev/null" >> SOURCE_THIS
    echo "echo \"Back to build project $PROJECT_DIR.\"" >> SOURCE_THIS
fi

prompt_message
cd $PROJECT_DIR
clean_up
