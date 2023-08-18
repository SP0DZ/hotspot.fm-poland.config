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
namespace eval MeteoInfo {

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

proc play_hydro {} {

  playSilence 1000;

   if {[file exist "/var/spool/svxlink/bulletins/hydro.tcl"] == 1} {
     puts "Playing HYDRO Info"
     source "/var/spool/svxlink/bulletins/hydro.tcl"
     playMsg "HydroInfo" "hydro_source"
      } else {
     playMsg "HydroInfo" "hydro"
     playMsg "HydroInfo" "nodata"
   }

}
proc play_hfprop {} {
   playSilence 1000;
   if {[file exist "/var/spool/svxlink/bulletins/hfprop.tcl"] == 1} {
     puts "Playing HF VHF Propagation Info"
     source "/var/spool/svxlink/bulletins/hfprop.tcl"
     playMsg "HFProp" "source"
     } else {
       playMsg "HFProp" "hfprop"
       playMsg "HFProp" "nodata"
   }

}
proc play_zplas {} {

  set month [clock format [clock sec] -format %m];

  playSilence 1000;

   if {[file exist "/var/spool/svxlink/bulletins/zplas.tcl"] == 1 && ($month >= "03" || $month <= "09")} {
     puts "Playing Zagrozenie Pozarowe Lasow Info"
     source "/var/spool/svxlink/bulletins/zplas.tcl"
     playMsg "ZPLas" "info"
   } else {
     playMsg "ZPLas" "zplas"
     playMsg "ZPLas" "nodata"
 }
}

proc play_meteo {} {

  playSilence 1000

   if {[file exist "/var/spool/svxlink/bulletins/wx.tcl"] == 1} {
     puts "Playing WX Info"
     source "/var/spool/svxlink/bulletins/wx.tcl"
     playMsg "MeteoInfo" "wx_sources"
   } else {
     playMsg "MeteoInfo" "wx_nodata"
   }

}

proc play_malerts {} {

  playSilence 1000

   if {[file exist "/var/spool/svxlink/bulletins/meteo.wav"] == 1} {
     puts "Playing METEO Alert";
     playFile "/var/spool/svxlink/bulletins/meteo.wav"; 
   } else {
     playMsg "MeteoInfo" "noalerts"
   }
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
