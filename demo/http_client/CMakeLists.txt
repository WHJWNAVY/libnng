#
# Copyright 2018 Capitar IT Group BV <info@capitar.com>
# Copyright 2018 Staysail Systems, Inc. <info@staysail.tech>
#
# This software is supplied under the terms of the MIT License, a
# copy of which should be located in the distribution where this
# file was obtained (LICENSE.txt).  A copy of the license may also be
# found online at https://opensource.org/licenses/MIT.

cmake_minimum_required (VERSION 2.8.7)

project(http_client)

set(PROJECT_EXE_HTTP nng-http-client)
set(CMAKE_BUILD_TYPE Release)
# set(PROJECT_LD_PATH $ENV{PKG_LIBRARY_PATH})

# Call this from your own project's makefile.
find_package(nng CONFIG REQUIRED)
find_package(Threads)

# link_directories(${PROJECT_LD_PATH})

add_executable(${PROJECT_EXE_HTTP} http_client.c)
target_link_libraries(${PROJECT_EXE_HTTP} nng::nng)

install(TARGETS ${PROJECT_EXE_HTTP} RUNTIME DESTINATION bin)
