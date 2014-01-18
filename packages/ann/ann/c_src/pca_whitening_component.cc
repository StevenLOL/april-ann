/*
 * This file is part of APRIL-ANN toolkit (A
 * Pattern Recognizer In Lua with Artificial Neural Networks).
 *
 * Copyright 2013, Francisco Zamora-Martinez
 *
 * The APRIL-ANN toolkit is free software; you can redistribute it and/or modify it
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
#include "unused_variable.h"
#include "error_print.h"
#include "table_of_token_codes.h"
#include "token_vector.h"
#include "token_matrix.h"
#include "pca_whitening_component.h"
#include "wrapper.h"
#include "utilMatrixFloat.h"

#define WEIGHTS_NAME "U_S_epsilon"

namespace ANN {
  
  PCAWhiteningANNComponent::PCAWhiteningANNComponent(MatrixFloat *U,
						     MatrixFloat *S,
						     float epsilon,
						     unsigned int takeN,
						     const char *name) :
    ANNComponent(name, 0,
		 static_cast<unsigned int>(S->size()),
		 (takeN==0)?(static_cast<unsigned int>(S->size())):(takeN)),
    U(U), S(S), epsilon(epsilon),
    dot_product_encoder(0, WEIGHTS_NAME,
			getInputSize(), getOutputSize(),
			true) {
    if (U->getMajorOrder() != CblasColMajor)
      ERROR_EXIT(128, "Incorrect U matrix major order, needed col_major\n");
    if (S->getMajorOrder() != CblasColMajor)
      ERROR_EXIT(128, "Incorrect S matrix major order, needed col_major\n");
    if (U->getNumDim() != 2)
      ERROR_EXIT(128, "Needs a bi-dimensional matrix as U argument\n");
    if (S->getNumDim() != 1)
      ERROR_EXIT(128, "Needs a one-dimensional matrix as S argument\n");
    if (static_cast<int>(takeN) > S->size())
      ERROR_EXIT(128, "Taking more components than size of S matrix\n");
    if (takeN != 0) {
      int coords[2] = { 0,0 };
      int sizes[2] = { U->getDimSize(0), static_cast<int>(takeN) };
      this->U = new MatrixFloat(this->U, coords, sizes, true);
      this->S = new MatrixFloat(this->S, coords+1, sizes+1, true);
    }
    IncRef(this->U);
    IncRef(this->S);
    //
    U_S_epsilon = this->U->clone();
    // regularization
    MatrixFloat *aux_mat = 0;
    MatrixFloat::const_iterator Sit(this->S->begin());
    for (int i=0; i<this->S->size(); ++i, ++Sit) {
      aux_mat = U_S_epsilon->select(1, i, aux_mat);
      aux_mat->scal( 1/sqrtf( (*Sit) + epsilon ) );
    }
    IncRef(U_S_epsilon);
    //
    matrix_set.insert(WEIGHTS_NAME, U_S_epsilon);
    hash<string,ANNComponent*> components_dict;
    dot_product_encoder.build(0, 0, &matrix_set, components_dict);
  }
  
  PCAWhiteningANNComponent::~PCAWhiteningANNComponent() {
    DecRef(U);
    DecRef(S);
    DecRef(U_S_epsilon);
  }
  
  Token *PCAWhiteningANNComponent::doForward(Token* _input, bool during_training) {
    return dot_product_encoder.doForward(_input, during_training);
  }

  Token *PCAWhiteningANNComponent::doBackprop(Token *_error_input) {
    return dot_product_encoder.doBackprop(_error_input);
  }
  
  void PCAWhiteningANNComponent::reset(unsigned int it) {
    dot_product_encoder.reset(it);
  }
  
  ANNComponent *PCAWhiteningANNComponent::clone() {
    PCAWhiteningANNComponent *component = new PCAWhiteningANNComponent(U, S,
								       epsilon,
								       0,
								       name.c_str());
    return component;
  }
  
  void PCAWhiteningANNComponent::build(unsigned int _input_size,
				       unsigned int _output_size,
				       MatrixFloatSet *weights_dict,
				       hash<string,ANNComponent*> &components_dict) {
    // TODO: CHECK INPUT OUTPUT SIZES
    UNUSED_VARIABLE(_input_size);
    UNUSED_VARIABLE(_output_size);
    UNUSED_VARIABLE(weights_dict);
    UNUSED_VARIABLE(components_dict);
  }
  
  char *PCAWhiteningANNComponent::toLuaString() {
    buffer_list buffer;
    char *U_str, *S_str;
    int len;
    U_str = writeMatrixFloatToString(U, false, len);
    S_str = writeMatrixFloatToString(S, false, len);
    buffer.printf("ann.components.pca_whitening{ name='%s', U=%s, S=%s, epsilon=%g, takeN=0, }",
		  name.c_str(), U_str, S_str, epsilon);
    delete[] U_str;
    delete[] S_str;
    return buffer.to_string(buffer_list::NULL_TERMINATED);
  }
}