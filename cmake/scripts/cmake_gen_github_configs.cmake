# Copyright (c) 2020 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include(${CMAKE_CURRENT_LIST_DIR}/../config_generation.cmake)

# TBBConfig in TBB provided packages are expected to be placed into: <tbb-root>/lib[/<intel64|ia32>]/cmake/TBB
set(WIN_LIN_INC_REL_PATH "../../../../include")
set(DARWIN_INC_REL_PATH "../../../include")
set(LIB_REL_PATH "../..")
set(DLL_REL_PATH "../../../../redist")  # ia32/intel64 subdir is appended depending on configuration.

# Parse version info
file(READ ${CMAKE_CURRENT_LIST_DIR}/../../include/tbb/version.h _tbb_version_info)
string(REGEX REPLACE ".*#define TBB_VERSION_MAJOR ([0-9]+).*" "\\1" _tbb_ver_major "${_tbb_version_info}")
string(REGEX REPLACE ".*#define TBB_VERSION_MINOR ([0-9]+).*" "\\1" _tbb_ver_minor "${_tbb_version_info}")
string(REGEX REPLACE ".*#define TBB_INTERFACE_VERSION ([0-9]+).*" "\\1" _tbb_interface_ver "${_tbb_version_info}")
string(REGEX REPLACE ".*#define __TBB_BINARY_VERSION ([0-9]+).*" "\\1" TBB_BINARY_VERSION "${_tbb_version_info}")
file(READ ${CMAKE_CURRENT_LIST_DIR}/../../CMakeLists.txt _tbb_cmakelist)
string(REGEX REPLACE ".*TBBMALLOC_BINARY_VERSION ([0-9]+).*" "\\1" TBBMALLOC_BINARY_VERSION "${_tbb_cmakelist}")
set(TBBMALLOC_PROXY_BINARY_VERSION ${TBBMALLOC_BINARY_VERSION})
string(REGEX REPLACE ".*TBBBIND_BINARY_VERSION ([0-9]+).*" "\\1" TBBBIND_BINARY_VERSION "${_tbb_cmakelist}")

# Parse patch and tweak versions from interface version: e.g. 12014 --> 01 - patch version, 4 - tweak version.
math(EXPR _tbb_ver_patch "${_tbb_interface_ver} % 1000 / 10")
math(EXPR _tbb_ver_tweak "${_tbb_interface_ver} % 10")

# Applicable for beta releases.
if (_tbb_ver_patch EQUAL 0)
    math(EXPR _tbb_ver_tweak "${_tbb_ver_tweak} + 6")
endif()

set(COMMON_ARGS
    LIB_REL_PATH ${LIB_REL_PATH}
    VERSION ${_tbb_ver_major}.${_tbb_ver_minor}.${_tbb_ver_patch}.${_tbb_ver_tweak}
    TBB_BINARY_VERSION ${TBB_BINARY_VERSION}
    TBBMALLOC_BINARY_VERSION ${TBBMALLOC_BINARY_VERSION}
    TBBMALLOC_PROXY_BINARY_VERSION ${TBBMALLOC_PROXY_BINARY_VERSION}
    TBBBIND_BINARY_VERSION ${TBBBIND_BINARY_VERSION}
)

tbb_generate_config(INSTALL_DIR ${INSTALL_DIR}/linux-32   SYSTEM_NAME Linux   INC_REL_PATH ${WIN_LIN_INC_REL_PATH} SIZEOF_VOID_P 4 HANDLE_SUBDIRS ${COMMON_ARGS})
tbb_generate_config(INSTALL_DIR ${INSTALL_DIR}/linux-64   SYSTEM_NAME Linux   INC_REL_PATH ${WIN_LIN_INC_REL_PATH} SIZEOF_VOID_P 8 HANDLE_SUBDIRS ${COMMON_ARGS})
tbb_generate_config(INSTALL_DIR ${INSTALL_DIR}/windows-32 SYSTEM_NAME Windows INC_REL_PATH ${WIN_LIN_INC_REL_PATH} SIZEOF_VOID_P 4 HANDLE_SUBDIRS DLL_REL_PATH ${DLL_REL_PATH}/ia32 ${COMMON_ARGS})
tbb_generate_config(INSTALL_DIR ${INSTALL_DIR}/windows-64 SYSTEM_NAME Windows INC_REL_PATH ${WIN_LIN_INC_REL_PATH} SIZEOF_VOID_P 8 HANDLE_SUBDIRS DLL_REL_PATH ${DLL_REL_PATH}/intel64 ${COMMON_ARGS})
tbb_generate_config(INSTALL_DIR ${INSTALL_DIR}/darwin     SYSTEM_NAME Darwin  INC_REL_PATH ${DARWIN_INC_REL_PATH}  SIZEOF_VOID_P 8 ${COMMON_ARGS})
message(STATUS "TBBConfig files were created in ${INSTALL_DIR}")
