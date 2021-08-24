#!/bin/sh

TOP_DIR=$(pwd)
INSTALL_PREFIX=${TOP_DIR}/install
BUILD_PREFIX=${TOP_DIR}/build
INSTALL_PKGEXE_PATH=${INSTALL_PREFIX}/bin
INSTALL_PKGINC_PATH=${INSTALL_PREFIX}/include
INSTALL_PKGLIB_PATH=${INSTALL_PREFIX}/lib
INSTALL_PKGCFG_PATH=${INSTALL_PKGLIB_PATH}/pkgconfig
export PKG_CONFIG_PATH=${INSTALL_PKGCFG_PATH}:${PKG_CONFIG_PATH}
export PKG_LIBRARY_PATH=${INSTALL_PKGLIB_PATH}

clean_target() {
    echo "Clean target begin ..."
    [[ -d ${INSTALL_PREFIX} ]] && rm -rf ${INSTALL_PREFIX}
    [[ -d ${BUILD_PREFIX} ]] && rm -rf ${BUILD_PREFIX}

    mkdir -p ${INSTALL_PREFIX}
    mkdir -p ${INSTALL_PKGCFG_PATH}
    mkdir -p ${BUILD_PREFIX}
    echo "Clean target end ..."
}

build_prepare() {
    local target=$1
    local target_dir=${TOP_DIR}/${target}
    local build_dir=${BUILD_PREFIX}/${target}
    echo "Target [${target}] prepare begin ..."
    [[ -d ${build_dir} ]] && rm -rf ${build_dir}
    mkdir -p ${build_dir} # && cp -ra ${target_dir} ${build_dir}
    echo "Target [${target}] prepare end ..."
}

build_target() {
    local target=$1
    local target_dir=${TOP_DIR}/${target}
    local build_dir=${BUILD_PREFIX}/${target}

    echo "Build [${target}] begin ..."
    build_prepare ${target}

    if [[ -f ${target_dir}/CMakeLists.txt ]] && [[ -d ${build_dir} ]]; then
        echo "Build [${target}] ..."
        cd ${build_dir}
        cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ${target_dir}
        make && make install #&& cd ..
        cd ..
    fi
    echo "Build [${target}] end ..."
}

install_pkgcfg() {
    pkgcfg_dir=${TOP_DIR}/pkgconfig
    echo "Install pkgconfig begin ..."
    [[ -d ${pkgcfg_dir} ]] && {
        cd ${pkgcfg_dir}
        local pkgconfig=$(ls *.pc.in)
        for pc in ${pkgconfig}; do
            local pcname=$(echo "${pc}" | sed 's/.in//g')
            echo "Install pkgconfig [${pc}], name[${pcname}] ..."
            [[ -n "${pcname}" ]] && {
                sed -e "s#@CMAKE_INSTALL_PREFIX@#${INSTALL_PREFIX}#g" ${pc} > ${INSTALL_PKGCFG_PATH}/${pcname}
            }
        done
        cd ..
    }
    echo "Install pkgconfig end ..."
}

run_target() {
    target=$1
    echo "Run [${target}] begin ..."
    if [[ -f ${INSTALL_PKGEXE_PATH}/${target} ]]; then
        cd ${INSTALL_PKGEXE_PATH} && ./${target}
    fi
    echo "Run [${target}] end ..."
}

clean_target
install_pkgcfg
build_target nng
build_target demo/async
build_target demo/http_client
build_target demo/raw
build_target demo/reqrep
build_target demo/rest