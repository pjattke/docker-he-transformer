# ******************************************************************************
# Copyright 2018-2020 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
# ******************************************************************************

include(ExternalProject)

set(EXTERNAL_NGRAPH_INSTALL_DIR ${EXTERNAL_INSTALL_DIR})
set(NGRAPH_TF_CMAKE_PREFIX ext_ngraph_tf)

set(NGRAPH_TF_REPO_URL https://github.com/tensorflow/ngraph-bridge.git)
set(NGRAPH_TF_GIT_LABEL v0.22.0-rc3)
set(NGRAPH_TF_PATCH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/ngraph-tf.patch)

set(NGRAPH_TF_SRC_DIR
    ${CMAKE_BINARY_DIR}/${NGRAPH_TF_CMAKE_PREFIX}/src/${NGRAPH_TF_CMAKE_PREFIX})
set(NGRAPH_TF_BUILD_DIR ${NGRAPH_TF_SRC_DIR}/build_cmake)
set(NGRAPH_TF_ARTIFACTS_DIR ${NGRAPH_TF_BUILD_DIR}/artifacts)

set(NGRAPH_TF_VENV_DIR ${NGRAPH_TF_BUILD_DIR}/venv-tf-py3)

if(OS_VERSION STREQUAL "centos")
  set(NGRAPH_TF_LIB_DIR ${NGRAPH_TF_ARTIFACTS_DIR}/lib64)
else()
  set(NGRAPH_TF_LIB_DIR ${NGRAPH_TF_ARTIFACTS_DIR}/lib)
endif()

set(
  NGRAPH_TF_VENV_LIB_DIR
  ${NGRAPH_TF_VENV_DIR}/lib/${PYTHON_VENV_VERSION}/site-packages/ngraph_bridge)
set(NGRAPH_TF_INCLUDE_DIR ${NGRAPH_TF_ARTIFACTS_DIR}/include)

ExternalProject_Add(ext_ngraph_tf
      GIT_REPOSITORY ${NGRAPH_TF_REPO_URL}
      GIT_TAG ${NGRAPH_TF_GIT_LABEL}
      PREFIX ${NGRAPH_TF_CMAKE_PREFIX}
      CONFIGURE_COMMAND ""
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${NGRAPH_TF_CMAKE_PREFIX}
      PATCH_COMMAND git apply ${NGRAPH_TF_PATCH}
      COMMAND git apply ${CMAKE_CURRENT_SOURCE_DIR}/cmake/make_tf_build_verbose.patch
      COMMAND git apply ${CMAKE_CURRENT_SOURCE_DIR}/cmake/fix_numpy_for_tf.patch
      BUILD_COMMAND python3 ${NGRAPH_TF_SRC_DIR}/build_ngtf.py --use_grappler_optimizer --ngraph_src_dir ${NGRAPH_SRC_DIR}
      INSTALL_COMMAND ln -fs ${NGRAPH_TF_VENV_DIR}
                      ${EXTERNAL_INSTALL_DIR}
      UPDATE_COMMAND "")

ExternalProject_Get_Property(ext_ngraph_tf SOURCE_DIR)
add_library(libngraph_tf INTERFACE)
add_dependencies(libngraph_tf ext_ngraph_tf)

if(NOT EXISTS ${NGRAPH_TF_INCLUDE_DIR})
  file(MAKE_DIRECTORY ${NGRAPH_TF_INCLUDE_DIR})
endif()

install(DIRECTORY ${NGRAPH_TF_LIB_DIR}/
        DESTINATION ${EXTERNAL_INSTALL_LIB_DIR}
        FILES_MATCHING
        PATTERN "*.so"
        PATTERN "*.so.*"
        PATTERN "*.a")

install(DIRECTORY ${NGRAPH_TF_INCLUDE_DIR}/
        DESTINATION ${EXTERNAL_INSTALL_INCLUDE_DIR}
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp")

