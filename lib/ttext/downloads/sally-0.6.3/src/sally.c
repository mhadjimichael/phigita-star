/*
 * Sally - A Tool for Embedding Strings in Vector Spaces
 * Copyright (C) 2010-2011 Konrad Rieck (konrad@mlsec.org)
 * --
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.  This program is distributed without any
 * warranty. See the GNU General Public License for more details. 
 */

#include "config.h"
#include "common.h"
#include "sally.h"
#include "input.h"
#include "output.h"
#include "fvec.h"
#include "util.h"
#include "sconfig.h"

/* Global variables */
int verbose = 1;
config_t cfg;

/* Local variables */
static char *input = NULL;
static char *output = NULL;
static long entries = 0;

/* Option string */
#define OPTSTRING       "c:i:o:n:d:E:N:b:vqVh"

/**
 * Array of options of getopt_long()
 */
static struct option longopts[] = {
    { "config_file", 	1, NULL, 'c' },
    { "input_format", 	1, NULL, 'i' },
    { "output_format", 	1, NULL, 'o' },
    { "chunk_size", 	1, NULL, 1000 },
    { "fasta_regex", 	1, NULL, 1001 },
    { "lines_regex", 	1, NULL, 1002 },
    { "ngram_len", 	1, NULL, 'n' },
    { "ngram_delim", 	1, NULL, 'd' },
    { "vect_embed", 	1, NULL, 'E' }, 
    { "vect_norm", 	1, NULL, 'N' },
    { "hash_bits", 	1, NULL, 'b' },
    { "explicit_hash", 	1, NULL, 1003 }, 
    { "tfidf_file", 	1, NULL, 1004 },
    { "verbose", 	0, NULL, 'v' }, 
    { "quiet", 		0, NULL, 'q' },
    { "version", 	0, NULL, 'V' },
    { "help", 		0, NULL, 'h' },
    { NULL, 		0, NULL, 0 }
};

/**
 * Prints version and copyright information to a file stream
 * @param f File pointer
 * @param p Prefix character
 * @param m Message
 * @return number of written characters
 */
int sally_version(FILE *f, char *p, char *m)
{
    return fprintf(f, "%sSally %s - %s\n", p, PACKAGE_VERSION, m);
}

/**
 * Main processing function
 * @param in Input file
 * @param out Output file
 */

/**
 * Print usage of command line tool
 */
static void print_usage(void)
{
    printf("Usage: sally [options] <input> <output>\n"
            "\nI/O options:\n"
            "  -i,  --input_format <format>   Set input format for strings.\n"
            "       --chunk_size <num>        Set chunk size for processing.\n"   
            "       --fasta_regex <regex>     Set RE for labels in FASTA sequences.\n"
            "       --lines_regex <regex>     Set RE for labels in text lines.\n"
            "  -o,  --output_format <format>  Set output format for vectors.\n"            
            "\nFeature options:\n"
            "  -n,  --ngram_len <num>         Set length of n-grams.\n"
            "  -d,  --ngram_delim <delim>     Set delimiters of words in n-grams.\n"
            "  -E,  --vect_embed <embed>      Set embedding mode for vectors.\n"
            "  -N,  --vect_norm <norm>        Set normalization mode for vectors.\n"
            "  -b,  --hash_bits <num>         Set number of hash bits.\n"
            "       --explicit_hash <num>     Set explicit hash representation (0/1).\n"
            "       --tfidf_file <file>       Set file name for TFIDF weighting.\n" 
            "\nGeneric options:\n"
            "  -c,  --config_file <file>      Set configuration file.\n"
            "  -v,  --verbose                 Increase verbosity.\n"
            "  -q,  --quiet                   Be quiet during processing.\n"
            "  -V,  --version                 Print version and copyright.\n"
            "  -h,  --help                    Print this help screen.\n"
            "\n");
}

/**
 * Print version of Sally tool
 */
static void print_version(void)
{
    printf("Sally %s - A Tool for Embedding Strings in Vector Spaces\n"
           "Copyright (c) 2010-2011 Konrad Rieck (konrad@mlsec.org)\n",
            PACKAGE_VERSION);
}

/**
 * Parse command line options
 * @param argc Number of arguments
 * @param argv Argument values
 */
static void sally_parse_options(int argc, char **argv)
{
    int ch;
    
    optind = 0;
    
    while ((ch = getopt_long(argc, argv, OPTSTRING, longopts, NULL)) != -1) {
        switch (ch) {
        case 'c':
            /* Skip. See sally_load_config(). */
            break;
        case 'i':
            config_set_string(&cfg, "input.input_format", optarg);
            break;
        case 'o':
            config_set_string(&cfg, "output.output_format", optarg);
            break;
        case 1000:
            config_set_int(&cfg, "input.chunk_size", atoi(optarg));
            break;    
        case 1001:
            config_set_string(&cfg, "input.fasta_regex", optarg);        
            break;    
        case 1002:
            config_set_string(&cfg, "input.lines_regex", optarg);
            break;    
        case 'n':
            config_set_int(&cfg, "features.ngram_len", atoi(optarg));
            break;
        case 'd':
            config_set_string(&cfg, "features.ngram_delim", optarg);
            break;
        case 'E':
            config_set_string(&cfg, "features.vect_embed", optarg);
            break;
        case 'N':
            config_set_string(&cfg, "features.vect_norm", optarg);
            break;
        case 'b':
            config_set_int(&cfg, "features.hash_bits", atoi(optarg));        
            break;
        case 1003:
            config_set_int(&cfg, "features.explicit_hash", atoi(optarg));
            break;    
        case 1004:
            config_set_string(&cfg, "features.tfidf_file", optarg);
            break;    
        case 'q':
            verbose = 0;
            break;
        case 'v':
            verbose++;
            break;
        case 'V':
            print_version();
            exit(EXIT_SUCCESS);
            break;
        case 'h':
        case '?':
            print_usage();
            exit(EXIT_SUCCESS);
            break;
        }
    }

    /* Check configuration */
    config_check(&cfg);

    argc -= optind;
    argv += optind;

    /* Check remaining arguments */
    if (argc != 2) {
        print_usage();
        exit(EXIT_FAILURE);
    }

    input = argv[0];
    output = argv[1];
}


/**
 * Load the configuration of Sally
 * @param argc number of arguments
 * @param argv arguments
 */
static void sally_load_config(int argc, char **argv)
{
    char *cfg_file = NULL;
    char cfg_path[MAX_PATH_LEN];
    int ch;

    /* Check for config file in command line */
    while ((ch = getopt_long(argc, argv, OPTSTRING, longopts, NULL)) != -1) {
        switch (ch) {
   	    case 'c':
   	        cfg_file = optarg;
   	        break;
            case '?':
            default:
                /* empty */
                break;
        }
    }

    /* Check for local config file ".sally" */   
    snprintf(cfg_path, MAX_PATH_LEN, "%s/.sally", getenv("HOME"));
    if (!cfg_file && !access(cfg_path, F_OK))
        cfg_file = cfg_path;

    /* Check for global config file "sally.cfg" */
    snprintf(cfg_path, MAX_PATH_LEN, "%s/sally.cfg", CONFIG_DIR);
    if (!cfg_file && !access(cfg_path, F_OK))
        cfg_file = cfg_path;

    if (!cfg_file)
        fatal("No config file availablle.");

    /* Init and load configuration */
    config_init(&cfg);
    if (config_read_file(&cfg, cfg_file) != CONFIG_TRUE)
        fatal("Could not read configuration (%s in line %d)",
            config_error_text(&cfg), config_error_line(&cfg));

    /* Check configuration */
    config_check(&cfg);
}


/**
 * Init the Sally tool
 * @param argc number of arguments
 * @param argv arguments
 */
static void sally_init()
{
    int ehash;
    const char *cfg_str;

    if (verbose > 1)
        config_print(&cfg);

    /* Check for TFIDF weighting */
    config_lookup_string(&cfg, "features.vect_embed", &cfg_str);
    if (!strcasecmp(cfg_str, "tfidf")) 
        idf_create(input);

    /* Check for feature hash table */
    config_lookup_int(&cfg, "features.explicit_hash", &ehash);
    if (ehash) {
        info_msg(1, "Enabling feature hash table.");
        fhash_init();
    }

    /* Open input */
    config_lookup_string(&cfg, "input.input_format", &cfg_str);
    input_config(cfg_str);
    info_msg(1, "Opening '%0.40s' with input module '%s'.", input, cfg_str);
    entries = input_open(input);
    if (entries < 0)
        fatal("Could not open input source");

    /* Open output */
    config_lookup_string(&cfg, "output.output_format", &cfg_str);
    output_config(cfg_str);
    info_msg(1, "Opening '%0.40s' with output module '%s'.", output, cfg_str);
    if (!output_open(output))
        fatal("Coult not open output destination");
}

/**
 * Main processing routine of Sally. This function processes chunks of
 * strings. It might be suitable for OpenMP support in a later version.
 */
static void sally_process()
{
    long read, i, j;
    int chunk;

    /* Get chunk size */
    config_lookup_int(&cfg, "input.chunk_size", &chunk);

    /* Allocate space */
    fvec_t **fvec = alloca(sizeof (fvec_t *) * chunk);
    string_t *strs = alloca(sizeof (string_t) * chunk);

    if (!fvec || !strs)
        fatal("Could not allocate memory for embedding");

    info_msg(1, "Processing %d strings in chunks of %d.", entries, chunk);

    for (i = 0, read = 0; i < entries; i += read) {
        read = input_read(strs, chunk);
        if (read <= 0)
            fatal("Failed to read strings from input '%s'", input);

        for (j = 0; j < read; j++) {
            fvec[j] = fvec_extract(strs[j].str, strs[j].len);
            fvec_set_label(fvec[j], strs[j].label);
            fvec_set_source(fvec[j], strs[j].src);
        }

        if (!output_write(fvec, read))
            fatal("Failed to write vectors to output '%s'", output);

        /* Free memory */
        input_free(strs, read);
        output_free(fvec, read);

        if (fhash_enabled())
            fhash_reset();

        prog_bar(0, entries, i + read);
    }
}

/**
 * Exit Sally tool. Close open files and free memory.
 */
static void sally_exit()
{
    int ehash;
    const char *cfg_str;

    info_msg(1, "Flushing. Closing input and output.");
    input_close();
    output_close();
    
    config_lookup_string(&cfg, "features.vect_embed", &cfg_str);
    if (!strcasecmp(cfg_str, "tfidf")) 
        idf_destroy(input);

    /* Check for feature hash table */
    config_lookup_int(&cfg, "features.explicit_hash", &ehash);
    if (ehash)
        fhash_destroy();

    /* Destroy configuration */
    config_destroy(&cfg);

}

/**
 * Main function of Sally tool 
 * @param argc Number of arguments
 * @param argv Argument values
 * @return exit code
 */
int main(int argc, char **argv)
{
    sally_load_config(argc, argv);
    sally_parse_options(argc, argv);

    sally_init();
    sally_process();
    sally_exit();
}
