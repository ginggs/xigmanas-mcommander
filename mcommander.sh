#!/bin/sh
# filename:     mcommander.sh
# author:       Dan Merschi
# date:         2009-07-28 ; Add multiplatform support
# author:       Graham Inggs
# date:         2012-04-11 ; Updated for NAS4Free 9.0.0.1
# date:         2013-02-09 ; Updated for ftp.freebsd.org restructuring and latest mc-light version
# date:         2013-05-05 ; Switch from mc-light to mc ; drop compat7x ; add libslang
# date:         2013-08-10 ; Update mc package name to mc-4.8.8.tbz
# date:         2013-08-23 ; Fetch files from packages-9.2-release ; add libssh2
# date:         2018-05-23 ; Updated for NAS4Free 11.1.0.4
# date:         2018-12-29 ; Updated for XigmaNAS 11.2.0.4
# date:         2019-10-29 ; Updated for XigmaNAS 12.0.0.4
# date:         2019-11-25 ; Updated for XigmaNAS 12.1.0.4
# date:         2021-04-03 ; Updated for XigmaNAS 12.2.0.4
# purpose:      Install Midnight Commander on XigmaNAS (embedded version).
# Note:         Check the end of the page.
#
#----------------------- Set variables ------------------------------------------------------------------
DIR=`dirname $0`;
#----------------------- Set Errors ---------------------------------------------------------------------
_msg() { case $@ in
  0) echo "The script will exit now."; exit 0 ;;
  1) echo "No route to server, or file do not exist on server"; _msg 0 ;;
  2) echo "Can't find ${PKG}-*.pkg on ${DIR}/All"; _msg 0 ;;
  3) echo "Midnight Commander installed and ready! (ONLY USE DURING A SSH SESSION)"; exit 0 ;;
  4) echo "Always run this script using the full path: /mnt/.../directory/mcommander.sh"; _msg 0 ;;
esac ; exit 0; }
#----------------------- Check for full path ------------------------------------------------------------
if [ ! `echo $0 |cut -c1-5` = "/mnt/" ]; then _msg 4 ; fi
cd $DIR;
#----------------------- Download and decompress mc files if needed -------------------------------------
PKG="mc"
if [ ! -d ${DIR}/usr/local/bin ]; then
  if [ ! -e ${DIR}/All/${PKG}-*.pkg ]; then pkg fetch -o ${DIR} -y ${PKG} || _msg 1; fi
  if [ -f ${DIR}/All/${PKG}-*.pkg ]; then tar xzf ${DIR}/All/${PKG}-*.pkg || _msg 2;
    rm ${DIR}/+*; rm -R ${DIR}/usr/local/man; fi
  if [ ! -d ${DIR}/usr/local/bin ]; then _msg 4; fi
fi
#----------------------- Download and decompress libslang files if needed -------------------------------
PKG="libslang2"
if [ ! -f ${DIR}/usr/local/lib/libslang.so ]; then
  if [ ! -e ${DIR}/All/${PKG}-*.pkg ]; then pkg fetch -o ${DIR} -y ${PKG} || _msg 1; fi
  if [ -f ${DIR}/All/${PKG}-*.pkg ]; then tar xzf ${DIR}/All/${PKG}-*.pkg || _msg 2};
    rm ${DIR}/+*; rm -R ${DIR}/usr/local/libdata; rm -R ${DIR}/usr/local/man;
    rm -R ${DIR}/usr/local/include; rm ${DIR}/usr/local/lib/*.a; rm ${DIR}/usr/local/bin/slsh;
    rm ${DIR}/usr/local/etc/slsh.rc; fi
  if [ ! -f ${DIR}/usr/local/lib/libslang.so ]; then _msg 4; fi
fi
#----------------------- Download and decompress libssh2 files if needed --------------------------------
PKG="libssh2"
if [ ! -f ${DIR}/usr/local/lib/libssh2.so ]; then
  if [ ! -e ${DIR}/All${PKG}-*.pkg ]; then pkg fetch -o ${DIR} -y ${PKG} || _msg 1; fi
  if [ -f ${DIR}/All/${PKG}-*.pkg ]; then tar xzf ${DIR}/All/${PKG}-*.pkg || _msg 2};
    rm ${DIR}/+*; rm -R ${DIR}/usr/local/libdata; rm -R ${DIR}/usr/local/man;
    rm -R ${DIR}/usr/local/include; rm ${DIR}/usr/local/lib/*.a; fi
  if [ ! -f ${DIR}/usr/local/lib/libssh2.so ]; then _msg 4; fi
fi
#----------------------- Create symlinks ----------------------------------------------------------------
if [ ! -e /usr/local/share/mc ]; then ln -s ${DIR}/usr/local/share/mc /usr/local/share; fi
if [ ! -e /usr/local/libexec/mc ]; then ln -s ${DIR}/usr/local/libexec/mc /usr/local/libexec; fi
if [ ! -e /usr/local/etc/mc ]; then ln -s ${DIR}/usr/local/etc/mc /usr/local/etc; fi
for i in `ls $DIR/usr/local/bin/`
  do if [ ! -e /usr/local/bin/${i} ]; then ln -s ${DIR}/usr/local/bin/$i /usr/local/bin; fi; done
for i in `ls $DIR/usr/local/share/locale`
  do if [ ! -e /usr/local/share/locale/${i} ]; then
      ln -s ${DIR}/usr/local/share/locale/${i} /usr/local/share/locale;
    else if [ ! -e /usr/local/share/locale/${i}/LC_MESSAGES/mc.mo ]; then
      ln -s ${DIR}/usr/local/share/locale/${i}/LC_MESSAGES/mc.mo \
        /usr/local/share/locale/${i}/LC_MESSAGES; fi;
    fi; done
for i in `ls $DIR/usr/local/lib`
  do if [ ! -e /usr/local/lib/${i} ]; then ln -s ${DIR}/usr/local/lib/$i /usr/local/lib; fi; done
_msg 3 ; exit 0;
#----------------------- End of Script ------------------------------------------------------------------
# 1. Keep this script in its own directory.
# 2. chmod the script u+x,
# 3. Always run this script using the full path: /mnt/.../directory/mcommander.sh
# 4. You can add this script to WebGUI: Advanced: Command Scripts as a PostInit command (see 3).
# 5. To run Midnight Commander from shell type 'mc'.
