#!/bin/sh

pkg_name="application name"

pkg_url="http://localhost:8080"

product_name="product name"

app_dir="${HOME}/.${pkg_name}"

yaml_name="latest-linux.yml"
yaml="${app_dir}/${yaml_name}"
image_name="${pkg_name}.AppImage"
image="${app_dir}/${image_name}"
icon_name="${pkg_name}.png"
icon="${app_dir}/${icon_name}"

log="${app_dir}/install.log"

if [ ! -e $app_dir ]; then
   sudo mkdir $app_dir
   sudo chmod 777 $app_dir
fi

cd $app_dir

echo "Download config file..." >> $log
if [ -e $yaml ]; then
   sudo rm -f $yaml
fi
wget $pkg_url/$yaml_name
if [ -e $yaml ]; then
   sudo chmod 744 $yaml
   echo "Download config file successful." >> $log
else
   echo "Download config file failed." >> $log
   echo "Install failed." >> $log
   exit 1
fi

server_image=`grep 'path:' $yaml | tail -n1 | awk '{print $2}' | tr -d '\r'`

echo "Download image file..." >> $log
if [ -e $image ]; then
   sudo rm -f $image
fi
wget $pkg_url/$server_image -O $image_name
if [ -e $image ]; then
   sudo chmod a+x $image
   echo "Download image file successful." >> $log
else
   echo "Download image file failed." >> $log
   echo "Install failed." >> $log
   exit 1
fi

echo "Download icon file..." >> $log
if [ -e $icon ]; then
   sudo rm -f $icon
fi
wget $pkg_url/$icon_name
if [ -e $icon ]; then
   sudo chmod 744 $icon
   echo "Download icon file successful." >> $log
else
   echo "Download icon file failed." >> $log
   echo "Install failed." >> $log
   exit 1
fi

echo "Install libs." >> $log
sudo apt -y update
sudo apt -y install gconf2 gconf-service libnotify4 libappindicator1 libxtst6 libnss3
echo "Install libs successful." >> $log

desktop="${HOME}/.local/share/applications/vmi.desktop"

if [ -e $desktop ]; then
   sudo rm -f $desktop
fi

(
cat <<EOF
[Desktop Entry]
Name=$product_name
Exec=$image
Terminal=false
Type=Application
Icon=$icon
StartupWMClass=$product_name
Comment=$product_name
Categories=Utility;
TryExec=$image
Actions=Remove;
[Desktop Action Remove]
Name=Uninstall
Name[zh_CN]=卸载
Icon=$icon
Exec=gnome-terminal -e $app_dir/uninstall.sh %f
EOF
) >> $desktop

if [ -e $desktop ]; then
   sudo chmod 744 $desktop
   echo "Create desktop link." >> $log
else
   echo "Create desktop link failed." >> $log
   echo "Install failed." >> $log
   exit 1
fi

uninstall="${app_dir}/uninstall.sh"

if [ -e $uninstall ]; then
   sudo rm -f $uninstall
fi

(
cat <<EOF
#!/bin/sh

sudo rm -f $image
if [ -e $image ]; then
   echo "Uninstall failed." >> $app_dir/uninstall.log
   exit 1
else
   echo "Remove image file." >> $app_dir/uninstall.log
fi
sudo rm -f $desktop
echo "Remove desktop link." >> $app_dir/uninstall.log
echo "Done." >> $app_dir/uninstall.log
EOF
) >> $uninstall

if [ -e $uninstall ]; then
   sudo chmod 744 $uninstall
   echo "Create uninstall script." >> $log
else
   echo "Create uninstall script failed." >> $log
fi

echo "Done." >> $log

./$image_name &
