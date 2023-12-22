# .types = ( rmf );
# Rich Map Format for Worldcraft editor used in Half-Life.
# reference: https://twhl.info/wiki/page/Specification%3A_RMF
# refernece: https://github.com/LogicAndTrick/sledge-formats/blob/master/Sledge.Formats.Map/Formats/WorldcraftRmfFormat.cs

# "RMF"
requires 4 "524D46"
little_endian

proc p_char {label} {
	set strlen [uint8]
	return [ascii $strlen $label]
}
proc rgb {label} {
	bytes 3 $label
}

proc rgba {label} {
	bytes 4 $label
}

proc vector {label} {
	section $label {
		float "x"
		float "y"
		float "z"
	}
}

proc mapbase {} {
	int32 "visgroup_id"
	rgb "color"
	set child_count [int32 "child_count"]
	section "brushes" {
		for {set i 0} {$i < $child_count} {incr i} {
			mapobject
		}
	}
}

proc keyval {} {
	p_char "key"
	p_char "value"
}

proc keyvals {} {
	section "keyvalues" {
		set kv_count [int32 "kv_count"]
		for {set i 0} {$i < $kv_count} {incr i} {
			keyval
		}
	}
}

proc entitydata {} {
	p_char "classname"
	move 4
	int32 "spawnflags"
	keyvals
	move 12
}

proc mapworld {} {
	section "mapworld" {
		mapbase
	}
}

proc mapentity {} {
	section "mapentity" {
		mapbase
		entitydata
		move 2
		vector "origin"
		move 4
	}
}

proc face {} {
	global version
	if {$version > 1.6} {
		ascii 260 "texture_name"
	} else {
		ascii 40 "texture_name"
	}
	if {$version > 1.8} {
		vector "right_axis"
		float "shift_x"
		vector "down_axis"
		float "shift_y"
		float "angle"
		float "scale_x"
		float "scale_y"
	} else {
		float "shift_x"
		float "shift_y"
		float "angle"
		float "scale_x"
		float "scale_y"
	}
	if {$version > 1.6 } {
		move 16
	} else {
		move 4
	}
	section "vertices" {
		set vertex_count [int32 "vertex_count"]
		for {set i 0} {$i < $vertex_count} {incr i} {
			vector $i
		}
	}
	section "plane_points" {
		vector "1"
		vector "2"
		vector "3"	
	}
}

proc pathnode {} {
	vector "position"
	int32 "index"
	ascii 128 "name_override"
	keyvals
}

proc path {} {
	section "path" {
		ascii 128 "path_name"
		ascii 128 "classname"
		int32 "path_type"
		section "nodes" {
			set node_count [int32 "node_count"]
			for {set i 0} {$i < $node_count} {incr i} {
				pathnode
			}
		}
	}
}

proc camera {label} {
	section $label {
		vector "eye_position"
		vector "lookat_position"
	}
}

proc docinfo {} {
	ascii 8 "docinfo"
	float "version"
	int32 "active_camera"
	sections "cameras" {
		set camera_count [int32 "camera_count"]
		for {set i 0} {$i < $node_count} {incr i} {
			camera $i
		}
	}
}

proc mapsolid {} {
	section "mapsolid" {
		mapbase
		set face_count [int32 face_count]
		for {set i 0} {$i < $face_count} {incr i} {
			face	
		}
	}
}

proc mapgroup {} {
	section "mapgroup" {
		mapbase
	}
}


proc mapobject {} {
	set type [p_char "object_type"]
	switch $type {
		"CMapWorld" { mapworld }
		"CMapGroup" { mapgroup }
		"CMapSolid" { mapsolid }
		"CMapEntity" { mapentity }
	}
}

section "Header" {
	set version [format "%.1f" [float "version"]]
	ascii 3 "RMF"
}

section "visgroup" {
	set nvis [int32 "number of vis groups"]
	for {set i 0} {$i < $nvis} {incr i} {
		ascii 128 "name"
		rgba "color"
		int32 "ID"
		byte "visible"
		bytes 3 "unknown"
	} 
}

section "worldspawn" {
	mapobject
}
