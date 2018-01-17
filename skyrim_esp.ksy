meta:
  id: skyrim_esp
  file-extension: esp
  encoding: ascii
  endian: le
seq:
- id: top
  type: generic_record
types:
  generic_record:
    seq:
    - id: type
      size: 4
      type: str
    - id: data_size
      type: u4
    - id: flags
      type: u4
    - id: formid
      type: u4
      if: type != "TES4"
    - id: version_control_info
      type: u4
      if: false
    - id: a
      type: u4
      if: type == "TES4"
    - id: b
      type: u4
      if: type == "TES4"
    - id: c
      type: u4
      if: type == "TES4"
    - id: record
      type: sub_record
      repeat: expr
      repeat-expr: 8
    #  repeat: eos
    #- id: data
    #  size: data_size
  sub_record:
    seq:
    - id: t
      size: 4
      type: str
    - id: data_size
      type: u2
      if: t != "GRUP"
    - id: body
      if: t != "GRUP"
      size: data_size
      #type: u1
      type: 
        switch-on: t
        cases:
          '"HEDR"': hedr_body
          '"INTV"': u4
          _: str
    - id: body
      if: t == "GRUP"
      type: grup_body
  grup_body:
    seq:
    - id: group_size
      type: u4
    - id: label
      type: str
      size: 4
    - id: group_type
      type: u4
      #enum: group_type
    - id: stamp_month
      type: u1 # bcd, /12 years since 2002, %12 month
    - id: stamp_day
      type: u1 # bcd
    - id: unknown
      type: u2
    - id: version
      type: u2
    - id: unknown2
      type: u2
    - id: body
      size: group_size - 24
      type:
        switch-on: group_type
        cases:
          0: top_record
  top_record:
    # http://en.uesp.net/wiki/Tes5Mod:Mod_File_Format#Records
    seq:
      - id: type
        type: str
        size: 4
      - id: data_size
        type: u4
      - id: flags
        type: u4
      - id: id
        type: u4
      - id: revision
        type: u4
      - id: version
        type: u2
      - id: unknown
        type: u2
      - id: data
        size: data_size
  str_p2:
    seq:
    - id: len
      type: u2
    - id: string
      type: str
      size: 2
  hedr_body:
    seq:
    - id: version
      type: f4
      # commentary: who the hell makes a version number a float?
    - id: num_records
      type: u4
    - id: next_object_id
      type: u4
  tes4:
    seq:
    - id: fourcc
      size: 4
      type: str
    - id: a
      type: u4
    - id: b
      type: u4
    - id: c
      type: u4
    - id: d
      type: u4
    - id: e
      type: u4
    - id: hedr
      type: hedr
  hedr:
    seq:
    - id: fourcc
      size: 4
      type: str
enums:
  group_type:
    0: top
    1: world_children
    2: interior_cell_block
    3: interior_cell_subblock
    4: exterior_cell_block
    5: exterior_cell_subblock
