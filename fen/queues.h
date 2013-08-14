/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
#ifndef QUEUES_H
#define QUEUES_H

struct queue {
	struct queue *qnext,	   /* Next item in queue */
		     *qprev;	   /* Previous item in queue */
};

/*  Queue macros  */

#define qempty(x) (qnext((struct queue *)(x),(struct queue *)(x))==NULL)

/*  Queue functions  */
#ifdef CC
extern void qinit(struct queue *qhead);
extern void qinsert(struct queue *qhead,struct queue* object);
extern void qpush(struct queue *qhead,struct queue * object);
extern struct queue *qremove(struct queue *qhead);
extern struct queue *qnext(struct queue *qthis, struct queue *qhead);
extern struct queue *qdchain(struct queue *qitem);
extern int qlength(struct queue *qhead);
extern Boolean qvalid(struct queue *qhead);

#else
void qinit(), qinsert(), qpush();
int qlength(), qvalid();
struct queue *qremove(), *qnext(), *qdchain();
#endif
#endif
