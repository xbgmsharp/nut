dnl Check for LIBMODBUS compiler flags. On success, set nut_have_libmodbus="yes"
dnl and set LIBMODBUS_CFLAGS and LIBMODBUS_LIBS. On failure, set
dnl nut_have_libmodbus="no". This macro can be run multiple times, but will
dnl do the checking only once.

AC_DEFUN([NUT_CHECK_LIBMODBUS],
[
if test -z "${nut_have_libmodbus_seen}"; then
	nut_have_libmodbus_seen=yes

	dnl save CFLAGS and LIBS
	CFLAGS_ORIG="${CFLAGS}"
	LIBS_ORIG="${LIBS}"
	NUT_CHECK_PKGCONFIG

	AS_IF([test x"$have_PKG_CONFIG" = xyes],
		[AC_MSG_CHECKING(for libmodbus version via pkg-config)
		 LIBMODBUS_VERSION="`$PKG_CONFIG --silence-errors --modversion libmodbus 2>/dev/null`"
		 if test "$?" != "0" -o -z "${LIBMODBUS_VERSION}"; then
		    LIBMODBUS_VERSION="none"
		 fi
		 AC_MSG_RESULT(${LIBMODBUS_VERSION} found)
		],
		[LIBMODBUS_VERSION="none"
		 AC_MSG_NOTICE([can not check libmodbus settings via pkg-config])
		]
	)

	AS_IF([test x"$LIBMODBUS_VERSION" != xnone],
		[CFLAGS="`$PKG_CONFIG --silence-errors --cflags libmodbus 2>/dev/null`"
		 LIBS="`$PKG_CONFIG --silence-errors --libs libmodbus 2>/dev/null`"
		],
		[CFLAGS="-I/usr/include/modbus"
		 LIBS="-lmodbus"
		]
	)

	AC_MSG_CHECKING(for libmodbus cflags)
	AC_ARG_WITH(modbus-includes,
		AS_HELP_STRING([@<:@--with-modbus-includes=CFLAGS@:>@], [include flags for the libmodbus library]),
	[
		case "${withval}" in
		yes|no)
			AC_MSG_ERROR(invalid option --with(out)-modbus-includes - see docs/configure.txt)
			;;
		*)
			CFLAGS="${withval}"
			;;
		esac
	], [])
	AC_MSG_RESULT([${CFLAGS}])

	AC_MSG_CHECKING(for libmodbus ldflags)
	AC_ARG_WITH(modbus-libs,
		AS_HELP_STRING([@<:@--with-modbus-libs=LIBS@:>@], [linker flags for the libmodbus library]),
	[
		case "${withval}" in
		yes|no)
			AC_MSG_ERROR(invalid option --with(out)-modbus-libs - see docs/configure.txt)
			;;
		*)
			LIBS="${withval}"
			;;
		esac
	], [])
	AC_MSG_RESULT([${LIBS}])

	dnl check if libmodbus is usable
	AC_CHECK_HEADERS(modbus.h, [nut_have_libmodbus=yes], [nut_have_libmodbus=no], [AC_INCLUDES_DEFAULT])
	AC_CHECK_FUNCS(modbus_new_rtu, [], [nut_have_libmodbus=no])
	AC_CHECK_FUNCS(modbus_new_tcp, [], [nut_have_libmodbus=no])

	if test "${nut_have_libmodbus}" = "yes"; then
		LIBMODBUS_CFLAGS="${CFLAGS}"
		LIBMODBUS_LIBS="${LIBS}"
	fi

	dnl restore original CFLAGS and LIBS
	CFLAGS="${CFLAGS_ORIG}"
	LIBS="${LIBS_ORIG}"
fi
])
