extends EditorInspectorPlugin

const InventoryInspector = preload("res://addons/gloot/editor/inventory_editor/inventory_inspector.tscn")
const ItemSlotInspector = preload("res://addons/gloot/editor/item_slot_editor/item_slot_inspector.tscn")
const ItemRefSlotButton = preload("res://addons/gloot/editor/item_slot_editor/item_ref_slot_button.gd")


func _can_handle(object: Object) -> bool:
    return (object is Inventory) || \
            (object is InventoryItem) || \
            (object is ItemSlot) || \
            (object is ItemRefSlot)


func _parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_inspector := InventoryInspector.instantiate()
        inventory_inspector.init(object as Inventory)
        add_custom_control(inventory_inspector)
    if object is ItemSlot:
        var item_slot_inspector := ItemSlotInspector.instantiate()
        item_slot_inspector.init(object as ItemSlot)
        add_custom_control(item_slot_inspector)


func _parse_property(object: Object,
        type: Variant.Type,
        name: String,
        hint: PropertyHint,
        hint_string: String,
        usage: int,
        wide: bool) -> bool:
    if (object is ItemRefSlot) && name == "_equipped_item":
        add_property_editor(name, ItemRefSlotButton.new())
        return true
    return false

