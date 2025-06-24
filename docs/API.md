# API


## Структура API

Все компоненты системы разбиты на следующие логические группы:

* `core/` — сущности и игровой движок
* `ui/` — визуальные элементы
* `scenes/` — игровые и вспомогательные сцены
* `utils/` — вспомогательные утилиты (логгер, менеджер сцен)

### `core_engine`

```lua
-- Создание сущности
core_engine.create_player(name)
core_engine.create_deck(name)
core_engine.create_zone(name)
-- Поиск
core_engine.find("player", function(p) return p.name == "Alex" end)
-- Сброс
core_engine.reset()
-- Подписка на событие
core_engine.on("draw", function(data) ... end)
-- Испускание события
core_engine.emit("draw", { player = ..., card = ... })
-- Сериализация / десериализация
core_engine.serialize()
core_engine.deserialize(data)
```

### Сущности

#### `Card`

```lua
Card.new(suit, rank, props)
card:flip()
card:get_sprite_name()
card:serialize()
Card.from_table(tbl)
```

#### `Deck`

```lua
deck:add(card)
deck:shuffle()
deck:draw()
deck:serialize()
Deck.from_table(tbl)
```

#### `Dice`

```lua
dice:roll()
dice:get_value()
dice:get_sprite_path()
dice:serialize()
Dice.from_table(tbl)
```

---

## UI-компоненты

Каждый компонент расположен в папке `ui/` и реализует интерфейс с методами:

* `:draw()` — отрисовка
* `:update(dt)` — логика
* `:mousepressed(x, y, button)` / `:mousereleased(...)`
* `:keypressed(key)` (если нужно)

### Примеры

#### `Button`

```lua
Button.new("Нажми", x, y, w, h, function() print("Clicked") end)
```

#### `Checkbox`

```lua
Checkbox.new(x, y, size, "Лейбл", true, function(val) print(val) end)
```

#### `Dropdown`

```lua
Dropdown.new(x, y, w, h, {"Easy", "Medium", "Hard"}, 2)
dropdown:setOnChange(function(value, index) ... end)
```

---

## Тестирование

### Структура

Тесты располагаются в папке `scenes/devui/` (UI) и `scenes/deventity/` (движок). Для каждого компонента создаётся отдельная сцена.

### Создание теста

1. Создайте файл `scenes/devui/название.lua`
2. Подключите нужный компонент
3. Реализуйте логику:

   * `.load()` — инициализация
   * `.update(dt)`, `.draw()` — основной цикл
   * `.mousepressed(...)` / `.mousereleased(...)`

```lua
-- scenes/devui/button.lua
local Button = require("ui.button")
local scene = {}
function scene.load()
  btn = Button.new("Тест", 100, 100, 200, 50, function() print("OK") end)
end
function scene.draw() btn:draw() end
function scene.mousepressed(x, y, b) btn:mousepressed(x, y, b) end
return scene
```

### Автоматическое тестирование

Планируется подключение модульного Lua-фреймворка (например, `busted` или `luassert`).

Пример:

```lua
describe("Card", function()
  it("should flip state", function()
    local card = Card.new("spades", "A")
    assert.is_false(card:is_face_up())
    card:flip()
    assert.is_true(card:is_face_up())
  end)
end)
```

---

## Расширение API

Для добавления новой сущности:

1. Создайте файл в `core/entities/` с методом `.new()` и `.serialize()`
2. Добавьте сущность в `core_engine.lua`
3. Создайте тест-сцену в `scenes/deventity/`

---

## Поддерживаемые события

* `draw` — взятие карты
* `roll` — бросок кубика
* `custom` — пользовательские

Каждое событие может быть подписано через:

```lua
core_engine.on("event_name", function(data) ... end)
```

---

