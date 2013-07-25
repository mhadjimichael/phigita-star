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

#include "config.h"
#include "common.h"
#include "fhash.h"
#include "tests.h"

/* Test file */
#define TEST_FILE               "test.fh"
/* Number of stress runs */
#define STRESS_RUNS             4096
/* String length */
#define STR_LENGTH              1024

/* Global variables */
int verbose = 5;

/* Test structure */
typedef struct {
    feat_t f;
    char *s;
} test_t;

/* Test features */
test_t tests[] = {
    {0, "a b c d e f"},
    {-1, "a b c d e"},
    {1, "a b c d"},
    {0x10, "a b"},
    {0x100, "a"},
    {0xFFF, ""},
    {0, 0}
};

/* 
 * A simple static test for the feature map
 */
int test_static()
{
    int i, j, k, err = 0;
    fentry_t *f;

    test_printf("Maintenance of feature hash table");

    /* Initialize table */
    fhash_init();
    for (i = 0; tests[i].s != 0; i++)
        fhash_put(tests[i].f, tests[i].s, strlen(tests[i].s) + 1);

    /* Randomly query elements */
    for (j = 0; j < 100; j++) {
        k = rand() % i;
        f = fhash_get(tests[k].f);

        /* Check for correct feature string */
        if (memcmp(f->data, tests[k].s, f->len)) {
            test_error("(%d) '%s' != '%s'", k, f->data, tests[k].s);
            /* ftable_print(); */
            err++;
        }
    }

    test_return(err, 100);

    /* Destroy table */
    fhash_destroy();
    return err;
}

/* 
 * A simple stress test for the feature table
 */
int test_stress()
{
    int i, j, err = 0;
    fentry_t *f;
    feat_t key;
    char buf[STR_LENGTH + 1];

    test_printf("Stress test of feature hash table");

    /* Initialize table */
    fhash_init();

    for (i = 0; i < STRESS_RUNS; i++) {
        /* Create random key and string */
        key = rand() % 100;
        for (j = 0; j < STR_LENGTH; j++)
            buf[j] = rand() % 10 + '0';
        buf[j] = 0;

        switch (rand() % 2) {
        case 0:
            /* Insert random string */
            fhash_put(key, buf, strlen(buf));
            break;
        case 1:
            /* Query for string */
            f = fhash_get(key);
            break;
        }
    }

    test_return(err, STRESS_RUNS);
    
    fhash_destroy();    
    return err;
}

/* 
 * A test for reading and saving the feature table
 */
int test_read_write()
{
    int i, j, err = 0;
    gzFile *z;
    fentry_t *f;

    test_printf("reading and saving of feature hash table");

    /* Create map */
    fhash_init();
    for (i = 0; tests[i].s != 0; i++)
        fhash_put(tests[i].f, tests[i].s, strlen(tests[i].s) + 1);

    /* Create and write feature vectors */
    if (!(z = gzopen(TEST_FILE, "w9"))) {
        printf("Could not create file (ignoring)\n");
        return FALSE;
    }
    
    fhash_write(z);
    gzclose(z);
    fhash_destroy();

    /* Create and read */
    z = gzopen(TEST_FILE, "r");
    fhash_read(z);
    gzclose(z);

    /* Check elements */
    for (j = 0; j < i; j++) {
        f = fhash_get(tests[j].f);

        /* Check for correct feature string */
        if (memcmp(f->data, tests[j].s, f->len)) {
            test_error("(%d) '%s' != '%s'", j, f->data, tests[j].s);
            err++;
        }
    }

    /* Destroy table */
    fhash_destroy();
    unlink(TEST_FILE);

    test_return(err, i);
    return (err > 0);
}


/**
 * Main function
 */
int main(int argc, char **argv)
{
    int err = FALSE;

    err |= test_static();
    err |= test_stress();
    err |= test_read_write();
    
    return err;
}
