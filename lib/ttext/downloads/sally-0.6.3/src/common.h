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

#ifndef COMMON_H
#define COMMON_H

#define _BSD_SOURCE             /* Linux: strdup() */
#define __USE_POSIX             /* Linux: readdir_r() */

#ifdef __STRICT_ANSI__          
#undef __STRICT_ANSI__          /* Required on Cygwin */
#endif

#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>

/* Standard C headers */
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stddef.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>
#include <math.h>
#include <float.h>
#include <assert.h>
#include <dirent.h>

#ifdef HAVE_GETOPT_H
#include <getopt.h>
#endif
#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif
#ifdef HAVE_STRING_H
#include <string.h>
#endif
#ifdef HAVE_ZLIB_H
#include <zlib.h>
#endif
#ifdef HAVE_LIBCONFIG_H
#include <libconfig.h>
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif


#endif                          /* COMMON_H */
