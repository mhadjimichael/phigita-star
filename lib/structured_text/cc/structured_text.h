#ifndef STRUCTURED_TEXT_H
#define STRUCTURED_TEXT_H



#include "tcl.h"


int MinitextToHtml(Tcl_DString *dsPtr, int *outflags, char *text);
int StxToHtml(Tcl_DString *dsPtr, int *outflags, char *text);

#endif
