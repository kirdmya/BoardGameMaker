# Документация для разработчиков Boardgame Maker

## Оглавление

1. [Введение](#введение)
2. [Архитектура и структура проекта](#архитектура-и-структура-проекта)
3. [Добавление и использование UI-компонентов](#добавление-и-использование-ui-компонентов)

   * [Button](#button)
   * [Checkbox](#checkbox)
   * [Slider](#slider)
   * [Dropdown](#dropdown)
   * [TextInput](#textinput)
   * [ColorPicker](#colorpicker)
   * [RadioButton](#radiobutton)
   * [ListView](#listview)
   * [Tabbar](#tabbar)
   * [Tooltip](#tooltip)
   * [NumberInput](#numberinput)
   * [ProgressBar](#progressbar)
4. [Тестирование компонентов и движка](#тестирование-компонентов-и-движка)
5. [Добавление и организация игровых сцен](#добавление-и-организация-игровых-сцен)
6. [Создание новой игры](#создание-новой-игры)
7. [Работа с ассетами](#работа-с-ассетами)
8. [Локализация](#локализация)
9. [Рекомендации по стилю кода](#рекомендации-по-стилю-кода)
10. [CI, Pull Request и вклад в проект](#ci-pull-request-и-вклад-в-проект)

---

## Введение

Boardgame Maker — это кроссплатформенное open-source приложение на **Lua** с использованием **LOVE2D**, предназначенное для проектирования и прототипирования настольных игр, а также разработки собственных UI-компонентов, игровых механик и модулей.

---

## Архитектура и структура проекта

* **main.lua** — точка входа, инициализация приложения, сцен и настроек.
* **core/** — сущности игрового движка (карта, колода, кубик, игрок и др.), правила и обработчики событий.
* **ui/** — реализация интерфейсных компонентов (кнопки, чекбоксы, слайдеры и др.).
* **assets/** — изображения, звуковые файлы, шрифты.
* **scenes/** — игровые сцены: меню, игры, песочница UI и тестовые экраны.
* **locales/** — языковые пакеты (ru.lua, en.lua, ...).
* **utils/** — вспомогательные утилиты (логгер, менеджер сцен и др.).

---

## Добавление и использование UI-компонентов

Все компоненты располагаются в папке `ui/`. Любой UI-компонент — это Lua-модуль, реализующий методы **new**, **draw**, **update** и обработку событий (mousepressed, mousereleased и др.).

### Button

```lua
local Button = require("ui.button")
local btn = Button.new("Click me", 100, 100, 200, 60, function()
    print("Clicked")
end)
btn:update(dt)
btn:draw()
btn:mousepressed(x, y, button)
btn:mousereleased(x, y, button)
```

### Checkbox

```lua
local Checkbox = require("ui.checkbox")
local cb = Checkbox.new(120, 200, 36, "Enable", false, function(checked)
    print("Checked:", checked)
end)
```

### Slider

```lua
local Slider = require("ui.slider")
local slider = Slider.new(60, 300, 240, 36, 50, function(val)
    print("Changed:", val)
end)
```

### Dropdown

```lua
local Dropdown = require("ui.dropdown")
local dropdown = Dropdown.new(50, 50, 180, 42, {"EN", "RU"}, 1)
dropdown:setOnChange(function(val, idx) print("Selected:", val) end)
```

### TextInput

```lua
local TextInput = require("ui.textinput")
local input = TextInput.new(120, 420, 240, "Enter name")
```

### ColorPicker

```lua
local ColorPicker = require("ui.colorpicker")
local picker = ColorPicker.new(360, 260, 240, 32, {1, 0, 0, 1}, function(r, g, b, a)
    print("Color:", r, g, b, a)
end)
```

### RadioButton

```lua
local RadioButton = require("ui.radiobutton")
local radio = RadioButton.new(100, 100, {"Easy", "Medium", "Hard"}, 2, function(selected)
    print("Mode:", selected)
end)
```

### ListView

```lua
local ListView = require("ui.listview")
local list = ListView.new(50, 100, 300, 200, {"Item 1", "Item 2"})
```

### Tabbar

```lua
local Tabbar = require("ui.tabbar")
local tabbar = Tabbar.new(0, 0, 400, 40, {"Overview", "Settings"}, 1, function(idx)
    print("Switched tab:", idx)
end)
```

### Tooltip

```lua
local Tooltip = require("ui.tooltip")
Tooltip.set("Hover to see info", 1)
Tooltip.draw(x, y)
```

### NumberInput

```lua
local NumberInput = require("ui.number_input")
local input = NumberInput.new(100, 100, 180, 0, 0, 100, function(val)
    print("Value:", val)
end)
```

### ProgressBar

```lua
local ProgressBar = require("ui.progressbar")
local bar = ProgressBar.new(100, 200, 300, 20, 0.5)
bar:draw()
```

---

## Добавление новых сущностей в движок

* Все сущности расположены в `core/entities`
* Любое добавление сущности обрабатывается через основное ядро `core/core_engine.lua`
* Примеры реализации представлены в тестах


## Тестирование компонентов и движка

* Все UI-компоненты имеют сцены-примеры в `scenes/devui/`
* Движок и сущности тестируются в `scenes/devcore/` и `scenes/deventity/`
* Используйте `devmode.lua` → `devui_components.lua` / `deventity_list.lua`

### Добавить свой тест:

1. Создайте файл в `scenes/devui/mycomponent.lua`
2. Реализуйте методы `load`, `draw`, `update`, `mousepressed`, `keypressed`
3. Добавьте компонент в список в `devui_components.lua`

---

## Добавление и организация игровых сцен

* Каждая игра — это файл в `scenes/games/`
* Пример: `twentyone.lua`, `memory.lua`
* Сцена должна реализовывать `load`, `update`, `draw`, `mousepressed`, `keypressed`
* Подключается через `game_list.lua`

---

## Создание новой игры

1. Создайте файл `scenes/games/mygame.lua`
2. Используйте компоненты движка: `core.entities.card`, `deck`, `player` и т.д.
3. Отрисовывайте интерфейс с помощью UI-компонентов
4. Добавьте название и сцену в `game_list.lua`

---

## Работа с ассетами

* **Карты**: `assets/entities/cards/` (128x128 PNG)
* **UI**: `assets/ui/Color/Variant/*.png`
* **Звуки**: `assets/sounds/`
* **Шрифты**: `assets/fonts/`

> Добавьте ассет — он автоматически подгрузится через `assets.lua`

---

## Локализация

* Все строки через `locales/` и `I18N.t("key")`
* Добавьте ключ в `ru.lua` и `en.lua`
* Смена языка: `Settings.language = "en"`

---

## Рекомендации по стилю кода

* Используйте `snake_case` для переменных, `PascalCase` для классов
* Разделяйте `load`, `update`, `draw` и события
* Каждый модуль должен возвращать объект (или таблицу)
* Не используйте глобальные переменные (кроме `AppMode`, если необходимо)

---

## CI, Pull Request и вклад в проект

* **CI** не используется, но вы можете запускать локально `love .`
* Все тесты можно открыть из меню DevMode
* Пулл-реквесты принимаются при соблюдении структуры, локализации и документации

---

