@tool
class_name  CtrlInventoryUniversal
extends VBoxContainer

# TODO: Consider renaming to item_activated
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)

@export var inventory: Inventory = null :
    set(new_inventory):
        if inventory == new_inventory:
            return
        disconnect_inventory_signals()
        inventory = new_inventory
        connect_inventory_signals()
        _refresh()

var _inventory_control: Control = null
var _capacity_control: CtrlInventoryCapacity = null


func connect_inventory_signals():
    if !inventory:
        return

    inventory.prototree_json_changed.connect(_refresh)
    inventory.constraint_changed.connect(_on_constraint_changed)
    inventory.constraint_added.connect(_on_constraint_changed)
    inventory.constraint_removed.connect(_on_constraint_changed)

    if !inventory.prototree_json:
        return
    inventory.prototree_json.changed.connect(_refresh)


func disconnect_inventory_signals():
    if !inventory:
        return
        
    inventory.prototree_json_changed.disconnect(_refresh)
    inventory.constraint_changed.disconnect(_on_constraint_changed)
    inventory.constraint_added.disconnect(_on_constraint_changed)
    inventory.constraint_removed.disconnect(_on_constraint_changed)

    if !inventory.prototree_json:
        return
    inventory.prototree_json.changed.disconnect(_refresh)


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    _refresh()


func _ready() -> void:
    _refresh()


func _refresh() -> void:
    if is_instance_valid(_inventory_control):
        _inventory_control.queue_free()
        _inventory_control = null
    if is_instance_valid(_capacity_control):
        _capacity_control.queue_free()
        _capacity_control = null

    if !is_instance_valid(inventory):
        return

    if inventory.get_constraint(GridConstraint) != null:
        _inventory_control = CtrlInventoryGrid.new()
    else:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    _inventory_control.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _inventory_control.inventory_item_context_activated.connect(func(item: InventoryItem):
        inventory_item_context_activated.emit(item)
    )
    if inventory.get_constraint(WeightConstraint) != null:
        _capacity_control = CtrlInventoryCapacity.new()
        _capacity_control.inventory = inventory

    if is_instance_valid(_inventory_control):
        add_child(_inventory_control)
    if is_instance_valid(_capacity_control):
        add_child(_capacity_control)


func get_selected_inventory_item() -> InventoryItem:
    assert(is_instance_valid(_inventory_control))
    return _inventory_control.get_selected_inventory_item()


func get_selected_inventory_items() -> Array[InventoryItem]:
    assert(is_instance_valid(_inventory_control))
    return _inventory_control.get_selected_inventory_items()
