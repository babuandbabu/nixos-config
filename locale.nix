# TODO: review these values for your location.
{ ... }:
{
  time.timeZone = "Asia/Kolkata";       # TODO: change if wrong (`timedatectl list-timezones`)
  i18n.defaultLocale = "en_US.UTF-8";   # TODO: change if you want another language

  services.xserver.xkb.layout = "us";   # TODO: keyboard layout (used by SDDM greeter)
  console.useXkbConfig = true;          # TTY uses the same layout
}
