meta:
  id: smip
  file-extension: smip
  endian: le
  encoding: ascii
seq:
  - id: desc_count
    type: u2
  - id: smip_size
    type: u2
  - id: blocks
    type: top_blocks
    repeat: expr
    repeat-expr: desc_count
types:
  top_blocks:
    seq:
      - id: type
        type: u2
        enum: block_type
      - id: offset
        type: u2
      - id: length
        type: u2
      - id: reserved
        type: u2
    instances:
      body:
        pos: offset
        size: length
        type:
          switch-on: type
          cases:
            block_type::txe: txe_block
            block_type::pmc: pmc_block
    enums:
      block_type:
        0: txe
        1: pmc
        2: iafw
        3: unk
  
  pmc_block:
    # Unclear from docs, but this is chapter 12, I think.
    instances:
      mod_phy_lane_2:
        pos: 7
        type: u1
      mod_phy_lane_3:
        pos: 8
        type: u1
      mod_phy_lane_4:
        pos: 9
        type: u1
      mod_phy_lane_8:
        pos: 0xd
        type: u1
      tco_no_reboot:
        pos: 0xf
        type: u1
  txe_block:
    # chapter 11
    seq:
      - id: usb_descriptor
        size: 72
      - id: soft_straps
        size: 128
        type: soft_straps
      - id: reserved
        size: 5624
      - id: tpm_and_bootguard_oem_policy
        type: u4
      - id: reserved
        type: u2
  soft_straps:
    instances:
      punit:
        size: 4
        type: punit_straps
        pos: 0
      #spi_straps:
      #  type: u4
      #  repeat: expr
      #  repeat-expr: 7
      #  # replicates uplevel data.
      usbx:
        size: 4
        pos: 0x24
        type: usbx_straps
      exi:
        size: 4
        pos: 0x28
        type: exi_straps
      fia:
        size: 4
        pos: 0x2c
        type: fia_straps
      pcie_a:
        pos: 0x30
        type: u8
      pcie_b:
        pos: 0x38
        type: u8
      sata:
        pos: 0x40
        type: u4
      smbus:
        pos: 0x44
        type: u4
      ipc_spi:
        pos: 0x48
        type: u4
  fia_straps:
    seq:
      - id: raw
        type: u4
    instances:
      staggering_enable:
        value: (raw >> 2) & 1
      pcie_usb3_p0_strp:
        value: (raw >> 8) & 3
        enum: p012
      pcie_usb3_p1_strp:
        value: (raw >> 10) & 3
        enum: p012
      pcie_usb3_p2_strp:
        value: (raw >> 12) & 3
        enum: p012
      pcie_usb3_p3_strp:
        value: (raw >> 16) & 3
        enum: p3
    enums:
      p012:
        0: usb3
        1: pcie
      p3:
        0: usb3
        1: sata
  exi_straps:
    seq:
      - id: raw
        type: u4
  usbx_straps:
    seq:
      - id: raw
        type: u4
    instances:
      xhc_port1_ownership:
        value: (raw >> 0) & 1
      xhc_port2_ownership:
        value: (raw >> 1) & 1
      xhc_port3_ownership:
        value: (raw >> 2) & 1
      xhc_port4_ownership:
        value: (raw >> 3) & 1
      xhc_port5_ownership:
        value: (raw >> 4) & 1
      xhc_port6_ownership:
        value: (raw >> 5) & 1
      xhc_port7_ownership:
        value: (raw >> 6) & 1
        
      usb3_ssic_port1_strap:
        value: (raw >> 8) & 1
      usb3_ssic_port2_strap:
        value: (raw >> 9) & 1
      usb3_ssic_port3_strap:
        value: (raw >> 10) & 1
      usb3_ssic_port4_strap:
        value: (raw >> 11) & 1
      usb3_ssic_port5_strap:
        value: (raw >> 12) & 1
      usb3_ssic_port6_strap:
        value: (raw >> 13) & 1
      usb3_ssic_port7_strap:
        value: (raw >> 14) & 1

      
  punit_straps:
    seq:
      - id: raw
        type: u4
    instances:
      thermal_throttle_unlock:
        value: raw & (1<<22)
      extended_reliability_enable:
        value: raw & (1<<21)
      svid_rail0_valid:
        value: (raw >> 0) & 1
      svid_rail0_id:
        value: (raw >> 1) & (1<<5 - 1)
      svid_rail1_valid:
        value: (raw >> 5) & 1
      svid_rail1_id:
        value: (raw >> 6) & (1<<5 - 1)
      svid_rail2_valid:
        value: (raw >> 10) & 1
      svid_rail2_id:
        value: (raw >> 11) & (1<<5 - 1)
      svid_rail3_valid:
        value: (raw >> 15) & 1
      svid_rail3_id:
        value: (raw >> 16) & (1<<5 - 1)
