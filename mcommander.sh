#!/bin/sh
# filename:     mcommander.sh
# author:       Dan Merschi
# date:         2009-07-28 ; Add multiplatform support
# author:       Graham Inggs <graham@nerve.org.za>
# date:         2012-04-11 ; Updated for NAS4Free 9.0.0.1
# date:         2013-02-09 ; Updated for ftp.freebsd.org restructuring and latest mc-light version
# date:         2013-05-05 ; Switch from mc-light to mc ; drop compat7x ; add libslang
# date:         2013-08-10 ; Update mc package name to mc-4.8.8.tbz
# date:         2013-08-23 ; Fetch files from packages-9.2-release ; add libssh2
# purpose:      Install Midnight Commander on NAS4Free (embedded version).
# Note:         Check the end of the page.
#
#----------------------- Set variables ------------------------------------------------------------------
DIR=`dirname $0`;
PLATFORM=`uname -m`
RELEASE=`uname -r | cut -d- -f1`
URL="ftp://ftp.freebsd.org/pub/FreeBSD/ports/${PLATFORM}/packages-9.2-release/All"
MCFILE="mc-4.8.8.tbz"
LIBSLANGFILE="libslang2-2.2.4_4.tbz"
LIBSSH2FILE="libssh2-1.4.3_1,2.tbz"
#----------------------- Set Errors ---------------------------------------------------------------------
_msg() { case $@ in
  0) echo "The script will exit now."; exit 0 ;;
  1) echo "No route to server, or file do not exist on server"; _msg 0 ;;
  2) echo "Can't find ${FILE} on ${DIR}"; _msg 0 ;;
  3) echo "Midnight Commander installed and ready! (ONLY USE DURING A SSH SESSION)"; exit 0 ;;
  4) echo "Always run this script using the full path: /mnt/.../directory/mcommander.sh"; _msg 0 ;;
esac ; exit 0; }
#----------------------- Check for full path ------------------------------------------------------------
if [ ! `echo $0 |cut -c1-5` = "/mnt/" ]; then _msg 4 ; fi
cd $DIR;
#----------------------- Download and decompress mc files if don't exist --------------------------------
FILE=${MCFILE}
if [ ! -d ${DIR}/bin ]; then
  if [ ! -e ${DIR}/${FILE} ]; then fetch ${URL}/${FILE} || _msg 1; fi
  if [ -f ${DIR}/${FILE} ]; then tar xzf ${DIR}/${FILE} || _msg 2; rm ${DIR}/+*; rm -R ${DIR}/man; fi
  if [ ! -d ${DIR}/bin ]; then _msg 4; fi
fi
#----------------------- Download and decompress libslang files if don't exist --------------------------
FILE=${LIBSLANGFILE}
if [ ! -d ${DIR}/lib ]; then
  if [ ! -e ${DIR}/${FILE} ]; then fetch ${URL}/${FILE} || _msg 1; fi
  if [ -f ${DIR}/${FILE} ]; then tar xzf ${DIR}/${FILE} || _msg 2};
    rm ${DIR}/+*; rm -R ${DIR}/libdata; rm -R ${DIR}/man; rm -R ${DIR}/include; rm ${DIR}/lib/*.a;
    rm ${DIR}/bin/slsh; rm ${DIR}/etc/slsh.rc; fi
  if [ ! -d ${DIR}/lib ]; then _msg 4; fi
fi
#----------------------- Download and decompress libssh2 files if don't exist ---------------------------
FILE=${LIBSSH2FILE}
if [ ! -f ${DIR}/lib/libssh2.so ]; then
  if [ ! -e ${DIR}/${FILE} ]; then fetch ${URL}/${FILE} || _msg 1; fi
  if [ -f ${DIR}/${FILE} ]; then tar xzf ${DIR}/${FILE} || _msg 2};
    rm ${DIR}/+*; rm -R ${DIR}/libdata; rm -R ${DIR}/man; rm -R ${DIR}/include; rm ${DIR}/lib/*.a;
    rm ${DIR}/lib/*.la; fi
  if [ ! -d ${DIR}/lib ]; then _msg 4; fi
fi
#----------------------- Create symlinks ----------------------------------------------------------------
if [ ! -e /usr/local/share/mc ]; then ln -s ${DIR}/share/mc /usr/local/share; fi
if [ ! -e /usr/local/libexec/mc ]; then ln -s ${DIR}/libexec/mc /usr/local/libexec; fi
if [ ! -e /usr/local/etc/mc ]; then ln -s ${DIR}/etc/mc /usr/local/etc; fi
for i in `ls $DIR/bin/`
  do if [ ! -e /usr/local/bin/${i} ]; then ln -s ${DIR}/bin/$i /usr/local/bin; fi; done
for i in `ls $DIR/share/locale`
  do if [ ! -e /usr/local/share/locale/${i} ]; then
      ln -s ${DIR}/share/locale/${i} /usr/local/share/locale;
    else if [ ! -e /usr/local/share/locale/${i}/LC_MESSAGES/mc.mo ]; then
      ln -s ${DIR}/share/locale/${i}/LC_MESSAGES/mc.mo /usr/local/share/locale/${i}/LC_MESSAGES; fi;
    fi; done
for i in `ls $DIR/lib`
  do if [ ! -e /usr/local/lib/${i} ]; then ln -s $DIR/lib/$i /usr/local/lib; fi; done
_msg 3 ; exit 0;
#----------------------- End of Script ------------------------------------------------------------------
# 1. Keep this script in his own directory.
# 2. chmod the script u+x,
# 3. Always run this script using the full path: /mnt/share/directory/mcommander
# 4. You can add this script to WebGUI: Advanced: Commands as Post command (see 3).
# 5. To run Midnight Commander from shell type 'mc'.
