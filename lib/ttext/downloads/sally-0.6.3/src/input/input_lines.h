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
 
#ifndef INPUT_LINES_H
#define INPUT_LINES_H

/* Lines module */
int input_lines_open(char *);
int input_lines_read(string_t *, int);
void input_lines_close(void);

#endif                          /* INPUT_LINES_H */
