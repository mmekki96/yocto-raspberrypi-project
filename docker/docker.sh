#!/bin/sh

if [ $# -ne 2 ]; then 
    echo "Usage: $0 [build/shell/checkout] <path/to/yml>"
    return 1
fi

PROJECT_DIR=$(realpath $(dirname $0)/..)
VENV_DIR=${PROJECT_DIR}/yocto-venv

prepare_env() {
    # 1- Check if the virtual environment exists
    if [ -d "${VENV_DIR}" ]; then
        if [ ! ${VENV_DIR}/pyvenv.cfg ]; then
            echo "[!] The ${VENV_DIR} is not a python virtual environment"
            echo "[!] Make sure to delete the ${VENV_DIR}"
            return 1
        fi
    else
        # Create the virtual environment if it doesn't exist
        echo "[.] Creating virtual environment ..."
        python3 -m venv "$VENV_DIR" || {
            echo "[!] Failed to setup python3 venv"
        }
    fi
 
    # 2- Sourcing the virtual environment
    echo "[.] Sourcing the virtual environment ..."
    . ${VENV_DIR}/bin/activate || { 
        echo "[!] Failed to setup environment"
    }

    # 3- Install the Kas
    CHECK_KAS=$(pip3 list | grep kas)
    if [ $? -ne 0 ]; then
        echo "[.] Installing kas ..."
        pip3 install kas || {
            echo "[!] Failed to install kas"
            return 1
        }
        echo "[.] Installation successfuly done"
    fi
}

check_cmd() {
    CMD=$1
    [ "${CMD}" = "checkout" ] || [ "${CMD}" = "shell" ] || [ "${CMD}" = "build" ] || {
        echo "[!] Wrong command \"${CMD}\". Try instead [checkout/shell/build]"
        return 1
    }
}

main() {
    local ACTION=$1
    local KAS_PATH=$2

    # Test if the command is [checkout, shell or build]
    check_cmd ${ACTION}
    if [ $? -ne 0 ]; then
        return 1
    fi
    echo "[.] Preparing environment ..."
    
    # Prepare environment
    prepare_env
           
    # Run the command
    kas-container ${ACTION} ${KAS_PATH}

    if [ ${ACTION} = "shell" ]; then
        deactivate
    fi
}

main $@