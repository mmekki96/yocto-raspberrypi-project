#!/bin/sh

if [ $# -ne 1 ]; then 
    echo "Usage: $0 [checkout | build | shell]"
    exit 1
fi

PRJ_DIR=$(realpath $(dirname $0)/..)
KAS_DIR=${PRJ_DIR}/kas
KAS_CONF=${PRJ_DIR}/kas-config

prepare_env() {
    if [ ! -d ${KAS_DIR} ]; then
        echo "[.] Cloning KAS official repo ..."
        git clone https://github.com/siemens/kas.git
        chmod +x ${KAS_DIR}/kas-container
    else
        echo "[.] KAS repo exists"
    fi
}

check_cmd() {
    CMD=$1
    [ ${CMD} = "checkout" ] || [ ${CMD} = "build" ] || [ ${CMD} = "shell" ] || {
        echo "[!] Wrong command \'${CMD}\'"
        return 1
    }
}

main() {
    ACTION=$1
    check_cmd ${ACTION}
    if [ $? -ne  0 ]; then
        exit 1
    fi

    echo "[.] Preparing environment ..."

    prepare_env

    ${KAS_DIR}/kas-container ${ACTION} ${KAS_CONF}/kas-core-image-minimal-rpi4.yml
}

main $@