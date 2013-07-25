/*
 * Sally - A Tool for Embedding Strings in Vector Spaces
 * Copyright (C) 2010 Konrad Rieck (konrad@mlsec.org)
 * --
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.  This program is distributed without any
 * warranty. See the GNU General Public License for more details. 
 */

#ifndef FVEC_H
#define FVEC_H

#include <stdint.h>

/** Data type for a feature */
typedef uint64_t 	feat_t;

/** Placeholder for non-initialized delimiters */
#define DELIM_NOT_INIT	42

/**
 * Sparse feature vector. The vector is stored as a sorted list 
 * of non-zero dimensions containing real numbers. The dimensions
 * are specified as regular indices or alternatively as 32bit
 * hash values. 
 */
typedef struct {
    feat_t *dim;            /**< List of dimensions */
    float *val;             /**< List of values */
    unsigned long len;      /**< Length of list */
    unsigned long total;    /**< Total features in string */
    float label;            /**< Label of features */
    char *src;              /**< Source of features */
} fvec_t;

/* Functions */
fvec_t *fvec_extract(char *, int l);
void fvec_destroy(fvec_t *);
void fvec_print(FILE *, fvec_t *);
void fvec_realloc(fvec_t *);
void fvec_set_label(fvec_t *fv, float l);
void fvec_set_source(fvec_t *fv, char *s);
void fvec_write(fvec_t *f, gzFile * z);
fvec_t *fvec_zero();
fvec_t *fvec_read(gzFile *);
void fvec_save(fvec_t *fv, char *f);
fvec_t *fvec_load(char *);
void fvec_reset_delim();

#include "fmath.h"
#include "norm.h"
#include "embed.h"
#include "fhash.h"

#endif                          /* FVEC_H */
