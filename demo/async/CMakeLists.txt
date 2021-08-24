#
# Copyright 2018 Capitar IT Group BV <info@capitar.com>
# Copyright 2018 Staysail Systems, Inc. <info@staysail.tech>
#
# This software is supplied under the terms of the MIT License, a
# copy of which should be located in the distribution where this
# file was obtained (LICENSE.txt).  A copy of the license may also be
# found online at https://opensource.org/licenses/MIT.

cmake_minimum_required (VERSION 2.8.7)

project(nng-asyncdemo)

set(PROJECT_EXE_SERVER nng-async-server)
set(PROJECT_EXE_CLIENT nng-async-client)
set(CMAKE_BUILD_TYPE Release)
# set(PROJECT_LD_PATH $ENV{PKG_LIBRARY_PATH})

set(PARALLEL 128 CACHE STRING "Parallelism (min 4, max 1000)")

# Call this from your own project's makefile.
find_package(nng CONFIG REQUIRED)
find_package(Threads)

# link_directories(${PROJECT_LD_PATH})

add_executable(${PROJECT_EXE_SERVER} server.c)
target_link_libraries(${PROJECT_EXE_SERVER} nng::nng)
target_compile_definitions(${PROJECT_EXE_SERVER} PRIVATE -DPARALLEL=${PARALLEL})

add_executable(${PROJECT_EXE_CLIENT} client.c)
target_link_libraries(${PROJECT_EXE_CLIENT} nng::nng)

install(TARGETS ${PROJECT_EXE_SERVER} RUNTIME DESTINATION bin)
install(TARGETS ${PROJECT_EXE_CLIENT} RUNTIME DESTINATION bin)
