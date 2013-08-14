/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
#include <sys/types.h>

#define NOSUNWINDOWS

#include "fest.h"


#ifdef SMARTALLOC
struct abufhead {
	struct queue abq;	   /* Links on allocated queue */
	unsigned ablen; 	   /* Buffer length in bytes */
	char *abfname;		   /* File name pointer */
	ushort ablineno;	   /* Line number of allocation */ 
};

static struct queue abqueue = {    /* Allocated buffer queue */
	&abqueue, &abqueue};

static bool bufimode = FALSE;   /* Buffers not tracked when TRUE */
#endif

/*  ALLOC  --  Allocate buffer and signal on error  */

#ifdef SMARTALLOC
char *palloc(char *fname, int lineno,unsigned  nbytes)
//char *fname;
//int lineno;
#else
char *alloc(unsigned nbytes)
#endif
//unsigned nbytes;
{
	char *buf;
#undef malloc
extern char *malloc(unsigned);

	assert(nbytes > 0);

#ifdef SMARTALLOC
	nbytes += sizeof(struct abufhead) + 1;
#endif
	if ((buf = malloc(nbytes)) != NULL) {
#define malloc(x) (^%&^%&^%%!!!@@%^&%)
#ifdef SMARTALLOC
	   /* Enqueue buffer on allocated list */
	   qinsert(&abqueue, (struct queue *) buf);
	   ((struct abufhead *) buf)->ablen = nbytes;
	   ((struct abufhead *) buf)->abfname = bufimode ? NULL : fname;
	   ((struct abufhead *) buf)->ablineno = lineno;
	   /* Emplace end-clobber detector at end of buffer */
	   buf[nbytes - 1] = (((long) buf) & 0xFF) ^ 0xC5;
	   buf += sizeof(struct abufhead);  /* Increment to user data start */
#endif
	   return buf;
	}
	fprintf(stderr,
           "\nBoom!!!  Memory capacity exceeded (%d requested)\n",
	   nbytes);
	abort();
	return(buf); /* for lint */
}

/*  MEMFREE  --  Update free pool availability.  FREE is never called
		 except through this interface.  free(x) is defined
		 to generate a call to this routine.  */

void memfree(char *cp)
//char *cp;
{
#ifdef SMARTALLOC
	struct queue *qp;

	assert(cp != NULL);	   /* Better not release a null buffer, guy! */
	cp -= sizeof(struct abufhead);
	qp = (struct queue *) cp;

	/* The following assertions will catch virtually every release
           of an address which isn't an allocated buffer. */
	assert(qp->qnext->qprev == qp);   /* Validate queue links */
	assert(qp->qprev->qnext == qp);

	/* The following assertion detects storing off the end
	   of the allocated space in the buffer by comparing the
	   end of buffer checksum with the address of the buffer. */

	assert(((unsigned char *) cp)[((struct abufhead *) cp)->ablen - 1] ==
	   ((((long) cp) & 0xFF) ^ 0xC5));

	qdchain(qp);
#endif
#undef free
	free(cp);
#define free(x)  memfree((x))
}

/*  ACTUALLYFREE  --  Interface to system free() function to release
		      buffers allocated by low-level routines. */

void actuallyfree(char *cp)
//char *cp;
{
#undef free
	free(cp);
#define free(x)  memfree((x))
}

#ifdef SMARTALLOC

/*  MEMDUMP  --  Print orphaned buffers (and dump them if BUFDUMP is
		 TRUE). */

/*static */ void memdump(bool bufdump)
//Boolean bufdump;
{
	struct abufhead *ap;
	char *cp;
	unsigned memsize, llen;
	char errmsg[80];

	while (ap = (struct abufhead *) qremove(&abqueue)) {
	   cp = (char *) ap;
	   memsize = ap->ablen;
	   if (ap->abfname != NULL) {
	      memsize -= sizeof(struct abufhead) + 1; /* Actual user size */
	      sprintf(errmsg,
                "Orphaned buffer:  %6d bytes allocated at line %d of %s\n",
		 memsize, ap->ablineno, ap->abfname
	      );
              fprintf(stderr, "%s", errmsg);
	      if (bufdump) {
		 cp += sizeof(struct abufhead);
		 llen = 0;
		 errmsg[0] = EOS;
		 while (memsize) {
		    if (llen >= 16) {
                       strcat(errmsg, "\n");
		       llen = 0;
                       fprintf(stderr, "%s", errmsg);
		       errmsg[0] = EOS;
		    }
                    sprintf(errmsg + strlen(errmsg), " %02X", *cp++);
		    llen++;
		    memsize--;
		 }
                 fprintf(stderr, "%s", errmsg);
	      }
	   }
	}
}
#endif
