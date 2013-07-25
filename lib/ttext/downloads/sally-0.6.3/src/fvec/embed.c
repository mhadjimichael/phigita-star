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

/** 
 * @addtogroup fvec Feature vector
 * @author Konrad Rieck (konrad@mlsec.org)
 * @{
 */

#include "config.h"
#include "common.h"
#include "fvec.h"
#include "fmath.h"
#include "util.h"
#include "input.h"

/**< Weights for TFIDF normalization */
static fvec_t *idf_weights = NULL;
/**< Global configuration */
extern config_t cfg;

/**
 * Embeds a feature vector using a given normalization.
 * @param fv Feature vector
 * @param n normalization mode
 */
void fvec_embed(fvec_t *fv, const char *n)
{
    int i;
    double s = 0;
    
    if (!strcasecmp(n, "cnt")) {
        /* Nothing */
    } else if (!strcasecmp(n, "bin")) {
        for (i = 0; i < fv->len; i++)
            fv->val[i] = 1;
    } else if (!strcasecmp(n, "tfidf")) {
        /* Normalize to frequencies */
        for (i = 0; i < fv->len; i++)
            s += fv->val[i];
        for (i = 0; i < fv->len; i++)
            fv->val[i] = fv->val[i] / s;
    
        /* Multiply with pre-computed IDF weights */
        assert(idf_weights);
        fvec_times(fv, idf_weights);
    } else {
        warning("Unknown embedding mode '%s', using 'cnt.", n);
    }
} 


/**
 * Compute IDF weighting
 * @param input Input source 
 */
void idf_create(char *input)
{
    long read, entries, i, j;
    int chunk;
    const char *in_format;
    const char *tfidf_file;

    config_lookup_string(&cfg, "input.input_format", &in_format);
    config_lookup_int(&cfg, "input.chunk_size", &chunk);
    config_lookup_string(&cfg, "features.tfidf_file", &tfidf_file);

    /* Load old file if present */
    if (!access(tfidf_file, R_OK)) {
        info_msg(1, "Loading IDF weights from '%s'.", tfidf_file);
        idf_weights = fvec_load((char *) tfidf_file);
        return;
    }

    /* Allocate stuff */
    string_t *strs = alloca(sizeof (string_t) * chunk);
    idf_weights = fvec_zero();

    /* Open input */
    input_config(in_format);
    entries = input_open(input);
    
    if (entries <= 0) {
        error("Could not open input for computing IDF weights");
        return;
    }

    info_msg(1, "Computing IDF weights from %d strings in chunks of %d.", 
                entries, chunk);

    for (i = 0, read = 0; i < entries; i += read) {
        read = input_read(strs, chunk);
        if (read <= 0)
            continue;

        for (j = 0; j < read; j++) {
            fvec_t *x = fvec_extract(strs[j].str, strs[j].len);
            fvec_binarize(x);
            fvec_add(idf_weights, x);
            fvec_destroy(x);
        }

        /* Free memory */
        input_free(strs, read);
        prog_bar(0, entries, i + read);
    }

    /* Close input */
    input_close();
    
    /* Finish computation */
    fvec_invert(idf_weights);
    fvec_mul(idf_weights, entries);
    fvec_log2(idf_weights);
    
    info_msg(1, "Saving IDF weights to '%s'.", tfidf_file);
    fvec_save(idf_weights, (char *) tfidf_file);
} 

/**
 * Destroys the IDF weights
 */
void idf_destroy()
{
    fvec_destroy(idf_weights);
}

/** @} */
