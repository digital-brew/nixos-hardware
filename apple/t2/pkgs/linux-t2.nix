{ lib, buildLinux, fetchFromGitHub, fetchzip, runCommand
, ... } @ args:

let
  patchRepo = fetchFromGitHub {
    owner = "t2linux";
    repo = "linux-t2-patches";
    rev = "234bbef68c666aa33bb4f78841d08fd8ea787af2";
    hash = "sha256-6L5n1Yg2TDtdEjyeyjXlbNicS0ttwRcuMTaYRCaV1gI=";
  };

  version = "6.7.3";
  majorVersion = with lib; (elemAt (take 1 (splitVersion version)) 0);
in
buildLinux (args // {
  inherit version;

  pname = "linux-t2";
  # Snippet from nixpkgs
  modDirVersion = with lib; "${concatStringsSep "." (take 3 (splitVersion "${version}.0"))}";

  src = runCommand "patched-source" {} ''
    cp -r ${fetchzip {
      url = "mirror://kernel/linux/kernel/v${majorVersion}.x/linux-${version}.tar.xz";
      hash = "sha256-jOHfvTYsiGbTLw7DM+OQivNbP5A1SGajlPjZicY1i1s=";
    }} $out
    chmod -R u+w $out
    cd $out
    while read -r patch; do
      echo "Applying patch $patch";
      patch -p1 < $patch;
    done < <(find ${patchRepo} -type f -name "*.patch" | sort)
  '';

  structuredExtraConfig = with lib.kernel; {
    APPLE_BCE = module;
    APPLE_GMUX = module;
    BRCMFMAC = module;
    BT_BCM = module;
    BT_HCIBCM4377 = module;
    BT_HCIUART_BCM = yes;
    BT_HCIUART = module;
    DRM_APPLETBDRM = module;
    # HID_APPLE_IBRIDGE = module;
    HID_APPLE = module;
    HID_APPLE_MAGIC_BACKLIGHT = module;
    # HID_APPLE_TOUCHBAR = module;
    HID_APPLETB_BL = module;
    HID_APPLETB_KBD = module;
    HID_SENSOR_ALS = module;
    SND_PCM = module;
    STAGING = yes;
  };

  kernelPatches = [];
} // (args.argsOverride or {}))
