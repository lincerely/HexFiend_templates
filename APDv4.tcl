# reference: https://gitlab.com/azelpg/azpainter/-/blob/master/src/other/apd_v4_format.c
requires 0 "415A 5044 4154 4103"
section "Header" {
	ascii 7 "ID"
	set version [uint8 "version"]
}

big_endian
section "Image info" {
	uint16 "header size"
	uint32 "width"
	uint32 "height"
	uint32 "dpi"
	uint8 "bits"
	uint8 "color type"
	section "background color" {
		uint8 "r"
		uint8 "g"
		uint8 "b"
	}
	set layer_count [uint16 "layer count"]
}

while {1} {
	set id [ascii 4]
	move -4
	if {$id == "pict"} {
		section "Full picture" {
			ascii 4 "ID"
			set csize [uint32 "csize"]
			while {$csize > 0} {
				section "block" {
					uint16 "ynum"
					set encsize [uint32 "encsize"]
					bytes $encsize "encdata"
				}
				set csize [expr $csize - $encsize - 6]
			}
		}
	} elseif {$id == "thum"} {
		section "Thumbnail" {
			ascii 4 "ID"
			uint32 "data size"
			uint16 "width"
			uint16 "height"
			set csize [uint32 "compressed data size"]
			bytes $csize "compressed data"
		}
		break
	} else {
		break
	}
}

bytes 4 "end of chunk"

section "Layers" {
	set i 0
	while {$i < $layer_count} {
		section "layer $i" {
			uint16 -hex "parent"
			uint8 -hex "lflags"
			

			set coltype [uint8]
			if { $coltype == 0 } { entry "color type" "RGBA" 1 [expr [pos]-1]}
			if { $coltype == 1 } { entry "color type" "gray" 1 [expr [pos]-1]}
			if { $coltype == 2 } { entry "color type" "alpha" 1 [expr [pos]-1]}
			if { $coltype == 3 } { entry "color type" "alpha 1 bit" 1 [expr [pos]-1] }
			
			section "rect" {
				uint32 "x1"
				uint32 "y1"
				uint32 "x2"
				uint32 "y2"
			}
			uint8 "opacity"
			uint8 "alphamask"
			ascii 4 "blend mode"
			uint32 "col"
			uint32 "flags"
			uint16 "tone lines"
			uint16 "tone angle"
			uint8 "tone density"

			section "extra data" {
				while {1} {
					set id [ascii 4]
					move -4
					if {$id == "name" || $id == "texp"} {
						section $id  {
							ascii 4 "ID"
							set strlen [uint32 "length"]
							str $strlen "utf8" "data"
						}
					} elseif {$id == "text"} {
						section $id {
							ascii 4 "ID"
							uint32 "size"
							uint32 "x"
							uint32 "y"
							section "rect" {
								uint32 "x1"
								uint32 "y1"
								uint32 "x2"
								uint32 "y2"
							}
							set dsize [uint32 "data size"]
							bytes $dsize "data"
						}
					} else {
						break
					}
				}
			}

			bytes 4 "end of extra data"

			# write_tileimage
			section "tile image" {
				uint8 "compress type"
				set tilenum [uint32 "tile count"]
				while {$tilenum} {
					section "block $tilenum" {
						set tnum [uint16 "tnum"]
						set size [uint32 "data size"]
						bytes $size "data"
						set tilenum [expr $tilenum - $tnum]
					}
				}
			}
		}
		set i [incr i]
	}
}

bytes 2 "end of layer"
