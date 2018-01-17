meta:
  id: me_met
  file-extension: met
  endian: le
  encoding: ascii
  # doc: "status: general purpose, no obvious problems"
seq:
  - id: extensions
    repeat: eos
    type: tlv
types:
  tlv:
    seq:
    - id: type
      type: u4
    - id: length
      type: u4
    - id: body
      size: length-8
      type:
        switch-on: type
        cases:
          4: mod_ext_4
          5: mod_ext_5
          6: mod_ext_6
          8: mod_ext_8
          9: mod_ext_9
          10: mod_attr_extension
          11: mod_ext_11
          13: mod_ext_13
    
  mod_attr_extension:
    seq:
    - id: compression_type
      type: u1
    - id: reserved
      size: 3
      contents: [0, 0, 0]
    - id: uncompressed_size
      type: u4
    - id: compressed_size
      type: u4
    - id: global_id_module_number
      type: u2
    - id: global_id_vendor_id
      type: u2
    - id: image_hash
      size: 32
  mod_ext_4:
    seq:
    - id: context_size
      type: u4
    - id: total_alloc
      type: u4
    - id: code_base
      type: u4
    - id: tls_size
      type: u4
    - id: reserved
      type: u4
  mod_ext_5:
    seq:
    - id: flags
      type: u4
    - id: thread_id
      type: u4
    - id: code_base
      type: u4
    - id: code_size_uncomp
      type: u4
    - id: cm0_heap
      type: u4
    - id: bss_size
      type: u4
    - id: default_heap_size
      type: u4
    - id: main_thread_entry
      type: u4
    - id: allowed_syscalls
      size: 16
    - id: user_id
      type: u2
    - id: reserved
      size: 10
    - id: group_id
      type: u2
    - id: trailing_data
      type: u2
  mod_ext_6:
    seq:
      # fixme: revisit with a better example (vfs.met has only one thread)      
      - id: stack_size
        type: u2
      - id: flags
        type: u4
      - id: policy
        type: u4
  mod_ext_8:
    seq:
      - id: ranges
        repeat: eos
        type: each
    types:
      each:
        seq:
        - id: base
          type: u4
        - id: size
          type: u4
        - id: permission
          type: u4
  mod_ext_9:
    seq:
      - id: major
        type: u2
      - id: flags
        type: u2
      - id: producers
        repeat: eos
        #repeat: expr
        #repeat-expr: 2
        type: each
    types:
      each:
        seq:
        - id: name
          type: str
          size: 12
        - id: access
          type: u2
        - id: user
          type: u2
        - id: group
          type: u2
        - id: minor
          type: u1
        - id: reserved
          size: 5
  mod_ext_13:
    seq:
      - id: users
        repeat: eos
        #repeat: expr
        #repeat-expr: 2
        type: each
    types:
      each:
        seq:
        - id: uid
          type: u2
        - id: pad
          type: u2
        - id: nv_quota
          type: u4
        - id: ram_quota
          type: u4
        - id: wear_out_quota
          type: u4
        - id: working_dir
          type: str
          size: 36
  mod_ext_11:
    seq:
      - id: ranges
        repeat: eos
        #repeat: expr
        #repeat-expr: 2
        type: each
    types:
      each:
        seq:
        - id: base
          type: u4
        - id: size
          type: u4
