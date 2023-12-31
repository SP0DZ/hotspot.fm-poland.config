###############################################################################
#
# Tcl module event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
# The name must match the configuration variable "NAME" in the
# [ModuleTcl] section in the configuration file. The name may be changed
# but it must be changed in both places.
#
namespace eval NetInfo {

variable cpu_offset 30

#
# Check if this module is loaded in the current logic core
#
if {![info exists CFG_ID]} {
  return
}


#
# Extract the module name from the current namespace
#
set module_name [namespace tail [namespace current]]


#
# An "overloaded" playMsg that eliminates the need to write the module name
# as the first argument.
#
#   msg - The message to play
#
#proc playMsg {msg} {
#  variable module_name
#  ::playMsg $module_name $msg
#}


#
# A convenience function for printing out information prefixed by the
# module name.
#
#   msg - The message to print
#
proc printInfo {msg} {
  variable module_name
  puts "$module_name: $msg"
}


#
# Executed when this module is being activated
#
proc activating_module {} {
  variable module_name
  Module::activating_module $module_name
}


#
# Executed when this module is being deactivated.
#
proc deactivating_module {} {
  variable module_name
  Module::deactivating_module $module_name
}


#
# Executed when the inactivity timeout for this module has expired.
#
proc timeout {} {
  variable module_name
  Module::timeout $module_name
}


#
# Executed when playing of the help message for this module has been requested.
#
proc play_help {} {
  variable module_name
  Module::play_help $module_name
}

proc play_status {} {

  # moze wymagac: sudo chmod 4755 /usr/bin/ping
  set status [catch {exec ping -c 1 -W 1 google.com} result]
  if {$status == 0} {
     playSilence 1000;
     puts "Internet online: Connected"
     playMsg "NetInfo" "internet_connection_active";
     set runcmd [exec /usr/bin/hostname -I];
     playSilence 200;
     playMsg "NetInfo" "ip_address_local";
     playSilence 200;
     set splitip1 [split $runcmd " "]
     lassign $splitip1 ipa1 ipa2 ipa3 ipa4
     set splitip2 [split $ipa1 .]
     puts "Local IP Adress: $ipa1"
     playSilence 100;
     lassign $splitip2 ip1 ip2 ip3 ip4
     playNumber $ip1;
     playSilence 100;
     playMsg "NetInfo" "dot";
     playSilence 100;
     playNumber $ip2;
     playSilence 100;
     playMsg "NetInfo" "dot";
     playSilence 100;
     playNumber $ip3;
     playSilence 100;
     playMsg "NetInfo" "dot";
     playSilence 100;
     playNumber $ip4;
     playSilence 100;

} else {
     puts "Internet online: Disconnected"
     playMsg "Default" "internet_connection_inactive";
}
    return 1
}


#
# Executed when the state of this module should be reported on the radio
# channel. The rules for when this function is called are:
#
# When a module is active:
# * At manual identification the status_report function for the active module is
#   called.
# * At periodic identification no status_report function is called.
#
# When no module is active:
# * At both manual and periodic (long variant) identification the status_report
#   function is called for all modules.
#
proc status_report {} {
  printInfo "status_report called..."
}


#
# Called when an illegal command has been entered
#
#   cmd - The received command
#
proc unknown_command {cmd} {
  playNumber $cmd
  playMsg "unknown_command"
}



# end of namespace
}


#
# This file has not been truncated
#
