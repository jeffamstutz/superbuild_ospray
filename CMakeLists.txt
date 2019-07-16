## ======================================================================== ##
## Copyright 2009-2019 Intel Corporation                                    ##
##                                                                          ##
## Licensed under the Apache License, Version 2.0 (the "License");          ##
## you may not use this file except in compliance with the License.         ##
## You may obtain a copy of the License at                                  ##
##                                                                          ##
##     http://www.apache.org/licenses/LICENSE-2.0                           ##
##                                                                          ##
## Unless required by applicable law or agreed to in writing, software      ##
## distributed under the License is distributed on an "AS IS" BASIS,        ##
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. ##
## See the License for the specific language governing permissions and      ##
## limitations under the License.                                           ##
## ======================================================================== ##

cmake_minimum_required(VERSION 3.1)

if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX
      "${CMAKE_BINARY_DIR}/install"
      CACHE STRING "Final install location." FORCE)
endif()

project(SuperbuildTest)

include(ExternalProject)
set(installDir ${CMAKE_INSTALL_PREFIX})

# Options
set(NUM_BUILD_JOBS 4 CACHE STRING "Number of build jobs '-j <n>'")
set(BUILD_EMBREE_VERSION "3.5.2" CACHE STRING "Which version of Embree to build?")
set(BUILD_OSPRAY_BRANCH "devel" CACHE STRING "Which branch of OSPRay to build?")
option(BUILD_DEPENDENCIES_ONLY "Don't build OSPRay itself, only deps" OFF)

set(DEFAULT_BUILD_COMMAND make -j ${NUM_BUILD_JOBS})

## ISPC ##

if (APPLE)
  set(ISPC_URL http://sdvis.org/ospray/download/dependencies/osx/ispc-v1.10.0-osx.tar.gz)
else()
  set(ISPC_URL http://sdvis.org/ospray/download/dependencies/linux/ispc-v1.10.0-linux.tar.gz)
endif()

ExternalProject_Add(ispc
  PREFIX ispc
  INSTALL_DIR ${installDir}/
  URL ${ISPC_URL}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND "${CMAKE_COMMAND}" -E copy_if_different
    <SOURCE_DIR>/bin/ispc${CMAKE_EXECUTABLE_SUFFIX}
    <INSTALL_DIR>/ispc/bin/ispc${CMAKE_EXECUTABLE_SUFFIX}
  BUILD_ALWAYS OFF
)

## TBB ##

ExternalProject_Add(tbb
  PREFIX tbb
  INSTALL_DIR ${installDir}/tbb
  URL "https://github.com/wjakob/tbb/archive/master.zip"
  CMAKE_ARGS
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE=Release
    -DTBB_BUILD_TESTS=OFF
    -DTBB_BUILD_SHARED=ON
    -DTBB_BUILD_STATIC=OFF
  BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
  BUILD_ALWAYS OFF
)

## Embree ##

ExternalProject_Add(embree
  PREFIX embree
  INSTALL_DIR ${installDir}/embree
  URL "https://github.com/embree/embree/archive/v${BUILD_EMBREE_VERSION}.zip"
  CMAKE_ARGS
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DEMBREE_TUTORIALS=OFF
    -DEMBREE_TBB_ROOT=${installDir}/tbb
    -DEMBREE_ISPC_EXECUTABLE=${installDir}/ispc/bin/ispc
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_TESTING=OFF
  BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
  BUILD_ALWAYS OFF
)

ExternalProject_Add_StepDependencies(embree configure ispc tbb)

## OSPRay ##

if (NOT BUILD_DEPENDENCIES_ONLY)
  set(ENV{TBB_ROOT} ${installDir}/tbb)

  ExternalProject_Add(ospray
    PREFIX ospray
    INSTALL_DIR ${installDir}/ospray
    URL "https://github.com/ospray/ospray/archive/${BUILD_OSPRAY_BRANCH}.zip"
    CMAKE_ARGS
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -Dembree_DIR:PATH=${installDir}/embree/lib64/cmake/embree-${BUILD_EMBREE_VERSION}
      -DISPC_EXECUTABLE=${installDir}/ispc/bin/ispc
      -DTBB_INCLUDE_DIR=${installDir}/tbb/include
      -DTBB_LIBRARY=${installDir}/tbb/lib/libtbb${CMAKE_SHARED_LIBRARY_SUFFIX}
      -DTBB_LIBRARY_MALLOC=${installDir}/tbb/lib/libtbbmalloc${CMAKE_SHARED_LIBRARY_SUFFIX}
      -DCMAKE_BUILD_TYPE=Release
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
    BUILD_ALWAYS OFF
  )

  ExternalProject_Add_StepDependencies(ospray configure embree)
endif()
