# Crossworlds SDDM Theme
This is a SDDM login theme based on the login screen present on [CrossCode](https://www.cross-code.com/)'s intro.

This theme is completely and absolutely aesthetical. It's not made with practicality in mind and does not have the necessary characteristics to be completely usable. USE AT YOUR OWN RISK.

## Installation
- Download the latest release or clone the repository.
    - Be sure that the theme folder is called crossworlds after downloading it.
- Populate the assets folder, either manually or using the script inside the folder (See #Assets).
- Move the theme folder to `/usr/share/sddm/themes/`
- Select the theme from system settings or change the `[Theme]` section inside `/usr/lib/sddm/sddm.conf.d/sddm.conf` to `Current=crossworlds`.

## Assets
A list of the needed assets is present inside `assets/assets-list`, do not modify it, this list is needed by the populating script.

Using the populating script should be fairly simple. From your terminal, run the script `populate.sh` that's present inside the `assets` folder. This script will ask for a crosscode installation folder to get the needed assets and download the needed fonts.

The original login fields only have separator lines on the righ, which makes the user selection assymetric so, optionally, the script uses ImageMagick to draw the lines on the left.

## Contributing
I do not have enough knowledge to continue improving upon the initial commit, so any contributions to the project are not only welcome, but also requested.
