meta:
  id: dbxc_shader
  file-extension: dbxc
  endian: le
  encoding: ascii
  # References: 
  # timjones: http://timjones.io/blog/archive/2015/09/02/parsing-direct3d-shader-bytecode#hlsl-sm-assembly
seq:
  - id: magic
    size: 4
    contents: "DXBC"
  - id: hash
    # timjones calls this a checksum, but it's not that algorythm
    size: 16
  - id: one
    type: u4
  - id: total_size
    type: u4
    # unlike most sizes, this includes the header
  - id: chunk_count
    type: u4
  - id: chunks
    type: chunk_abstract
    repeat: expr
    repeat-expr: chunk_count
types:
  chunk_abstract:
    seq:
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        size-eos: true
        type: chunk_header
  chunk_header:
    seq:
      - id: type
        type: str
        size: 4
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: type
          cases:
            '"RDEF"': rdef_body
            '"ISGN"': signature_body
            '"OSGN"': signature_body
  rdef_body:
    seq:
      - id: constant_count
        type: u4
      - id: constants
        repeat: expr
        repeat-expr: constant_count
        type: rdef_body_constant_abstract
      - id: resource_binding_count
        type: u4
      - id: resource_binding_offset
        type: u4
      - id: ver_minor
        type: u1
      - id: ver_major
        type: u1
      - id: program_type
        type: s2
      - id: flags
        type: u4
        # 0x100: NoPreshader
      - id: creator
        type: u4_strz_p
    instances:
      resource_bindings:
        pos: resource_binding_offset
        type: resource_binding
        repeat: expr
        repeat-expr: resource_binding_count
  resource_binding:
    seq:
      - id: name_offset
        type: u4 # _to_strz, rel start of chunk
      - id: input_type
        type: u4
        enum: shader_input_type
      - id: return_type
        type: u4
        enum: resource_return_type
      - id: view_dimension
        type: u4
      - id: num_samples
        type: u4
      - id: bind_point
        type: u4
      - id: bind_count
        type: u4
      - id: shader_input_flags
        type: u4
    instances:
      name:
        type: str
        terminator: 0
        pos: name_offset
  rdef_body_constant_abstract:
    seq:
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        size-eos: true
        type: constant
  constant:
    seq:
      - id: buffer_name
        type: u4_strz_pp
      - id: variable_count
        type: u4
      - id: variable_offsets
        type: u4
        repeat: expr
        repeat-expr: variable_count
      - id: buffer_size
        type: u4
      - id: flags
        type: u4
      - id: buffer_type
        type: u4
  signature_body:
    seq:
      - id: element_count
        type: u4
      - id: elements
        repeat: expr
        repeat-expr: element_count
        type: signature_element_abstract
      - id: eight
        type: u4
        # contents: 8
  signature_element_abstract:
    seq:
      - id: offset
        type: u4
    instances:
      data:
        pos: offset
        size-eos: true
        type: signature_element
  signature_element:
    seq:
      - id: semantic_name_offset
        type: u4 # FIME: Straight sttrz is wrong, but _p and _pp error out?
      - id: semantic_index
        type: u4
      - id: system_value_type
        type: u4
      - id: component_type
        type: u4 # 0: unk 1: unsigned 2: signed 3: float
      - id: mask
        type: u1
      - id: read_write_mask
        # osgn: never written
        # isgn: always read
        type: u1
    instances:
      semantic_name:
        type: str
        terminator: 0
        pos: semantic_name_offset - _parent.offset
  u4_strz:
    seq:
      - id: offset
        type: u4
    instances:
      str:
        type: str
        pos: offset
        terminator: 0
  u4_strz_p:
    seq:
      - id: offset
        type: u4
    instances:
      str:
        io: _parent._io
        type: str
        pos: offset
        terminator: 0
  u4_strz_pp:
    seq:
      - id: offset
        type: u4
    instances:
      str:
        io: _parent._parent._io
        type: str
        pos: offset
        terminator: 0
enums:
  shader_input_type:
    0: cbuffer
    1: tbuffer
    2: texture
    3: sampler
    # ...
  resource_return_type:
    0: not_applicable
    1: unorm
    2: snorm
    3: sint
    4: uint
    5: float
    
