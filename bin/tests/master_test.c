#include <config.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <isc/mem.h>
#include <isc/buffer.h>
#include <isc/error.h>

#include <dns/master.h>
#include <dns/name.h>
#include <dns/rdataset.h>
#include <dns/result.h>
#include <dns/types.h>

dns_result_t print_dataset(dns_rdatacallbacks_t *callbacks,
			   dns_name_t *owner, dns_rdataset_t *dataset);

isc_mem_t *mctx;

dns_result_t
print_dataset(dns_rdatacallbacks_t *callbacks, dns_name_t *owner,
	      dns_rdataset_t *dataset) {
	char buf[64*1024];
	isc_buffer_t target;
	dns_result_t result;
	
	callbacks = callbacks;	/*unused*/

	isc_buffer_init(&target, buf, 64*1024, ISC_BUFFERTYPE_TEXT);
	result = dns_rdataset_totext(dataset, owner, ISC_FALSE, &target);
	if (result == DNS_R_SUCCESS)
		fprintf(stdout, "%.*s\n", (int)target.used,
					  (char*)target.base);
	else 
		fprintf(stdout, "dns_rdataset_totext: %s\n",
			dns_result_totext(result));

	return (DNS_R_SUCCESS);
}

int
main(int argc, char *argv[]) {
	dns_result_t result;
	dns_name_t origin;
	isc_buffer_t source;
	isc_buffer_t target;
	unsigned char name_buf[255];
	int soacount = 0;
	int nscount = 0;
	dns_rdatacallbacks_t callbacks;

	argc = argc;

	RUNTIME_CHECK(isc_mem_create(0, 0, &mctx) == ISC_R_SUCCESS);

	if (argv[1]) {
		isc_buffer_init(&source, argv[1], strlen(argv[1]),
				ISC_BUFFERTYPE_TEXT);
		isc_buffer_add(&source, strlen(argv[1]));
		isc_buffer_setactive(&source, strlen(argv[1]));
		isc_buffer_init(&target, name_buf, 255, ISC_BUFFERTYPE_BINARY);
		dns_name_init(&origin, NULL);
		result = dns_name_fromtext(&origin, &source, dns_rootname,
					   ISC_FALSE, &target);
		if (result != DNS_R_SUCCESS) {
			fprintf(stdout, "dns_name_fromtext: %s\n",
				dns_result_totext(result));
			exit(1);
		}
				
		memset(&callbacks, 0, sizeof callbacks);
		callbacks.commit = print_dataset;
		
		result = dns_master_load(argv[1], &origin, &origin, 1,
					 &soacount, &nscount,
					 &callbacks, mctx);
		fprintf(stdout, "dns_master_load: %s\n",
			dns_result_totext(result));
		if (result == DNS_R_SUCCESS)
			fprintf(stdout, "soacount = %d, nscount = %d\n",
				soacount, nscount);
	}
	exit(0);
}
