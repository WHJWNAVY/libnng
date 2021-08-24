#
# Copyright 2018 Capitar IT Group BV <info@capitar.com>
# Copyright 2018 Staysail Systems, Inc. <info@staysail.tech>
#
# This software is supplied under the terms of the MIT License, a
# copy of which should be located in the distribution where this
# file was obtained (LICENSE.txt).  A copy of the license may also be
# found online at https://opensource.org/licenses/MIT.

cmake_minimum_required (VERSION 2.8.7)

project(pair)

set(PROJECT_EXE_PAIR nng-pair)
set(CMAKE_BUILD_TYPE Release)
# set(PROJECT_LD_PATH $ENV{PKG_LIBRARY_PATH})

find_package(nng CONFIG REQUIRED)
find_package(Threads)

# link_directories(${PROJECT_LD_PATH})

add_executable(${PROJECT_EXE_PAIR} pair.c)
target_link_libraries(${PROJECT_EXE_PAIR} nng::nng)
target_compile_definitions(${PROJECT_EXE_PAIR} PRIVATE -DPARALLEL=${PARALLEL})

install(TARGETS ${PROJECT_EXE_PAIR} RUNTIME DESTINATION bin)
