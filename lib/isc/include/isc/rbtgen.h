/*
 * Copyright (C) 1998  Internet Software Consortium.
 * 
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS" AND INTERNET SOFTWARE CONSORTIUM DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL INTERNET SOFTWARE
 * CONSORTIUM BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
 * ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
 * SOFTWARE.
 */

/*
 * Note that we do not do the usual #ifdef ... #endif protection since this
 * file is used as a template.
 */

#include <isc/result.h>

typedef struct RBT_NODE *RBT_NODE_T;

RBT_LINKAGE isc_result_t RBT_INSERT(RBT_NODE_T, RBT_NODE_T *);
RBT_LINKAGE RBT_NODE_T RBT_SEARCH(RBT_NODE_T, RBT_KEY_T);
RBT_LINKAGE void RBT_PRINT(RBT_NODE_T);
