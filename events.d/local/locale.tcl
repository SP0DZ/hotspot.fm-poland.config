###############################################################################
#
# Locale specific functions for playing back time, numbers and spelling words.
# Often, the functions in this file are the only ones that have to be
# reimplemented for a new language pack.
#
###############################################################################


#
# Spell the specified word using phonetic alphabet or plain letters depending
# on the setting of the PHONETIC_SPELLING configuration variable.
#
#   word -- The word to spell
#
proc spellWord {word} {
  variable Logic::CFG_PHONETIC_SPELLING
  set word [string tolower $word];
  for {set i 0} {$i < [string length $word]} {set i [expr $i + 1]} {
    set char [string index $word $i];
    if {[regexp {[a-z0-9]} $char]} {
      if {([info exists CFG_PHONETIC_SPELLING]) && \
          ($CFG_PHONETIC_SPELLING == 0)} {
        playMsg "Default" "$char";
      } else {
        playMsg "Default" "phonetic_$char";
      }
    } elseif {$char == "/"} {
      playMsg "Default" "slash";
    } elseif {$char == "-"} {
      playMsg "Default" "dash";
    } elseif {$char == "*"} {
      playMsg "Default" "star";
    }
  }
}


#
# Spell the specified number digit for digit
#
proc spellNumber {number} {
  for {set i 0} {$i < [string length $number]} {set i [expr $i + 1]} {
    set ch [string index $number $i];
    if {$ch == "."} {
      playMsg "Default" "decimal";
    } else {
      playMsg "Default" "$ch";
    }
  }
}


#
# Say the specified two digit number (00 - 99)
#
proc playTwoDigitNumber {number} {
  if {[string length $number] != 2} {
    puts "*** WARNING: Function playTwoDigitNumber received a non two digit number: $number";
    return;
  }
  
  set first [string index $number 0];
  if {($first == "0") || ($first == "O")} {
    playMsg "Default" $first;
    playMsg "Default" [string index $number 1];
  } elseif {$first == "1"} {
    playMsg "Default" $number;
  } elseif {[string index $number 1] == "0"} {
    playMsg "Default" $number;
  } else {
    playMsg "Default" "[string index $number 0]X";
    playMsg "Default" "[string index $number 1]";
  }
}


#
# Say the specified three digit number (000 - 999)
#
proc playThreeDigitNumber {number} {
  if {[string length $number] != 3} {
    puts "*** WARNING: Function playThreeDigitNumber received a non three digit number: $number";
    return;
  }
  
  set first [string index $number 0];
  if {($first == "0") || ($first == "O")} {
    spellNumber $number
  } else {
    append first "00";
    playMsg "Default" $first;
    if {[string index $number 1] != "0"} {
#      playMsg "Default" "and"
      playTwoDigitNumber [string range $number 1 2];
    } elseif {[string index $number 2] != "0"} {
#      playMsg "Default" "and"
      playMsg "Default" [string index $number 2];
    }
  }
}


#
# Say a number as intelligent as posible. Examples:
#
#	1	- one
#	24	- twentyfour
#	245	- twohundred and fourtyfive
#	1234	- twelve thirtyfour
#	12345	- onehundred and twentythree fourtyfive
#	136.5	- onehundred and thirtysix point five
#
proc playNumber {number} {
  if {[regexp {(\d+)\.(\d+)?} $number -> integer fraction]} {
    playNumber $integer;
    playMsg "Default" "decimal";
    spellNumber $fraction;
    return;
  }

  while {[string length $number] > 0} {
    set len [string length $number];
    if {$len == 1} {
      playMsg "Default" $number;
      set number "";
    } elseif {$len % 2 == 0} {
      playTwoDigitNumber [string range $number 0 1];
      set number [string range $number 2 end];
    } else {
      playThreeDigitNumber [string range $number 0 2];
      set number [string range $number 3 end];
    }
  }
}

proc playPressure {number} {
  if {[regexp {(\d+)\.(\d+)?} $number -> integer fraction]} {
    playNumber $integer;
    playMsg "Default" "decimal";
    spellNumber $fraction;
    return;
  }

  while {[string length $number] > 0} {
    set len [string length $number];
    if {$len == 1} {
      playMsg "Default" $number;
      set number "";
    } elseif {$len == 3} {
	playMsg "Default" "900";
	playTwoDigitNumber [string range $number 1 2];
	set number "";
        } elseif {$len == 4} {
	playMsg "Default" "1000";
	playTwoDigitNumber [string range $number 2 3];
	set number "";
    } elseif {$len % 2 == 0} {
      playTwoDigitNumber [string range $number 0 1];
      set number [string range $number 2 end];
    } else {
      playThreeDigitNumber [string range $number 0 2];
      set number [string range $number 3 end];
    }
  }
}


#
# Say the time specified by function arguments "hour" and "minute".
#
proc playTime {hour minute} {
  if {[scan $hour "%d" hour] != 1 || $hour < 0 || $hour > 23} {
    error "playTime: Non digit hour or value out of range: $hour"
  }
  if {[scan $minute "%d" minute] != 1 || $minute < 0 || $minute > 59} {
    error "playTime: Non digit minute or value out of range: $hour"
  }
  
  playMsg "Clock" [expr $hour];

  if {$minute != 0} {
    if {[string length $minute] == 1} {
      set minute "$minute";
    }
    playTwoDigitNumber $minute;
  }
  
  playSilence 50;
}



#
# Say the given frequency as intelligently as popssible
#
#   fq -- The frequency in Hz
#
proc playFrequency {fq} {
  if {$fq < 1000} {
    set unit "Hz"
  } elseif {$fq < 1000000} {
    set fq [expr {$fq / 1000.0}]
    set unit "kHz"
  } elseif {$fq < 1000000000} {
    set fq [expr {$fq / 1000000.0}]
    set unit "MHz"
  } else {
    set fq [expr {$fq / 1000000000.0}]
    set unit "GHz"
  }
  playNumber [string trimright [format "%.3f" $fq] ".0"]
  playMsg "Core" $unit
}

