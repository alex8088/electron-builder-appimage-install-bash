# Install bash for AppImage built by electron builder

A bash script to create integrated desktop for AppImage built by electron builder. Since electron builder 21 desktop integration is not part of producted AppImage file.

## Edit the install bash for your AppImage

```shell
pkg_name="application name" #application name

pkg_url="http://localhost:8080" #AppImage update server

product_name="product name" #the desktop display name
```

## What did the install bash do

- create install directory
- download the `latest-linux.yml` file
- download the AppImage file
- download the desktop icon(`You need to push the desktop icon to the update server`)
- create desktop link
- create uninstall script
- start your application
