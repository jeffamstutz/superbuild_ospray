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

option(BUILD_OSPRAY "Build OSPRay (ON) or just dependencies (OFF)" ON)

set(DEFAULT_BUILD_COMMAND cmake --build . --config release -j ${NUM_BUILD_JOBS})

get_filename_component(INSTALL_DIR_ABSOLUTE
  ${CMAKE_INSTALL_PREFIX} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})

## Build projects ##

include(get_tbb.cmake)
include(get_ispc.cmake)

build_subproject(
  NAME rkcommon
  URL "https://github.com/ospray/rkcommon/archive/v1.8.0.zip"
  BUILD_ARGS
    -DINSTALL_DEPS=OFF
    -DBUILD_TESTING=OFF
  DEPENDS_ON tbb ispc
)

build_subproject(
  NAME embree
  URL "https://github.com/embree/embree/archive/v3.13.2.zip"
  BUILD_ARGS
    -DEMBREE_TUTORIALS=OFF
    -DBUILD_TESTING=OFF
  DEPENDS_ON rkcommon
)

build_subproject(
  NAME openvkl
  URL "https://github.com/openvkl/openvkl/archive/v1.1.0.zip"
  BUILD_ARGS
    -DBUILD_BENCHMARKS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
  DEPENDS_ON rkcommon embree
)

build_subproject(
  NAME oidn
  URL "https://github.com/OpenImageDenoise/oidn/releases/download/v1.4.2/oidn-1.4.2.src.tar.gz"
  BUILD_ARGS
    -DOIDN_APPS=OFF
  DEPENDS_ON rkcommon
)

if (BUILD_OSPRAY)
  build_subproject(
    NAME ospray
    URL "https://github.com/ospray/ospray/archive/v2.8.0.zip"
    BUILD_ARGS
      -DOSPRAY_BUILD_ISA=ALL
      -DOSPRAY_MODULE_BILINEAR_PATCH=OFF
      -DOSPRAY_MODULE_DENOISER=ON
      -DOSPRAY_ENABLE_APPS=OFF
      -DOSPRAY_STRICT_BUILD=OFF
      -DOSPRAY_INSTALL_DEPENDENCIES=OFF
    DEPENDS_ON rkcommon openvkl embree oidn
  )
endif()
