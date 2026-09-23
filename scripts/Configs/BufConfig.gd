class_name BufConfig extends Resource

## Format this as follows:[br]"mod_buf" = "og_shin"[br]
##Utilizing the same identifier as another buf will overwrite it.
@export var identifier: StringName = &""
## Card Name
@export var buf_name: StringName = &""
## Description
@export var buf_desc: StringName = &""

## Your custom buf Scene. Please inherit from the base Buf.tscn Scene.
@export var buf_scene: PackedScene = null

## This is a lie. All bufs use Stack, but setting this to false makes the number not show up.
@export var uses_stack: bool = true
@export var uses_count: bool = false
@export var expires_stackzero: bool = true
@export var expires_countzero: bool = false
