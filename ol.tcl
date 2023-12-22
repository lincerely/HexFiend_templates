# .types = ( ol );
# Worldcraft editor prefab library
# reference: https://github.com/LogicAndTrick/sledge-formats/blob/master/Sledge.Formats.Map/Formats/WorldcraftPrefabLibrary.cs

# "Worldcraft Prefab Library\r\n"+0x1A
requires 0 "576F 726C 6463 7261 6674 2050 7265 6661 6220 4C69 6272 6172 790D 0A1A"

little_endian
section "Header" {
	ascii 28 "magic"
	float "version"
	set offset [uint32 "offset"]
	set num [uint16 "num"]
}

goto $offset

for {set i 0} {$i < $num} {incr i} {
	section "object" {
		set objoffset [uint32 "offset"]
		set objlength [uint32 "length"]
		ascii 31 "name"
		ascii 205 "desc"
		set cur [pos]
		goto $objoffset
		bytes $objlength ".rmf data"
		goto $cur
		move 300
	}
}
