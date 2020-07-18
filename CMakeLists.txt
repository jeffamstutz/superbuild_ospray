## Copyright 2020 Jefferson Amstutz
## SPDX-License-Identifier: Unlicense

cmake_minimum_required(VERSION 3.12)

if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX
      "${CMAKE_BINARY_DIR}/install"
      CACHE STRING "Final install location." FORCE)
endif()

project(build_ospray)

include(ExternalProject)
include(GNUInstallDirs)
include(ProcessorCount)

include(macros.cmake)

# Options ##

ProcessorCount(PROCESSOR_COUNT)
set(NUM_BUILD_JOBS ${PROCESSOR_COUNT} CACHE STRING "Number of build jobs '-j <n>'")

set(DEFAULT_BUILD_COMMAND cmake --build . --config release -j ${NUM_BUILD_JOBS})

get_filename_component(INSTALL_DIR_ABSOLUTE
  ${CMAKE_INSTALL_PREFIX} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})

## Build projects ##

build_subproject(
  NAME rkcommon
  URL "https://github.com/ospray/rkcommon/archive/v1.4.2.zip"
  BUILD_ARGS
    -DINSTALL_DEPS=OFF
    -DBUILD_TESTING=OFF
)

build_subproject(
  NAME embree
  URL "https://github.com/embree/embree/archive/v3.11.0.zip"
  BUILD_ARGS
    -DEMBREE_TUTORIALS=OFF
    -DBUILD_TESTING=OFF
  DEPENDS_ON rkcommon
)

build_subproject(
  NAME openvkl
  URL "https://github.com/openvkl/openvkl/archive/v0.10.0.zip"
  BUILD_ARGS
    -DBUILD_BENCHMARKS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
  DEPENDS_ON rkcommon embree
)

build_subproject(
  NAME oidn
  URL "https://github.com/OpenImageDenoise/oidn/releases/download/v1.2.2/oidn-1.2.2.src.zip"
  BUILD_ARGS
    -DOIDN_APPS=OFF
  DEPENDS_ON rkcommon
)

build_subproject(
  NAME ospray
  URL "https://github.com/ospray/ospray/archive/v2.2.0.zip"
  BUILD_ARGS
    -DOSPRAY_BUILD_ISA=ALL
    -DOSPRAY_ENABLE_TESTING=OFF
    -DOSPRAY_MODULE_BILINEAR_PATCH=OFF
    -DOSPRAY_MODULE_DENOISER=ON
    -DOSPRAY_ENABLE_APPS=OFF
    -DOSPRAY_STRICT_BUILD=OFF
    -DOSPRAY_INSTALL_DEPENDENCIES=OFF
  DEPENDS_ON rkcommon openvkl embree oidn
)
