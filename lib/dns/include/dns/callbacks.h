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

#ifndef DNS_CALLBACKS_H
#define DNS_CALLBACKS_H 1
#include <dns/types.h>
#include <dns/result.h>
 
typedef struct dns_rdatacallbacks {
	/* dns_load_master calls this when it has rdatasets to commit */
	dns_result_t	(*commit)(struct dns_rdatacallbacks *,
				  dns_name_t *, dns_rdataset_t *);
	/* dns_load_master / dns_rdata_fromtext call this to issue a error */
	void		(*error)(struct dns_rdatacallbacks *, char *, ...);
	/* dns_load_master / dns_rdata_fromtext call this to issue a warning */
	void		(*warn)(struct dns_rdatacallbacks *, char *, ...);
	/* private data handles for use by the above callback functions */
	void		*commit_private;
	void		*error_private;
	void		*warn_private;
} dns_rdatacallbacks_t;

#endif /* DNS_CALLBACKS_H */
