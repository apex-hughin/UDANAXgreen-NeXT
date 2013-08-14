/* Copyright � 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
#ifndef FEST_H
#define FEST_H

#include "fetypealias.h"

#include "feconfig.h"
#include "queues.h"
#include <stdio.h>
#include <ctype.h>
#include "festbot.h"
#include "klugeddcls.h"

extern int debug;

#ifdef MAINDECLARATION
int debug;
#endif

#ifndef max
#define max(a,b)        (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)        (((a) < (b)) ? (a) : (b))
#endif


#endif
