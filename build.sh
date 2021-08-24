#!/bin/sh

TOP_DIR=$(pwd)
INSTALL_PREFIX=${TOP_DIR}/install
BUILD_PREFIX=${TOP_DIR}/build
INSTALL_PKGEXE_PATH=${INSTALL_PREFIX}/bin
INSTALL_PKGINC_PATH=${INSTALL_PREFIX}/include
INSTALL_PKGLIB_PATH=${INSTALL_PREFIX}/lib
INSTALL_PKGCFG_PATH=${INSTALL_PKGLIB_PATH}/pkgconfig
export INSTALL_PKGEXE_PATH=${INSTALL_PKGEXE_PATH}
export PKG_CONFIG_PATH=${INSTALL_PKGCFG_PATH}:${PKG_CONFIG_PATH}
export PKG_LIBRARY_PATH=${INSTALL_PKGLIB_PATH}

DEBUG_LOG_FILE= #"debug.log"

debug_print() {
    cut_time=$(date +%s)

    echo ">>>>>> [${cut_time}] >>>>>> $*"
    if [[ -n "${DEBUG_LOG_FILE}" ]]; then
        echo ">>>>>> [${cut_time}] >>>>>> $*" >> ${DEBUG_LOG_FILE}
    fi
}

clean_target() {
    debug_print "Clean target begin ..."
    [[ -d ${INSTALL_PREFIX} ]] && rm -rf ${INSTALL_PREFIX}
    [[ -d ${BUILD_PREFIX} ]] && rm -rf ${BUILD_PREFIX}

    mkdir -p ${INSTALL_PREFIX}
    mkdir -p ${INSTALL_PKGCFG_PATH}
    mkdir -p ${BUILD_PREFIX}
    debug_print "Clean target end ..."
}

build_prepare() {
    local target=$1
    local target_dir=${TOP_DIR}/${target}
    local build_dir=${BUILD_PREFIX}/${target}
    debug_print "Target [${target}] prepare begin ..."
    [[ -d ${build_dir} ]] && rm -rf ${build_dir}
    mkdir -p ${build_dir} # && cp -ra ${target_dir} ${build_dir}
    debug_print "Target [${target}] prepare end ..."
}

build_target() {
    local target=$1
    local target_dir=${TOP_DIR}/${target}
    local build_dir=${BUILD_PREFIX}/${target}

    debug_print "Build [${target}] begin ..."
    build_prepare ${target}

    if [[ -f ${target_dir}/CMakeLists.txt ]] && [[ -d ${build_dir} ]]; then
        debug_print "Build [${target}] ..."
        cd ${build_dir}
        cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ${target_dir}
        make >/dev/null && make install >/dev/null #&& cd ..
        cd ..
    fi
    debug_print "Build [${target}] end ..."
}

install_pkgcfg() {
    pkgcfg_dir=${TOP_DIR}/pkgconfig
    debug_print "Install pkgconfig begin ..."
    [[ -d ${pkgcfg_dir} ]] && {
        cd ${pkgcfg_dir}
        local pkgconfig=$(ls *.pc.in)
        for pc in ${pkgconfig}; do
            local pcname=$(debug_print "${pc}" | sed 's/.in//g')
            debug_print "Install pkgconfig [${pc}], name[${pcname}] ..."
            [[ -n "${pcname}" ]] && {
                sed -e "s#@CMAKE_INSTALL_PREFIX@#${INSTALL_PREFIX}#g" ${pc} > ${INSTALL_PKGCFG_PATH}/${pcname}
            }
        done
        cd ..
    }
    debug_print "Install pkgconfig end ..."
}

run_target() {
    local target=$1
    local target_dir=${TOP_DIR}/${target}
    local build_dir=${BUILD_PREFIX}/${target}

    debug_print "Run [${target}] begin ..."
    if [[ -f ${target_dir}/run.sh ]]; then
        cd ${target_dir} && ./run.sh
    fi
    debug_print "Run [${target}] end ..."
}

prepare_sh() {
    clean_target
    install_pkgcfg
    build_target nng
}

build_sh() {
    target=$1
    if [[ -z "${target}" ]]; then
        targets=$(ls demo)
        for tg in ${targets}; do
            build_target demo/${tg} &
        done
    else
        build_target ${target} &
    fi
}

run_sh() {
    target=$1
    if [[ -z "${target}" ]]; then
        targets=$(ls demo)
        for tg in ${targets}; do
            run_target demo/${tg} &
        done
    else
        run_target ${target} &
    fi
}

stop_sh() {
    target=$1
    if [[ -z "${target}" ]]; then
        targets=$(ls ${INSTALL_PKGEXE_PATH})
        for tg in ${targets}; do
            killall -9 ${tg}
        done
    else
        killall -9 ${target}
    fi
}

print_help() {
    local app_name="$1"
    echo "Usage:"
    echo "$app_name <option> [target]"
    echo "Option:"
    echo "    prepare"
    echo "    build [target]"
    echo "    run [target]"
    echo "    stop [target]"
    echo "Targets:"
    targets=$(ls demo)
    for tg in ${targets}; do
        echo "    demo/${tg}"
    done
}

option=$1
target=$2
case "${option}" in
    prepare)
        debug_print "target prepare begin"
        prepare_sh
        debug_print "target prepare end"
        ;;
    build)
        debug_print "target build begin"
        build_sh ${target}
        debug_print "target build end"
        ;;
    run)
        debug_print "target run begin"
        run_sh ${target}
        debug_print "target run end"
        ;;
    stop)
        debug_print "target stop begin"
        stop_sh ${target}
        debug_print "target stop end"
        ;;
    *)
        print_help "$0"
        ;;
esac