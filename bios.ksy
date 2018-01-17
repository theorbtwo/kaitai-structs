meta:
  id: bios
  file-extension: bios
  endian: le
  encoding: ASCII
seq:
  - id: spiheader
    type: spiheader
types:
  spiheader:
    seq:
    - id: descfdbar
      type: fdbar
    - id: pad
      size: 8
    - id: descfcba
      type: fcba
    - id: descfrba
      type: frba
      
    - id: pad1
      size: 0x18
    - id: descfmba
      type: fmba
    - id: pad2
      size: 0x64
    - id: descfpsba
      type: fpsba
    - id: pad3
      size: 0x100
    - id: descfmsba
      type: fmsba
    - id: pad4
      size: 0xae4
    - id: descvtbax
      type: vtbax
    - id: descoem
      type: oem
    #- id: describax
    #  type: ribax
  oem:
    seq:
      - id: x
        size: 1
  vtbax: 
    seq:
      - id: data
        size: 0x10c
      - id: vtba
        type: u1
      - id: vtl
        type: u1
      - id: rsvd
        type: u2
        
  fmsba:
    seq:
    - id: cpustrapcpublank
      type: u4
    - id: group4x4
      type: u4
    - id: group8x4
      type: u4
      
  fpsba:
    seq:
    - id: straps0
      type: u4
    - id: straps4
      type: u4
    - id: straps8
      type: u4
    - id: strapsc
      type: u2
    - id: strapse
      type: u2
    - id: straps12
      type: u4
    - id: straps16
      type: u2
    - id: straps18
      type: u4
    - id: straps1c
      type: u4
    - id: straps20
      type: u2
    - id: straps22
      type: u4
    - id: straps26
      type: u4
    - id: rest
      size: 0xd8
      
  fmba:
    seq:
    - id: flmstr
      type: u4
      repeat: expr
      repeat-expr: 7
      
  frba:
    seq:
    - id: flregdesc
      type: flreg
    - id: flregbios
      type: flreg
    - id: flregme
      type: flreg
    - id: flreggbe
      type: flreg
    - id: flregpdr
      type: flreg
    - id: flregpdr
      type: flreg
    - id: flreg
      type: flreg
      repeat: expr
      repeat-expr: 4
      
  flreg:
    seq:
    - id: base
      type: u2
    - id: limit
      type: u2
      
  fcba:
    seq:
    - id: flcomp
      type: u4
    - id: flill
      type: u4
    - id: flill1
      type: u4
    - id: reserved
      type: u4
      
  fdbar:
    seq:
    - id: pad
      size: 0x10
    - id: magic
      #size: 4
      contents: [0x5a, 0xa5, 0xf0, 0x0f]
    - id: flmap0
      type: u4
    - id: flmap1
      type: u4
    - id: flmap2
      type: u4
    - id: flmap3
      type: u4
    - id: flmap4
      type: u4
      
  cpd_header:
    seq:
    - id: marker
      contents: "$CPD"
    - id: entries
      type: u4
    - id: header_version
      type: u1
    - id: entry_version
      type: u1
    - id: header_length
      type: u1
    - id: checksum
      type: u1
    - id: partition_name
      type: str
      size: 4
      encoding: ASCII
    - id: actual_entries
      repeat: expr
      repeat-expr: entries
      type: cpd_entry
      
  sub_section_mn_2:
   seq:
   - id: cpd
     type: cpd_header
   - id: manifest_header
     type: manifest_header
   - id: x
     size: manifest_header.modulusSize
  
  manifest_header:
    seq:
    - id: type
      type: u4
      #value: 4
    - id: length
      type: u4
    - id: version
      type: u4
    - id: flags
      type: u4
    - id: vendor
      type: u4
    - id: date
      type: u4
    - id: size
      type: u4
    - id: header_id
      type: str
      size: 4
      encoding: ASCII
    - id: reserved0
      type: u4
    - id: version_major
      type: u2
    - id: version_minor
      type: u2
    - id: version_hotfix
      type: u2
    - id: version_build
      type: u2
    - id: svn
      type: u4
    - id: reserved1
      type: u8
    - id: reserved2
      size: 64
    - id: modulus_size
      type: u4
    - id: exponent_size
      type: u4
      
  cpd_entry:
    seq:
      - id: name
        type: str
        size: 12
      - id: offset_info
        type: u4
      #- id: offset_reserved
      #  type: b6
      #- id: offset_compress_flag
      #  type: b1
      #- id: offset_address
      #  type: b25
      - id: length
        type: u4
      - id: reserved
        type: u4
    #instances:
    #  offset_address:
    #    value: (offset_info >> 0) & ((1<<((24-0)+1))-1)
    #  offset_compress_flag:
    #    value: offset_info >> 25) & ((1<<((25-25)+1))-1)
    #  offset_reserved:
    #    value: offset_info >> 26) & ((1<<((31-26)+1))-1)
    
instances:
  sub_section_mn_2_1:
    pos: 0x02000
    type: sub_section_mn_2
  sub_section_mn_2_1:
    pos: 0x06000
    type: sub_section_mn_2
  sub_section_mn_2_1:
    pos: 0x10000
    type: sub_section_mn_2
  sub_section_mn_2_1:
    pos: 0x20000
    type: sub_section_mn_2
  sub_section_mn_2_1:
    pos: 0x7b000
    type: sub_section_mn_2
