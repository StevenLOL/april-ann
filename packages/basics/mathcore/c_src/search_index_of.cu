/*
 * This file is part of the Neural Network modules of the APRIL toolkit (A
 * Pattern Recognizer In Lua).
 *
 * Copyright 2012, Salvador España-Boquera, Adrian Palacios Corella, Francisco
 * Zamora-Martinez
 *
 * The APRIL-MLP toolkit is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */
#include "binary_search.h"
#include "mathcore.h"
#include "unused_variable.h"

using namespace AprilUtils;

namespace AprilMath {

  /// searchs the index where the given coordinate (c1,c2) will is stored, or -1
  /// in case it isn't there
  int doSearchCSCSparseIndexOf(const Int32GPUMirroredMemoryBlock *indices,
                               const Int32GPUMirroredMemoryBlock *first_index,
                               const int c1, const int c2, bool use_gpu) {
#ifndef USE_CUDA
    UNUSED_VARIABLE(use_gpu);
#endif
#ifdef USE_CUDA
    if (use_gpu) {
      ERROR_PRINT("CUDA VERSION NOT IMPLEMENTED\n");
    }
    // else {
#endif
    const int *indices_ptr = indices->getPPALForRead();
    const int *first_index_ptr = first_index->getPPALForRead();
    if (c1 == 0) return first_index_ptr[c2];
    else {
      int idx = binary_search(indices_ptr + first_index_ptr[c2],
                              first_index_ptr[c2+1] - first_index_ptr[c2],
                              c1);
      return (idx >= 0) ? (idx + first_index_ptr[c2]) : idx;
    }
#ifdef USE_CUDA
    // }
#endif
  }

  /// searchs the index where the given coordinate (c1,c2) will is stored, or -1
  /// in case it isn't there
  int doSearchCSRSparseIndexOf(const Int32GPUMirroredMemoryBlock *indices,
                               const Int32GPUMirroredMemoryBlock *first_index,
                               const int c1, const int c2, bool use_gpu) {
#ifndef USE_CUDA
    UNUSED_VARIABLE(use_gpu);
#endif
#ifdef USE_CUDA
    if (use_gpu) {
      ERROR_PRINT("CUDA VERSION NOT IMPLEMENTED\n");
    }
    // else {
#endif
    const int *indices_ptr = indices->getPPALForRead();
    const int *first_index_ptr = first_index->getPPALForRead();
    if (c2 == 0) return first_index_ptr[c1];
    else {
      int idx = binary_search(indices_ptr + first_index_ptr[c1],
                              first_index_ptr[c1+1] - first_index_ptr[c1],
                              c2);
      return (idx >= 0) ? (idx + first_index_ptr[c1]) : idx;
    }
#ifdef USE_CUDA
    // }
#endif
  }

  /////////////////////////////////////////////////////////////////////

  /// searchs the index where the given coordinate (c1,c2) will is stored, or -1
  /// in case it isn't there
  int doSearchCSCSparseIndexOfFirst(const Int32GPUMirroredMemoryBlock *indices,
                                    const Int32GPUMirroredMemoryBlock *first_index,
                                    const int c1, const int c2, bool use_gpu) {
#ifndef USE_CUDA
    UNUSED_VARIABLE(use_gpu);
#endif
#ifdef USE_CUDA
    if (use_gpu) {
      ERROR_PRINT("CUDA VERSION NOT IMPLEMENTED\n");
    }
    // else {
#endif
    const int *indices_ptr = indices->getPPALForRead();
    const int *first_index_ptr = first_index->getPPALForRead();
    if (c1 == 0) return first_index_ptr[c2];
    else {
      const int *aux = binary_search_first(indices_ptr + first_index_ptr[c2],
                                           first_index_ptr[c2+1] - first_index_ptr[c2],
                                           c1);
      if (aux == 0) ERROR_EXIT(128, "Incorrect given coordinates\n");
      return (*aux > 0) ? (*aux + first_index_ptr[c2]) : *aux;
    }
#ifdef USE_CUDA
    // }
#endif
  }

  /// searchs the index where the given coordinate (c1,c2) will is stored, or -1
  /// in case it isn't there
  int doSearchCSRSparseIndexOfFirst(const Int32GPUMirroredMemoryBlock *indices,
                                    const Int32GPUMirroredMemoryBlock *first_index,
                                    const int c1, const int c2, bool use_gpu) {
#ifndef USE_CUDA
    UNUSED_VARIABLE(use_gpu);
#endif
#ifdef USE_CUDA
    if (use_gpu) {
      ERROR_PRINT("CUDA VERSION NOT IMPLEMENTED\n");
    }
    // else {
#endif
    const int *indices_ptr = indices->getPPALForRead();
    const int *first_index_ptr = first_index->getPPALForRead();
    if (c2 == 0) return first_index_ptr[c1];
    else {
      const int *aux = binary_search_first(indices_ptr + first_index_ptr[c1],
                                           first_index_ptr[c1+1] - first_index_ptr[c1],
                                           c2);
      if (aux == 0) ERROR_EXIT(128, "Incorrect given coordinates\n");
      return (*aux > 0) ? (*aux + first_index_ptr[c1]) : *aux;
    }
#ifdef USE_CUDA
    // }
#endif
  }

} // namespace AprilMath
