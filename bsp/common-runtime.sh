append_layers()
{
    layer_group=$1

    [ -z "${layer_group}" ] && return

    for layer in $(printf '%s\n' "${layer_group}" | xargs); do
        ACTIVE_LAYER_LIST="$ACTIVE_LAYER_LIST \
            $layer \
        "
    done
}

prompt_message()
{
    local image_recipe=''
    local image_recipes=''

    cat <<EOF
Welcome to ${COMPANY} Auto Linux BSP (Reference Distro)

The Yocto Project has extensive documentation about OE including a
reference manual which can be found at:
    http://yoctoproject.org/documentation

For more information about OpenEmbedded see their website:
    http://www.openembedded.org/

You can now run 'bitbake <target>'
EOF

    echo "Targets specific to ${COMPANY}:"
    for layer in $(printf '%s\n' "$ACTIVE_LAYER_LIST" | xargs); do
        image_recipes=$(find "${ROOT_DIR}/${SOURCES_DIR}/${layer}" \
            \( -path '*recipes-*/images/fsl*.bb' -o -path '*/images/fsl*.bb' \) 2>/dev/null)
        if [ -n "$image_recipes" ]; then
            for image_recipe in $(printf '%s\n' "$image_recipes" | xargs); do
                image_recipe=$(basename "$image_recipe")
                image_recipe=${image_recipe%.bb}
                echo "    $image_recipe"
            done
        fi
    done

    echo "To return to this build environment later please run:"
    echo "    . $PROJECT_DIR/SOURCE_THIS"
}

select_vendor_profile()
{
    SELECTED_VENDOR_PROFILE=""

    for vendor_profile in $VENDOR_PROFILE_LIST; do
        eval "vendor_machine_regex=\${VENDOR_MACHINE_REGEX_${vendor_profile}}"

        if [ -n "${vendor_machine_regex}" ] && printf '%s\n' "${MACHINE}" | grep -Eq "${vendor_machine_regex}"; then
            SELECTED_VENDOR_PROFILE=${vendor_profile}
            break
        fi
    done
}

append_vendor_profile_layers()
{
    vendor_profile=$1

    [ -z "${vendor_profile}" ] && return

    eval "vendor_base_layers=\${VENDOR_BASE_LAYERS_${vendor_profile}}"
    eval "vendor_feature_layers=\${VENDOR_FEATURE_LAYERS_${vendor_profile}}"

    append_layers "${vendor_base_layers}"
    append_layers "${vendor_feature_layers}"
}

resolve_vendor_profile_defaults()
{
    PROFILE_DEFAULT_DISTRO="${DEFAULT_DISTRO}"
    PROFILE_COMMON_FEATURE_LAYER_LIST="${COMMON_FEATURE_LAYER_LIST}"

    [ -z "${SELECTED_VENDOR_PROFILE}" ] && return

    eval "vendor_default_distro=\${VENDOR_DEFAULT_DISTRO_${SELECTED_VENDOR_PROFILE}}"
    eval "vendor_common_feature_layers=\${VENDOR_COMMON_FEATURE_LAYERS_${SELECTED_VENDOR_PROFILE}}"

    if [ -n "${vendor_default_distro}" ]; then
        PROFILE_DEFAULT_DISTRO="${vendor_default_distro}"
    fi

    if [ -n "${vendor_common_feature_layers}" ]; then
        PROFILE_COMMON_FEATURE_LAYER_LIST="${vendor_common_feature_layers}"
    fi
}

collect_supported_machines()
{
    supported_machines=""

    for layer in $(printf '%s\n' "$USAGE_LIST" | xargs); do
        if [ -d "${ROOT_DIR}/${SOURCES_DIR}/${layer}/conf/machine" ]; then
            layer_machines=$(ls "${ROOT_DIR}/${SOURCES_DIR}/${layer}/conf/machine" | grep "\.conf" \
                | grep -Ev "^${MACHINE_EXCLUSION}" | sed 's/\.conf//g' | xargs echo)
            if [ -n "${layer_machines}" ]; then
                supported_machines="${supported_machines} ${layer_machines}"
            fi
        fi
    done

    if [ -n "${supported_machines}" ]; then
        printf '%s\n' "${supported_machines}" | xargs -n1 | sort -u | xargs echo
    fi
}

usage()
{
    supported_machines=$(collect_supported_machines)

    echo "Usage: . $PROG_NAME -m <machine>"
    if [ -n "${supported_machines}" ]; then
        printf '\n    Supported machines: %s\n' "${supported_machines}"
    else
        echo "    ERROR: no available machine conf file is found. "
    fi

    cat <<EOF
    Optional parameters:
    * [-m machine]: the target machine to be built.
    * [-b path]:    non-default path of project build folder.
    * [-e layers]:  extra layer names
    * [-D distro]:  override the default distro selection ($PROFILE_DEFAULT_DISTRO)
    * [-j jobs]:    number of jobs for make to spawn during the compilation stage.
    * [-t tasks]:   number of BitBake tasks that can be issued in parallel.
    * [-d path]:    non-default path of DL_DIR (downloaded source)
    * [-c path]:    non-default path of SSTATE_DIR (shared state Cache)
    * [-l]:         lite mode. To help conserve disk space, deletes the building
                    directory once the package is built.
    * [-h]:         help
EOF

    if is_dash_shell; then
        cat <<EOF

    You are using dash which does not pass args when being sourced.
    To workaround this limitation, use "set -- args" prior to
    sourcing this script. For exmaple:
        \$ set -- -m s32g274ardb2 -j 3 -t 2
        \$ . $ROOT_DIR/$PROG_NAME
EOF
    fi
}