extends TestSuite

var inventory1: Inventory
var inventory2: Inventory
var item: InventoryItem


func init_suite():
    inventory1 = $Inventory1
    inventory2 = $Inventory2
    item = inventory1.get_item_by_id("minimal_item")

    tests = [
        "test_size",
        "test_has_item",
        "test_add_remove",
        "test_create_and_add",
        "test_transfer",
        "test_remove_item",
        "test_serialize",
        "test_serialize_json"
    ]


func init_test() -> void:
    clear_inventory(inventory1, [item])
    clear_inventory(inventory2, [item])
    inventory1.add_item(item)


func cleanup_suite() -> void:
    clear_inventory(inventory1)
    clear_inventory(inventory2)
    free_if_orphan(item)


func test_size() -> void:
    assert(inventory1.get_items().size() == 1)
    assert(inventory1.remove_item(item))
    assert(inventory1.get_items().size() == 0)


func test_add_remove() -> void:
    assert(inventory1.remove_item(item))
    assert(inventory1.get_items().size() == 0)
    assert(!inventory1.remove_item(item))

    assert(inventory1.add_item(item))
    assert(inventory1.get_items().size() == 1)
    assert(!inventory1.add_item(item))


func test_has_item() -> void:
    assert(inventory1.has_item_by_id("minimal_item"))
    assert(inventory1.has_item(item))
    assert(inventory1.remove_item(item))
    assert(!inventory1.has_item_by_id("minimal_item"))
    assert(!inventory1.has_item(item))


func test_create_and_add() -> void:
    var new_item = inventory2.create_and_add_item("minimal_item")
    assert(new_item)
    assert(inventory2.get_items().size() == 1)
    assert(inventory2.has_item(new_item))
    assert(inventory2.has_item_by_id("minimal_item"))


func test_transfer() -> void:
    assert(inventory1.transfer(item, inventory2))
    assert(!inventory1.has_item(item))
    assert(inventory2.has_item(item))


func test_remove_item() -> void:
    assert(inventory1.has_item(item))
    assert(inventory1.remove_item(item))
    assert(!inventory1.has_item(item))


func test_serialize() -> void:
    var inventory_data = inventory1.serialize()
    inventory1.reset()
    assert(inventory1.get_items().empty())
    assert(item.is_queued_for_deletion())
    assert(inventory1.deserialize(inventory_data))
    assert(inventory1.get_items().size() == 1)


func test_serialize_json() -> void:
    var inventory_data = inventory1.serialize()

    # To and from JSON serialization
    var json_string = JSON.print(inventory_data)
    var res: JSONParseResult = JSON.parse(json_string)
    assert(res.error == OK)
    inventory_data = res.result

    inventory1.reset()
    assert(inventory1.get_items().empty())
    assert(item.is_queued_for_deletion())
    assert(inventory1.deserialize(inventory_data))
    assert(inventory1.get_items().size() == 1)
