/* Source/config.h.  Generated from config.h.in by configure.  */
/* Source/config.h.in.  Generated from configure.ac by autoheader.  */

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* Define to the architecture's data model. */
#define DATA_MODEL DATA_MODEL_LP64

/* Defined to ILP32 data model. */
#define DATA_MODEL_ILP32 124484

/* Defined to IP16 data model. */
#define DATA_MODEL_IP16 122482

/* Defined to LLP64 data model. */
#define DATA_MODEL_LLP64 124488

/* Defined to LP32 data model. */
#define DATA_MODEL_LP32 122484

/* Defined to LP64 data model. */
#define DATA_MODEL_LP64 124888

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if you have the <float.h> header file. */
#define HAVE_FLOAT_H 1

/* Define to 1 if you have International Components for Unicode. */
#define HAVE_ICU 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the `dispatch' library (-ldispatch). */
/* #undef HAVE_LIBDISPATCH */

/* Define to 1 if you have the `objc' library (-lobjc). */
#define HAVE_LIBOBJC 1

/* Define to 1 if you have the `objc2' library (-lobjc2). */
/* #undef HAVE_LIBOBJC2 */

/* Define to 1 if you have the <limits.h> header file. */
#define HAVE_LIMITS_H 1

/* Define to 1 if you have the <math.h> header file. */
#define HAVE_MATH_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the <stddef.h> header file. */
#define HAVE_STDDEF_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
#define HAVE_SYS_TIME_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unicode/ucal.h> header file. */
#define HAVE_UNICODE_UCAL_H 1

/* Define to 1 if you have the <unicode/uchar.h> header file. */
#define HAVE_UNICODE_UCHAR_H 1

/* Define to 1 if you have the <unicode/ucnv.h> header file. */
#define HAVE_UNICODE_UCNV_H 1

/* Define to 1 if you have the <unicode/ucol.h> header file. */
#define HAVE_UNICODE_UCOL_H 1

/* Define to 1 if you have the <unicode/ucurr.h> header file. */
#define HAVE_UNICODE_UCURR_H 1

/* Define to 1 if you have the <unicode/udatpg.h> header file. */
#define HAVE_UNICODE_UDATPG_H 1

/* Define to 1 if you have the <unicode/udat.h> header file. */
#define HAVE_UNICODE_UDAT_H 1

/* Define to 1 if you have the <unicode/ulocdata.h> header file. */
#define HAVE_UNICODE_ULOCDATA_H 1

/* Define to 1 if you have the <unicode/uloc.h> header file. */
#define HAVE_UNICODE_ULOC_H 1

/* Define to 1 if you have the <unicode/unorm.h> header file. */
#define HAVE_UNICODE_UNORM_H 1

/* Define to 1 if you have the <unicode/unum.h> header file. */
#define HAVE_UNICODE_UNUM_H 1

/* Define to 1 if you have the <unicode/usearch.h> header file. */
#define HAVE_UNICODE_USEARCH_H 1

/* Define to 1 if you have the <unicode/ustring.h> header file. */
#define HAVE_UNICODE_USTRING_H 1

/* Define to 1 if you have the <unicode/utrans.h> header file. */
#define HAVE_UNICODE_UTRANS_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "bug-gnustep@gnu.org"

/* Define to the full name of this package. */
#define PACKAGE_NAME "libgnustep-corebase"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "libgnustep-corebase 0.2"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "libgnustep-corebase"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "0.2"

/* The size of `char', as computed by sizeof. */
#define SIZEOF_CHAR 1

/* The size of `double', as computed by sizeof. */
#define SIZEOF_DOUBLE 8

/* The size of `int', as computed by sizeof. */
#define SIZEOF_INT 4

/* The size of `long', as computed by sizeof. */
#define SIZEOF_LONG 8

/* The size of `long double', as computed by sizeof. */
#define SIZEOF_LONG_DOUBLE 16

/* The size of `long long', as computed by sizeof. */
#define SIZEOF_LONG_LONG 8

/* The size of `short', as computed by sizeof. */
#define SIZEOF_SHORT 2

/* The size of `void *', as computed by sizeof. */
#define SIZEOF_VOID_P 8

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define to the directory contain time zone object files. */
#define TZDIR "/usr/share/zoneinfo"

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif
