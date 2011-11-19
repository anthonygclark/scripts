#!/bin/bash
# Anthony Clark
#
# Vbox used to have incorrect symlinks, this
# fixes it. Not sure if this is still needed.

cd /opt/VirtualBox
	for lib in "libQtCore" "libQtGui" "libQtNetwork" "libQtOpenGL"; do
		rm "${lib}VBox.so.4"
		ln -s "/usr/lib/$lib.so.4" "${lib}VBox.so.4"
		echo -e '\E[33m'"\033[1m> Creating symlink \033[0m"
	done
cd ~
echo -e '\E[33m'"\033[1m> COMPLETED \033[0m"
