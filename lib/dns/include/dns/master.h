/*
 * Copyright (C) 1999  Internet Software Consortium.
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

#ifndef DNS_MASTER_H
#define DNS_MASTER_H 1

#include <isc/mem.h>
#include <isc/lex.h>

#include <dns/types.h>
#include <dns/result.h>
#include <dns/name.h>
#include <dns/rdataset.h>
#include <dns/callbacks.h>

dns_result_t dns_master_load(char *master_file,
			     dns_name_t *top,
			     dns_name_t *origin,
			     dns_rdataclass_t class,
			     int *soacount,
			     int *nscount,
			     dns_rdatacallbacks_t *callbacks,
			     isc_mem_t *mctx);

/*
 * Requires:
 *	callbacks->commit to point ta a valid function.
 *	masterfile point to a valid string.
 */

#endif	/* DNS_MASTER_H */
