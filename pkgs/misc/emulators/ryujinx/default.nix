{ lib, buildDotnetModule, fetchFromGitHub, makeDesktopItem, copyDesktopItems
, libX11, libgdiplus, ffmpeg
, SDL2_mixer, openal, libsoundio, sndio, pulseaudio
, gtk3, gdk-pixbuf, wrapGAppsHook
}:

buildDotnetModule rec {
  pname = "ryujinx";
  version = "1.0.7105"; # Versioning is based off of the official appveyor builds: https://ci.appveyor.com/project/gdkchan/ryujinx

  src = fetchFromGitHub {
    owner = "Ryujinx";
    repo = "Ryujinx";
    rev = "b9d83cc97ee1cb8c60d9b01c162bab742567fe6e";
    sha256 = "0plchh8f9xhhza1wfw3ys78f0pa1bh3898fqhfhcc0kxb39px9is";
  };

  projectFile = "Ryujinx.sln";
  nugetDeps = ./deps.nix;

  dotnetFlags = [ "/p:ExtraDefineConstants=DISABLE_UPDATER" ];

  # TODO: Add the headless frontend. Currently errors on the following:
  # System.Exception: SDL2 initlaization failed with error "No available video device"
  executables = [ "Ryujinx" ];

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
  ];

  runtimeDeps = [
    gtk3
    libX11
    libgdiplus
    ffmpeg
    SDL2_mixer
    openal
    libsoundio
    sndio
    pulseaudio
  ];

  patches = [
    ./log.patch # Without this, Ryujinx attempts to write logs to the nix store. This patch makes it write to "~/.config/Ryujinx/Logs" on Linux.
  ];

  preInstall = ''
    # TODO: fix this hack https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6

    makeWrapperArgs+=(
      --suffix LD_LIBRARY_PATH : "$out/lib/sndio-6"
    )

    for i in 16 32 48 64 96 128 256 512 1024; do
      install -D ${src}/Ryujinx/Ui/Resources/Logo_Ryujinx.png $out/share/icons/hicolor/''${i}x$i/apps/ryujinx.png
    done
  '';

  desktopItems = [(makeDesktopItem {
    desktopName = "Ryujinx";
    name = "ryujinx";
    exec = "Ryujinx";
    icon = "ryujinx";
    comment = meta.description;
    type = "Application";
    categories = "Game;";
  })];

  meta = with lib; {
    description = "Experimental Nintendo Switch Emulator written in C#";
    homepage = "https://ryujinx.org/";
    license = licenses.mit;
    changelog = "https://github.com/Ryujinx/Ryujinx/wiki/Changelog";
    maintainers = [ maintainers.ivar ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "Ryujinx";
  };
  passthru.updateScript = ./updater.sh;
}
