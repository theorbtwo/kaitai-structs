meta:
  id: swf
  file-extension: swf
  encoding: ascii
  endian: le
  # http://www.file-recovery.com/swf-signature-format.htm
  # http://www.adobe.com/devnet/swf.html
  # doc: highly incomplete, general, does not handle compressed
  # swf files (CWS / SWC files), because of ide.kaitai.io bug
  # https://github.com/kaitai-io/kaitai_struct_webide/issues/47
seq:
  - id: compression
    type: u1
  - id: signature
    size: 2
    contents: "WS"
  - id: version
    type: u1
  - id: total_size
    type: u4
instances:
  body_plain:
    pos: 8
    size: total_size-8
    #size-eos: true
    #type: file_body
    if: compression == 70 # F 
    #process:
    #  switch-on: compression
  body_compressed:
    pos: 8
    #size: total_size-8
    size-eos: true
    #type: file_body 
    if: compression == 67 # C
    process: zlib
  
types:
  file_body:
    seq:
    - id: frame_size
      type: rect
    - id: frame_rate
      type: u2
      # fixme: 8.8 fixed-point, frames per second
    - id: frame_count
      type: u2
      # How many frames in file.
    - id: tags
      type: tag
      repeat: eos
      #repeat: expr
      #repeat-expr: 4
  tag:
    seq:
      - id: tag_code_and_length
        type: u2
      - id: long_length
        type: u4
        if: short_length == 0x3f
      - id: body
        size: length
        type:
          switch-on: code
          cases:
            # Appendix B
            # 0: end
            # 1: show_frame
            # 2: define_shape
            # 3: x
            # 4: place_object
            # 5: remove_object
            # 6: define_bits
            # 7: define_button
            # 8: jpeg_tables
            9: background_color
            # 10: define_font
            # 11: define_text
            # 12: do_action
            # 13: define_font_info
            # 14: define_sound
            # 15: start_sound
            # 16: x
            # 17: define_button_sound
            # 18: sound_stream_head
            # 19: sound_stream_block
            # 20: define_bits_lossless

            69: file_attributes
            75: define_font_3
            77: metadata
    instances:
      code:
        value: tag_code_and_length >> 6
      short_length:
        value: tag_code_and_length & 0b111111
      length: 
        value: short_length == 0x3f ? long_length : short_length
  define_font_3:
    seq:
      - id: font_id
        type: u2
      - id: font_flags_has_layout
        type: b1
      - id: font_flags_shift_jis
        type: b1
      - id: font_flags_small_text
        type: b1
      - id: font_flags_ansi
        type: b1
      - id: font_flags_wide_offsets
        type: b1
      - id: font_flags_wide_codes
        type: b1
      - id: font_flags_italic
        type: b1
      - id: font_flags_bold
        type: b1
      - id: language_code
        type: lang_code
      - id: font_name_len
        type: u1
      - id: font_name
        type: str
        size: font_name_len
      # bored now
  lang_code:
    seq:
      - id: language_code
        type: u1
        enum: language
    enums:
      language:
        1: latin
        2: japanese
        3: korean
        4: chinese_simplified
        5: chinese_traditional
  background_color:
    seq:
      - id: color
        type: rgb
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
  metadata:
    seq:
     - id: xml
       type: str
       terminator: 0
  file_attributes:
    seq:
      - id: reserved
        type: b1
      - id: use_direct_blit
        type: b1
      - id: use_gpu
        type: b1
      - id: has_metadata
        type: b1
      - id: action_script_3
        type: b1
      - id: reserved2
        type: b2
      - id: use_network
        type: b1
      - id: reserved3
        type: b24
  rect:
    seq:
      - id: nbits
        type: b5
        #contents: [16]
        # FIXME: This field should specify how many bits each of the following
        # fields use.  I can't see a way to do this in kaitai
      - id: xmin
        type: b16
      - id: xmax
        type: b16
      - id: ymin
        type: b16
      - id: ymax
        type: b16
