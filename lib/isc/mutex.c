/*
 * Copyright (C) Internet Systems Consortium, Inc. ("ISC")
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * See the COPYRIGHT file distributed with this work for additional
 * information regarding copyright ownership.
 */

/*! \file */

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <sys/time.h>
#include <time.h>

#include <isc/mutex.h>
#include <isc/once.h>
#include <isc/print.h>
#include <isc/strerr.h>
#include <isc/string.h>
#include <isc/util.h>

#ifdef HAVE_PTHREAD_MUTEX_ADAPTIVE_NP
static bool attr_initialized = false;
static pthread_mutexattr_t attr;
static isc_once_t once_attr = ISC_ONCE_INIT;

static void
initialize_attr(void) {
	RUNTIME_CHECK(pthread_mutexattr_init(&attr) == 0);
	RUNTIME_CHECK(pthread_mutexattr_settype(
			      &attr, PTHREAD_MUTEX_ADAPTIVE_NP) == 0);
	attr_initialized = true;
}
#endif /* HAVE_PTHREAD_MUTEX_ADAPTIVE_NP */

void
isc__mutex_init(isc_mutex_t *mp, const char *file, unsigned int line) {
	int err;

#ifdef HAVE_PTHREAD_MUTEX_ADAPTIVE_NP
	isc_result_t result = ISC_R_SUCCESS;
	result = isc_once_do(&once_attr, initialize_attr);
	RUNTIME_CHECK(result == ISC_R_SUCCESS);

	err = pthread_mutex_init(mp, &attr);
#else  /* HAVE_PTHREAD_MUTEX_ADAPTIVE_NP */
	err = pthread_mutex_init(mp, NULL);
#endif /* HAVE_PTHREAD_MUTEX_ADAPTIVE_NP */
	if (err != 0) {
		char strbuf[ISC_STRERRORSIZE];
		strerror_r(err, strbuf, sizeof(strbuf));
		isc_error_fatal(file, line, "pthread_mutex_init failed: %s",
				strbuf);
	}
}
