#!rsc by RouterOS
# RouterOS script: dhcp-lease-comment.wifiwave2
# Copyright (c) 2013-2024 Christian Hesse <mail@eworm.de>
# https://git.eworm.de/cgit/routeros-scripts/about/COPYING.md
#
# provides: lease-script, order=60
# requires RouterOS, version=7.12
#
# update dhcp-server lease comment with infos from access-list
# https://git.eworm.de/cgit/routeros-scripts/about/doc/dhcp-lease-comment.md
#
# !! Do not edit this file, it is generated from template!

:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:local Main do={
  :local ScriptName [ :tostr $1 ];

  :global LogPrintExit2;
  :global ScriptLock;

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :return false;
  }

  :foreach Lease in=[ /ip/dhcp-server/lease/find where dynamic=yes status=bound ] do={
    :local LeaseVal [ /ip/dhcp-server/lease/get $Lease ];
    :local NewComment;
    :local AccessList ([ /interface/wifiwave2/access-list/find where mac-address=($LeaseVal->"active-mac-address") ]->0);
    :if ([ :len $AccessList ] > 0) do={
      :set NewComment [ /interface/wifiwave2/access-list/get $AccessList comment ];
    }
    :if ([ :len $NewComment ] != 0 && $LeaseVal->"comment" != $NewComment) do={
      $LogPrintExit2 info $ScriptName ("Updating comment for DHCP lease " . $LeaseVal->"active-mac-address" . ": " . $NewComment) false;
      /ip/dhcp-server/lease/set comment=$NewComment $Lease;
    }
  }
}

$Main [ :jobname ];
