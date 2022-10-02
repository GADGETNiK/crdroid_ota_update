#!/bin/bash

#leave blank if not used
maintainer="Krell RHEL (WolfAURman)" #ex: Lup Gabriel (gwolfu)
##
oem="Xiaomi" #ex: OnePlus
device="lava" #ex: guacamole
devicename="Redmi 9" #ex: OnePlus 7 Pro
##
zip=$(basename out/target/product/$device/crDroidAndroid-11.0-*-$device-*.zip)
nozip=$(basename out/target/product/$device/crDroidAndroid-11.0-*-$device-*.zip .zip)
time=$(cat out/build_date.txt)
date=$(echo $zip | cut -f3 -d '-')
here=$(pwd)
##
buildtype="Monthly" #choose from Testing/Alpha/Beta/Weekly/Monthly
forum="https://t.me/WolfAURman_Discussion" #https link (mandatory)
gapps="https://sourceforge.net/projects/nikgapps/files/Releases/NikGapps-R/08-Sep-2022/NikGapps-core-arm64-11-20220908-signed.zip/download" #https link (leave empty if unused)
firmware="" #https link (leave empty if unused)
modem="" #https link (leave empty if unused)
bootloader="" #https link (leave empty if unused)
recovery="" #https link (leave empty if unused)
paypal="" #https link (leave empty if unused)
telegram="https://t.me/red_hat_interprise13" #https link (leave empty if unused)

#don't modify from here
script_path="`dirname \"$0\"`"
zip_name=$script_path/out/target/product/$device/$zip
buildprop=$script_path/out/target/product/$device/system/build.prop

if [ -f $script_path/$device.json ]; then
  rm $script_path/$device.json
fi

linenr=`grep -n "ro.system.build.date.utc" $buildprop | cut -d':' -f1`
timestamp=`sed -n $linenr'p' < $buildprop | cut -d'=' -f2`
zip_only=`basename "$zip_name"`
md5=`md5sum "$zip_name" | cut -d' ' -f1`
size=`stat -c "%s" "$zip_name"`
version=`echo "$zip_only" | cut -d'-' -f5`
v_max=`echo "$version" | cut -d'.' -f1 | cut -d'v' -f2`
v_min=`echo "$version" | cut -d'.' -f2`
version=`echo $v_max.$v_min`

echo '{
  "response": [
    {
        "maintainer": "'$maintainer'",
        "oem": "'$oem'",
        "device": "'$devicename'",
        "filename": "'$zip_only'",
        "download": "https://github.com/WolfAURman/crdroid_ota_update/releases/download/'$nozip'/'$zip'",
        "timestamp": '$timestamp',
        "md5": "'$md5'",
        "size": '$size',
        "version": "'$version'",
        "buildtype": "'$buildtype'",
        "forum": "'$forum'",
        "gapps": "'$gapps'",
        "firmware": "'$firmware'",
        "modem": "'$modem'",
        "bootloader": "'$bootloader'",
        "recovery": "'$recovery'",
        "paypal": "'$paypal'",
        "telegram": "'$telegram'"
    }
  ]
}' >> $device.json

##

rm -rf ~/crdroid_ota_update/7.x/$device.json && cp $device.json ~/crdroid_ota_update/7.x

cd ~/crdroid_ota_update

git add -A && git commit -m "The configuration has been updated due to version $version for $device" && git push

gh release create $nozip --notes "Automated release CrDroid for $device $version $date/$time" $here/out/target/product/$device/$zip

cd $here