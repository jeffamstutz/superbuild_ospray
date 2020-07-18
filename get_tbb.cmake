## Copyright 2020 Jefferson Amstutz
## SPDX-License-Identifier: Unlicense

set(SUBPROJECT_NAME tbb-2020.3)
set(TBB_VERSION v2020.3)

if (APPLE)
  set(TBB_URL https://github.com/oneapi-src/oneTBB/releases/download/${TBB_VERSION}/${SUBPROJECT_NAME}-mac.tgz)
elseif(WIN32)
  set(TBB_URL https://github.com/oneapi-src/oneTBB/releases/download/${TBB_VERSION}/${SUBPROJECT_NAME}-win.zip)
else()
  set(TBB_URL https://github.com/oneapi-src/oneTBB/releases/download/${TBB_VERSION}/${SUBPROJECT_NAME}-lin.tgz)
endif()

ExternalProject_Add(tbb
  PREFIX ${SUBPROJECT_NAME}
  STAMP_DIR ${SUBPROJECT_NAME}/stamp
  SOURCE_DIR ${SUBPROJECT_NAME}/unpacked
  BINARY_DIR ""
  URL ${TBB_URL}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND "${CMAKE_COMMAND}" -E copy_directory
    <SOURCE_DIR>/tbb/lib
    ${INSTALL_DIR_ABSOLUTE}/lib
  BUILD_ALWAYS OFF
)

set(TBB_PATH "${SUBPROJECT_NAME}/unpacked")
