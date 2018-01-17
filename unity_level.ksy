meta:
  id: unity_level
  file-extension: unity_level
  endian: le
seq:
  - id: header
    type: header
    size: 0x14
  - id: metadata
    type: metadata0
types:
  data_item_shader:
    seq:
      - id: name
        type: str_pascal_4_1
      - id: text_asset
        type: str_pascal_4_1
      - id: decompressed_size
        type: u4
  str_pascal_4_1:
    seq:
      - id: len
        type: u4
      - id: data
        type: str
        size: len
        encoding: ASCII
  header:
    # type SerializedFileHeader
    seq:
      - id: metadata_size
        type: u4be
      - id: file_size
        type: u4be
      - id: version
        type: u4be
      - id: data_offset
        type: u4be
      - id: endianness
        # 0: le (which this ksy requires)
        type: u1
      - id: reserved
        size: 3
        contents: [0, 0, 0]
  metadata0:
    # char __thiscall SerializedFile::ReadMetadata<0>(SerializedFile *this, int version, unsigned int dataOffset, const char *data, unsigned int length, unsigned int dataFileEnd)
    seq:
      - id: unity_version
        encoding: ascii
        type: str
        terminator: 0
        # version >= 7
      - id: target_platform
        type: u4
        # version >= 8
      # if version < 13
      - id: enable_type_tree
        type: u1
      - id: type_info_count
        type: u4
      - id: type_info_records
        type: type_info_record
        repeat: expr
        repeat-expr: type_info_count
      # Skip a dword if version <= 13?
      - id: another_count
        type: u4
      - id: another_records
        type: another
        repeat: expr
        repeat-expr: another_count
  another:
    seq:
      - id: padding
        size: 4 - _io.pos & 3
      - id: index
        type: u8
      - id: offset_into_data
        type: u4
      - id: data_length
        type: u4
      - id: data_type
        type: s4
        enum: classid
      - id: script_type_index
        type: u2
      - id: pad
        type: u2
      - id: stripped
        type: u1
    instances:
      data:
        size: data_length
        pos: offset_into_data + _root.header.data_offset
        type:
          switch-on: data_type
          cases:
            classid::class_material: data_item_shader
            classid::class_game_object: data_item_game_object
            classid::class_transform: data_item_transform
            _: data_item_generic
  data_item_generic:
    seq:
      - id: raw
        size: _parent.data_length
  data_item_game_object:
    seq:
      # EditorExtension has no transfer / is abstract.
      #- id: parent
      #  type: data_item_editor_extension
      - id: a
        type: u4
      #- id: b
      #  type: u4
      #  repeat: expr
      #  # a==1?5: a==2?9:  a==3?13:  a==4?17: 0
      #  repeat-expr: 1 + a * 4
      #- id: name
      #  type: str_pascal_4_1
  data_item_transform:
    seq:
      - id: a
        type: f4
        repeat: expr
        # Hmm, 18 = 2 + 4*4 matrix?
        repeat-expr: 18
  type_info_record:
    seq:
      - id: type_id
        type: s4
      # SerializedFile::Type::ReadType<0>
      - id: script_id_hash_data
        size: 4*4
        if: type_id < 0
      # always
      - id: old_type_hash_hash_data
        size: 4*4
      # more fields if enableTypeTree
enums:
  classid:
    0xffffffff: class_undefined
    0x0: class_object
    0x1: class_game_object
    0x2: class_component
    0x3: class_level_game_manager
    0x4: class_transform
    0x5: class_time_manager
    0x6: class_global_game_manager
    0x8: class_behaviour
    0x9: class_game_manager
    0xb: class_audio_manager
    0xc: class_particle_animator
    0xd: class_input_manager
    0xf: class_ellipsoid_particle_emitter
    0x11: class_pipeline
    0x12: class_editor_extension
    0x13: class_physics2d_settings
    0x14: class_camera
    0x15: class_material
    0x17: class_mesh_renderer
    0x19: class_renderer
    0x1a: class_particle_renderer
    0x1b: class_texture
    0x1c: class_texture_2d
    0x1d: class_scene_settings
    0x1e: class_graphics_settings
    0x21: class_mesh_filter
    0x29: class_occlusion_portal
    0x2b: class_mesh
    0x2d: class_skybox
    0x2f: class_quality_settings
    0x30: class_shader
    0x31: class_text_asset
    0x32: class_rigidbody_2d
    0x33: class_physics_2d_manager
    0x35: class_collider_2d
    0x36: class_rigidbody
    0x37: class_physics_manager
    0x38: class_collider
    0x39: class_joint
    0x3a: class_circle_collider_2d
    0x3b: class_hinge_joint
    0x3c: class_polygon_collider_2d
    0x3d: class_box_collider_2d
    0x3e: class_physics_material_2d
    0x40: class_mesh_collider
    0x41: class_box_collider
    0x42: class_sprite_collider_2d
    0x44: class_edge_collider_2d
    0x48: class_compute_shader
    0x4a: class_animation_clip
    0x4b: class_constant_force
    0x4c: class_world_particle_collider
    0x4e: class_tag_manager
    0x51: class_audio_listener
    0x52: class_audio_source
    0x53: class_audio_clip
    0x54: class_render_texture
    0x57: class_mesh_particle_emitter
    0x58: class_particle_emitter
    0x59: class_cubemap
    0x5a: class_avatar
    0x5b: class_animator_controller
    0x5c: class_guilayer
    0x5d: class_runtime_animator_controller
    0x5e: class_script_mapper
    0x5f: class_animator
    0x60: class_trail_renderer
    0x62: class_delayed_call_manager
    0x66: class_text_mesh
    0x68: class_render_settings
    0x6c: class_light
    0x6d: class_cg_program
    0x6e: class_base_animation_track
    0x6f: class_animation
    0x72: class_mono_behaviour
    0x73: class_mono_script
    0x74: class_mono_manager
    0x75: class_texture_3d
    0x76: class_new_animation_track
    0x77: class_projector
    0x78: class_line_renderer
    0x79: class_flare
    0x7a: class_halo
    0x7b: class_lens_flare
    0x7c: class_flare_layer
    0x7d: class_halo_layer
    0x7e: class_nav_mesh_areas
    0x80: class_font
    0x81: class_player_settings
    0x82: class_named_object
    0x83: class_gui_texture
    0x84: class_gui_text
    0x85: class_gui_element
    0x86: class_physic_material
    0x87: class_sphere_collider
    0x88: class_capsule_collider
    0x89: class_skinned_mesh_renderer
    0x8a: class_fixed_joint
    0x8c: class_raycast_collider
    0x8d: class_build_settings
    0x8e: class_asset_bundle
    0x8f: class_character_controller
    0x90: class_character_joint
    0x91: class_spring_joint
    0x92: class_wheel_collider
    0x93: class_resource_manager
    0x94: class_network_view
    0x95: class_network_manager
    0x96: class_preload_data
    0x98: class_movie_texture
    0x99: class_configurable_joint
    0x9a: class_terrain_collider
    0x9b: class_master_server_interface
    0x9c: class_terrain_data
    0x9d: class_lightmap_settings
    0x9e: class_web_cam_texture
    0x9f: class_editor_settings
    0xa0: class_interactive_cloth
    0xa1: class_cloth_renderer
    0xa2: class_editor_user_settings
    0xa3: class_skinned_cloth
    0xa4: class_audio_reverb_filter
    0xa5: class_audio_high_pass_filter
    0xa6: class_audio_chorus_filter
    0xa7: class_audio_reverb_zone
    0xa8: class_audio_echo_filter
    0xa9: class_audio_low_pass_filter
    0xaa: class_audio_distortion_filter
    0xab: class_sparse_texture
    0xb4: class_audio_behaviour
    0xb5: class_audio_filter
    0xb6: class_wind_zone
    0xb7: class_cloth
    0xb8: class_substance_archive
    0xb9: class_procedural_material
    0xba: class_procedural_texture
    0xbf: class_off_mesh_link
    0xc0: class_occlusion_area
    0xc1: class_tree
    0xc3: class_nav_mesh_agent
    0xc4: class_nav_mesh_settings
    0xc6: class_particle_system
    0xc7: class_particle_system_renderer
    0xc8: class_shader_variant_collection
    0xcd: class_lod_group
    0xce: class_blend_tree
    0xcf: class_motion
    0xd0: class_nav_mesh_obstacle
    0xda: class_terrain
    0xd4: class_sprite_renderer
    0xd5: class_sprite
    0xd6: class_cached_sprite_atlas
    0xd7: class_reflection_probe
    0xd8: class_reflection_probes
    0xdc: class_light_probe_group
    0xdd: class_animator_override_controller
    0xde: class_canvas_renderer
    0xdf: class_canvas
    0xe0: class_rect_transform
    0xe1: class_canvas_group
    0xe2: class_billboard_asset
    0xe3: class_billboard_renderer
    0xe4: class_speed_tree_wind_asset
    0xe5: class_anchored_joint_2d
    0xe6: class_joint_2d
    0xe7: class_spring_joint_2d
    0xe8: class_distance_joint_2d
    0xe9: class_hinge_joint_2d
    0xea: class_slider_joint_2d
    0xeb: class_wheel_joint_2d
    0xec: class_cluster_input_manager
    0xed: class_base_video_texture
    0xee: class_nav_mesh_data
    0xf0: class_audio_mixer
    0xf1: class_audio_mixer_controller
    0xf3: class_audio_mixer_group_controller
    0xf4: class_audio_mixer_effect_controller
    0xf5: class_audio_mixer_snapshot_controller
    0xf6: class_physics_update_behaviour_2d
    0xf7: class_constant_force_2d
    0xf8: class_effector_2d
    0xf9: class_area_effector_2d
    0xfa: class_point_effector_2d
    0xfb: class_platform_effector_2d
    0xfc: class_surface_effector_2d
    0xfd: class_buoyancy_effector_2d
    0xfe: class_relative_joint_2d
    0xff: class_fixed_joint_2d
    0x100: class_friction_joint_2d
    0x101: class_target_joint_2d
    0x102: class_light_probes
    0x10f: class_sample_clip
    0x110: class_audio_mixer_snapshot
    0x111: class_audio_mixer_group
    0x118: class_n_screen_bridge
    0x122: class_asset_bundle_manifest
    0x12c: class_localization_database
    0x124: class_unity_ads_settings
    0x12c: class_runtime_initialize_on_load_manager
    0x12d: class_cloud_web_services_manager
    0x12f: class_unity_analytics_manager
    0x136: class_unity_connect_settings
    0x140: class_director_player
    0x143: class_audio_player
    0x144: class_batched_sprite_renderer
    0x145: class_sprite_data_provider
    0x146: class_smart_sprite
    0x147: k_largest_runtime_class_id
    0x3e8: class_smallest_editor_class_id
    0x3e9: class_prefab
    0x3ea: class_editor_extension_impl
    0x3eb: class_asset_importer
    0x3ec: class_asset_database
    0x3ed: class_mesh3dsimporter
    0x3ee: class_texture_importer
    0x3ef: class_shader_importer
    0x3f0: class_compute_shader_importer
    0x3f3: class_avatar_mask
    0x3fc: class_audio_importer
    0x402: class_hierarchy_state
    0x404: class_asset_meta_data
    0x405: class_default_asset
    0x406: class_default_importer
    0x407: class_text_script_importer
    0x408: class_scene_asset
    0x40a: class_native_format_importer
    0x40b: class_mono_importer
    0x40d: class_asset_server_cache
    0x40e: class_library_asset_importer
    0x410: class_model_importer
    0x411: class_fbximporter
    0x412: class_true_type_font_importer
    0x414: class_movie_importer
    0x415: class_editor_build_settings
    0x416: class_ddsimporter
    0x418: class_inspector_expanded_state
    0x419: class_annotation_manager
    0x41a: class_plugin_importer
    0x41b: class_editor_user_build_settings
    0x41c: class_pvrimporter
    0x41d: class_astcimporter
    0x41e: class_ktximporter
    0x44d: class_animator_state_transition
    0x44e: class_animator_state
    0x451: class_human_template
    0x453: class_animator_state_machine
    0x454: class_preview_asset_type
    0x455: class_animator_transition
    0x456: class_speed_tree_importer
    0x457: class_animator_transition_base
    0x458: class_substance_importer
    0x459: class_lightmap_parameters
    0x460: class_lighting_data_asset
    0x461: class_gisraster
    0x462: class_gisraster_importer
    0x463: class_cad_importer
    0x464: class_sketch_up_importer
    0x465: k_largest_editor_class_id
    0x186a0: k_class_id_out_of_hierarchy
    0x186a0: class_int
    0x186a1: class_bool
    0x186a2: class_float
    0x186a3: class_mono_object
    0x186a4: class_collision
    0x186a5: class_vector3f
    0x186a6: class_root_motion_data
    0x186a7: class_collision_2d
    0x186a8: class_audio_mixer_live_update_float
    0x186a9: class_audio_mixer_live_update_bool
    0x186aa: class_polygon_2d
