meta:
  id: fvh
  file-extension: fvh
  endian: le
  encoding: ascii
  # doc: http://www.uefi.org/sites/default/files/resources/PI_Spec_1_6.pdf section 3.2
  # doc: "Incomplete, not general"
  ks-debug: true
instances:
 x83440:
  pos: 0x83440
  size: 0x1000
  type: fvh_head
 x84440:
  pos: 0x84440
  size: 0xbc000
  type: fvh_head
 x3f2000:
  pos: 0x3f2000
  size: 0x20000
  type: fvh_head
  # when parsing body[2]:
  # Call stack: undefined KaitaiEOFError: requested 18446744073709552000 bytes, but only -32 bytes available
 x432000:
  pos: 0x432000
  size: 0x2000
  type: fvh_head
 x434000:
  pos: 0x434000
  size: 3452928 #0x352000 # 0x352000 #file cuts out early.
  type: fvh_head
   
types:
  fvh_head:
    doc: 3.2.1
    seq:
      - id: zero_vector
        size: 0x10
      - id: guid
        type: guid
      - id: fv_length
        type: u8
      - id: magic
        size: 4
        #type: str
        contents: "_FVH"
      - id: attributes
        type: u4
        # FIXME: attributes into a bitfield - EFI_FVB_ATTRIBUTES_2
      - id: header_length
        type: u2
      - id: checksum
        type: u2
      - id: ext_header_offset
        type: u2
      - id: reserved
        type: u1
      - id: revision
        type: u1
      - id: block_map
        type: efi_fv_block_map
        repeat: until
        repeat-until: _.num_blocks == 0
    instances:
      ext_header:
        pos: ext_header_offset
        type: efi_firmware_volume_ext_header
        if: ext_header_offset != 0
      body:
        pos: ext_header_offset ? (ext_header_offset + ext_header.ext_header_size) : header_length
        type: efi_ffs_file_header
        #repeat: eos
        
        #repeat: expr
        #repeat-expr: 4
        
        repeat: until
        # the last clause is a cop-out, since the end of my firmware image is cut off.
        repeat-until: _.attributes == 0xFF or _io.eof #or _.real_size == 0x3018
  efi_ffs_file_header:
    seq:
      - id: pad0
        type: pad_to_8
      - id: name
        type: guid
      - id: integrety_check
        type: u2
      - id: type
        type: u1
        enum: filetype
      - id: attributes
        type: u1
      - id: size
        type: u1
        repeat: expr
        repeat-expr: 3
      - id: state
        type: u1
      - id: extended_size
        type: u8
        if: large_file
      - id: body
        size: real_size - 24
        if: attributes != 0xFF
        type: efi_common_section_headers
    instances:
      large_file:
        value: attributes & 1 == 1
      fixed:
        value: attributes & 2 == 2
      checksum:
        value: attributes & 0x40 == 0x40
      align_raw:
        value: attributes & 0x38
      size24:
        value: size[0] + (size[1] << 8) + (size[2] << 16)
      parsed_size:
        value: large_file ? extended_size : size24
      real_size:
        value: parsed_size > (_io.size - _io.pos) ? (_io.size - _io.pos + 24) : parsed_size
  efi_common_section_headers:
    seq:
      - id: x
        type: efi_common_section_header
        if: _parent.type != filetype::raw and _parent.type != filetype::ffs_pad
        repeat: expr
        repeat-expr: 2
        #repeat: eos
  efi_common_section_header:
    seq:
      - id: padding
        type: pad_to_4
      - id: size
        type: u1
        repeat: expr
        repeat-expr: 3
      - id: type
        type: u1
        enum: efi_section_type
      - id: body
        size: real_size - 4
    instances:
      size24:
        value: size[0] + (size[1] << 8) + (size[2] << 16)
      parsed_size:
        value: size24
      real_size:
        value: parsed_size > (_io.size - _io.pos) ? (_io.size - _io.pos) : parsed_size
  guid:
    seq:
      - id: data1
        type: u4
      - id: data2
        type: u2
      - id: data3
        type: u2
      - id: data4
        type: u1
        repeat: expr
        repeat-expr: 8
        
      #- id: it
      #  size: 16
  efi_firmware_volume_ext_header:
    seq:
      - id: fv_name
        type: guid
      - id: ext_header_size
        type: u4
      - id: entry
        type: efi_firmware_volume_ext_entry
        size: ext_header_size - 0x14
        repeat: eos
        #repeat-expr: 1
        if: ext_header_size > 0x14
  efi_firmware_volume_ext_entry:
    seq:
      - id: ext_entry_size
        type: u2
      - id: ext_entry_type
        type: u2
  efi_fv_block_map:
    seq:
      - id: num_blocks
        type: u4
      - id: length
        type: u4
  pad_to_4:
    seq:
    - id: padding
      size: (_io.pos % 4) == 0 ? 0 : 4-(_io.pos % 4)
  pad_to_8:
    seq:
    - id: padding
      size: (_io.pos % 8) == 0 ? 0 : 8-(_io.pos % 8)
enums:
  filetype:
    1: raw
    2: freeform
    3: security_core
    4: pei_core
    5: dxe_core
    6: peim
    7: driver
    8: combined_peim_driver
    9: application
    0xa: mm
    0xb: firmware_volume_image
    0xc: combined_mm_dxe
    0xd: mm_core
    0xe: mm_standalone
    0xf: mm_core_standalone
    0xf0: ffs_pad
  efi_section_type:
    # pi vol 3 3.2.4
    # encap sections
    1: compression
    2: guid_defined
    3: disposable
    # leaf sections
    0x10: pe32
    0x11: pic
    0x12: te
    0x13: dxe_depex
    0x14: version
    0x15: user_interface
    0x16: compatability16
    0x17: firmware_volume_image
    0x18: freeform_subtype_guid
    0x19: raw
    #0x1a: 
    0x1b: pei_depex
    0x1c: mm_depex
    
