class_name EditingScene
extends Node2D

var open_session_data : SessionData
var _list_of_elements_in_session: ItemList
var _edit_element_root_container: Container
var _edit_element_grid_container: Container
var _subliminal_messages_editor: TextEdit
var _currently_editing_element: SessionElement
var _currently_editing_index: int

var SubliminalClass = preload("res://Scripts/SessionElement_Subliminal.gd")

func _ready():
	_list_of_elements_in_session = $CanvasLayer/ListOfElementsInSession
	_edit_element_root_container = $CanvasLayer/EditElementRootContainer
	_edit_element_grid_container = $CanvasLayer/EditElementRootContainer/EditElementGridContainer


func refresh():
	_list_of_elements_in_session.clear()
	_populate_edit_container_for_element(null)
	
	if open_session_data != null:
		for element in open_session_data._elements:
			_add_element_to_display_list(element)


func set_visibility(in_is_visible: bool):
	show()
	$CanvasLayer.visible = in_is_visible


func _on_add_subliminal_button_pressed() -> void:
	var new_element: SessionElement_Subliminal = SubliminalClass.new()
	open_session_data.assign_unique_default_display_name_to_element(new_element)
	open_session_data.add_element(new_element)
	_add_element_to_display_list(new_element)


func _on_back_to_menu_button_pressed() -> void:
	hide()


func _add_element_to_display_list(new_element: SessionElement) -> void:
	_list_of_elements_in_session.add_item(new_element.get_display_name())


func _on_list_of_elements_in_session_item_selected(index: int) -> void:
	_currently_editing_index = index
	var selected_display_name: String = _list_of_elements_in_session.get_item_text(index)
	var selected_element: SessionElement = open_session_data.get_element_by_display_name(selected_display_name)
	_populate_edit_container_for_element(selected_element)


func _populate_edit_container_for_element(element: SessionElement) -> void:
	if _currently_editing_element != null:
		_currently_editing_element.on_display_name_changed.disconnect(_handle_currently_editing_element_display_name_changed)
		
	for child in _edit_element_grid_container.get_children():
		_edit_element_grid_container.remove_child(child)
		
	for child in _edit_element_root_container.get_children():
		if child != _edit_element_grid_container:
			_edit_element_root_container.remove_child(child)
	
	_currently_editing_element = element
	if _currently_editing_element == null:
		return
		
	_currently_editing_element.on_display_name_changed.connect(_handle_currently_editing_element_display_name_changed)
	
	_add_string_prop_to_edit_container("Name:", element.get_display_name_ref())
	_add_float_prop_to_edit_container("Start Time:", element.get_start_time_ref())
	_add_float_prop_to_edit_container("End Time:", element.get_end_time_ref())
	
	if _currently_editing_element is SessionElement_Subliminal:
		_add_float_prop_to_edit_container("Time Per Message:", element.get_time_per_message_ref())
		
		_subliminal_messages_editor = TextEdit.new()
		var text: String = ""
		for message in _currently_editing_element._messages:
			text = text + message + "\n"
		_subliminal_messages_editor.text = text
		_subliminal_messages_editor.custom_minimum_size.x = 256
		_subliminal_messages_editor.custom_minimum_size.y = 256
		_subliminal_messages_editor.size_flags_horizontal = 0
		_subliminal_messages_editor.text_changed.connect(_handle_subliminal_messages_editor_text_changed)
		_edit_element_root_container.add_child(_subliminal_messages_editor)
	
	var delete_button: Button = Button.new()
	delete_button.text = "Delete Element"
	delete_button.pressed.connect(_handle_delete_element_button_pressed)
	_edit_element_root_container.add_child(delete_button)
	

func _add_label_to_edit_container(text: String) -> void:
	var new_label: Label = Label.new()
	new_label.text = text;
	_edit_element_grid_container.add_child(new_label)

	
func _add_float_prop_to_edit_container(label_text: String, prop_ref: FloatObj) -> void:
	_add_label_to_edit_container(label_text)
	var new_float_entry: FloatPropLineEdit = FloatPropLineEdit.new()
	new_float_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_float_entry.set_property_reference(prop_ref)
	_edit_element_grid_container.add_child(new_float_entry)

	
func _add_string_prop_to_edit_container(label_text: String, prop_ref: StringObj) -> void:
	_add_label_to_edit_container(label_text)
	var new_string_entry: StringPropLineEdit = StringPropLineEdit.new()
	new_string_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_string_entry.set_property_reference(prop_ref)
	_edit_element_grid_container.add_child(new_string_entry)
	
	
func _handle_currently_editing_element_display_name_changed(_old_name: String, _new_name: String) -> void:
	open_session_data.update_display_name_of_element_to_be_unique(_currently_editing_element)
	_list_of_elements_in_session.set_item_text(_currently_editing_index, _currently_editing_element._display_name.get_value())

func _handle_subliminal_messages_editor_text_changed():
	var packed: PackedStringArray = _subliminal_messages_editor.text.split("\n", false)
	var current_subliminal: SessionElement_Subliminal = _currently_editing_element
	current_subliminal._messages.clear()
	for packed_message: String in packed:
		current_subliminal._messages.append(packed_message)
		
func _handle_delete_element_button_pressed():
	open_session_data.delete_element(_currently_editing_element)
	refresh()
