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

set(NUM_BUILD_JOBS 4 CACHE INT "Number of build jobs '-j <n>'")
set(DEFAULT_BUILD_COMMAND make -j ${NUM_BUILD_JOBS})

## ISPC ##

ExternalProject_Add(ispc
  PREFIX ispc
  INSTALL_DIR ${installDir}/
  URL http://sdvis.org/ospray/download/dependencies/linux/ispc-v1.10.0-linux.tar.gz
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
  URL "https://github.com/embree/embree/archive/master.zip"
  CMAKE_ARGS
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

ExternalProject_Add(ospray
  PREFIX ospray
  INSTALL_DIR ${installDir}/ospray
  URL "https://github.com/ospray/ospray/archive/devel.zip"
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>/ospray
    -Dembree_DIR:PATH=<INSTALL_DIR>/embree/lib64/cmake
    -DISPC_EXECUTABLE=${installDir}/ispc/bin/ispc
    -DCMAKE_BUILD_TYPE=Release
  BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
  BUILD_ALWAYS OFF
)

ExternalProject_Add_StepDependencies(ospray configure embree)
