# Demo_AHK

Ready-to-use AutoHotkey v1 project template with CoreLibsFor_AHK already integrated.

Готовый шаблон проекта для AutoHotkey v1 с уже подключенной библиотекой CoreLibsFor_AHK.

> ⚠️ **Project Status**
>
> This repository is intended as a starting point for new AutoHotkey projects.
> It already contains the required project structure and integration with CoreLibsFor_AHK, allowing development to begin immediately.
>
> ---
>
> ⚠️ **Статус проекта**
>
> Этот репозиторий предназначен в качестве стартового шаблона для новых проектов на AutoHotkey.
> В нем уже присутствует необходимая структура проекта и подключена библиотека CoreLibsFor_AHK, поэтому разработку можно начинать сразу после скачивания.

🌐 **Language / Язык**

* 🇷🇺 [Русский](#русский)
* 🇺🇸 [English](#english)

---

# Русский

## О проекте

`Demo_AHK` — это готовый шаблон проекта с уже подключенной библиотекой `CoreLibsFor_AHK`.

Основная цель репозитория — избавить пользователя от необходимости вручную подключать библиотеку, настраивать структуру папок и создавать стартовую конфигурацию проекта.

После скачивания можно сразу приступать к написанию собственного кода.

## Поддерживаемая версия AutoHotkey

Проект рассчитан на:

**AutoHotkey v1**

Совместимость с AutoHotkey v2 не гарантируется.

## Связанный проект

Этот шаблон использует библиотеку `CoreLibsFor_AHK`.

Репозиторий библиотеки:

https://github.com/YagamiKlait3579/CoreLibsFor_AHK

Если вас интересует внутренняя реализация функций, классов и компонентов фреймворка, рекомендуется ознакомиться с этим репозиторием.

## Основной файл

В корневой папке находится файл:

```text
Start.ahk
```

Это пример стартового скрипта с базовой заготовкой для дальнейшей разработки.

Вы можете изменять его любым образом, использовать как основу для собственного проекта или создавать дополнительные основные скрипты.

Количество основных скриптов в проекте не ограничено.

Главное — сохранить подключение библиотеки:

```ahk
#include %A_ScriptDir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
```

Именно через этот файл выполняется подключение CoreLibsFor_AHK.

## Автоматически загружаемые файлы

Библиотека может автоматически загружать несколько дополнительных файлов, предназначенных для хранения настроек и общих функций проекта.

Шаблоны этих файлов находятся в:

```text
libs\CoreLibsFor_AHK\Templates
```

### Settings.ahk

Используется для общих настроек проекта, которые должны применяться независимо от того, какой основной скрипт запускается.

Обычно данный файл располагается рядом с основными скриптами проекта, чтобы его было удобно редактировать.

При необходимости он также может находиться внутри папки `libs`.

Для настроек, относящихся только к одному конкретному скрипту, обычно удобнее использовать переменные и параметры непосредственно внутри этого скрипта.

### AdvancedSettings.ahk

Предназначен для более специфических и редко изменяемых настроек.

Обычно этот файл размещают в папке `libs` и используют для параметров, которые в большинстве случаев не требуют изменения после первоначальной настройки проекта.

При необходимости он также может находиться рядом с основными скриптами.

### AdditionalFunctions.ahk

Предназначен для размещения собственных вспомогательных функций разработчика.

Если файл существует, библиотека автоматически загружает его при запуске.

Обычно сюда помещаются функции, которые должны быть доступны всем основным скриптам проекта.

Данный файл загружается только из папки `libs`.

## Быстрое редактирование через трей

Библиотека автоматически добавляет в меню трея команды для быстрого открытия:

* основного запущенного скрипта;
* `Settings.ahk`;
* `AdvancedSettings.ahk`.

Это позволяет быстро перейти к редактированию наиболее важных файлов проекта без необходимости искать их вручную в папках.

Если соответствующий файл отсутствует, пункт меню для него не отображается.

## Библиотеки и функции

Основные библиотеки находятся в директории:

```text
libs\CoreLibsFor_AHK\BaseLibs
```

Большинство функций содержат встроенные комментарии с описанием назначения, параметров и примерами использования.

Поскольку библиотека постоянно развивается и пополняется новыми возможностями, подробное описание всех функций в README не поддерживается.

Рекомендуется изучать комментарии непосредственно в исходном коде.

## Дополнительные инструменты

В состав `CoreLibsFor_AHK` также входят несколько вспомогательных инструментов, которые могут быть полезны при разработке AutoHotkey-скриптов.

Все эти инструменты доступны через меню трея запущенного скрипта в разделе **Other programs**.

При необходимости их также можно запускать напрямую. Исходные скрипты инструментов находятся в:

```text
CoreLibsFor_AHK\AuxiliaryScripts
```

### FindText

Инструмент для поиска изображений и текста на экране. Позволяет находить нужные элементы и получать их координаты для дальнейшего использования в скриптах.

`FindText` является сторонним проектом. Дополнительная информация и ссылки на оригинальный проект приведены в разделе [Используемые сторонние библиотеки](#используемые-сторонние-библиотеки).

### CoordinateConverter

Инструмент для работы с координатами внутри окон.

Позволяет преобразовать координаты элементов окна в относительные значения, которые можно использовать независимо от текущего размера окна. Это особенно полезно при работе с `PixelSearch` и другими функциями, использующими экранные координаты.

### KeyInfo

Небольшой инструмент для определения кодов клавиш `SC` (Scan Code) и `VK` (Virtual-Key Code).

Полученные значения можно использовать при настройке горячих клавиш и других параметров, связанных с клавиатурным вводом.

### WindowSpy

Стандартная утилита AutoHotkey для получения информации об окнах и элементах интерфейса.

С ее помощью можно быстро узнать, например, заголовок окна, имя процесса, класс окна, координаты и другую информацию, которая может потребоваться при написании скрипта.

## Используемые сторонние библиотеки

Хотя большая часть кода в составе CoreLibsFor_AHK написана мной, проект также использует некоторые сторонние библиотеки.

### FindText

Оригинальная тема автора:

https://www.autohotkey.com/boards/viewtopic.php?f=6&t=17834

Подробная инструкция по использованию:

https://www.autohotkey.com/boards/viewtopic.php?f=7&p=456845#p456845

### Gdip

Официальный репозиторий:

https://github.com/tariqporter/Gdip

---

# English

## About

`Demo_AHK` is a ready-to-use project template with `CoreLibsFor_AHK` already integrated.

The purpose of this repository is to eliminate the need for manual library integration, folder structure setup, and initial project configuration.

After downloading the repository, you can immediately start writing your own code.

## Supported AutoHotkey Version

This project is designed for:

**AutoHotkey v1**

Compatibility with AutoHotkey v2 is not guaranteed.

## Related Project

This template uses the `CoreLibsFor_AHK` library.

Library repository:

https://github.com/YagamiKlait3579/CoreLibsFor_AHK

If you are interested in the implementation details of the framework, its functions, classes, and components, please refer to that repository.

## Main Script

The root directory contains:

```text
Start.ahk
```

This file serves as a starting script and code template for future development.

You are free to modify it, use it as the basis of your own project, or create additional main scripts.

There is no limitation on the number of main scripts you can have within the project.

The only important requirement is keeping the library include:

```ahk
#include %A_ScriptDir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
```

This line is responsible for loading and initializing CoreLibsFor_AHK.

## Automatically Loaded Files

The library can automatically load several optional files intended for project configuration and shared functionality.

Template versions of these files can be found in:

```text
libs\CoreLibsFor_AHK\Templates
```

### Settings.ahk

Used for general project settings that should apply regardless of which main script is launched.

This file is typically stored next to the project's main scripts so it can be easily edited.

If preferred, it may also be placed inside the `libs` directory.

Settings that apply only to a specific script are usually better placed directly inside that script.

### AdvancedSettings.ahk

Intended for more specialized and rarely modified settings.

This file is typically stored inside the `libs` directory and used for parameters that normally do not require changes after the initial project setup.

If preferred, it may also be placed next to the main scripts.

### AdditionalFunctions.ahk

Intended for developer-defined helper functions.

If the file exists, it is automatically loaded by the library during startup.

It is commonly used for functions that should be available to all main scripts within the project.

Unlike the configuration files, this file is loaded only from the `libs` directory.

## Quick Access Through the Tray Menu

The library automatically adds tray menu entries for quick access to:

* the currently running main script;
* `Settings.ahk`;
* `AdvancedSettings.ahk`.

This makes it easy to edit the most important project files without manually browsing through folders.

If a file does not exist, its menu entry will not be shown.

## Libraries and Functions

Most core libraries are located in:

```text
libs\CoreLibsFor_AHK\BaseLibs
```

Most functions include built-in comments describing their purpose, parameters, and usage examples.

Since the framework continues to evolve and new functionality is added over time, a complete function reference is intentionally not maintained in this README.

For detailed information, it is recommended to review the source code directly.

## Additional Tools

`CoreLibsFor_AHK` also includes several auxiliary tools that can be useful when developing AutoHotkey scripts.

All of these tools are available from the tray menu of a running script under **Other programs**.

If needed, they can also be launched directly. The tool scripts are located in:

```text
CoreLibsFor_AHK\AuxiliaryScripts
```

### FindText

A tool for searching for images and text on the screen. It can be used to locate elements and retrieve their coordinates for further use in AutoHotkey scripts.

`FindText` is a third-party project. Additional information and links to the original project can be found in the [Included Third-Party Libraries](#Included-Third-Party-Libraries) section.

### CoordinateConverter

A tool for working with coordinates inside application windows.

It converts element coordinates into relative values that can be used regardless of the current window size. This is particularly useful when working with `PixelSearch` and other functions that rely on screen coordinates.

### KeyInfo

A small utility for determining the `SC` (Scan Code) and `VK` (Virtual-Key Code) of keyboard keys.

These values can be used when configuring hotkeys and other keyboard-related settings.

### WindowSpy

The standard AutoHotkey utility for inspecting windows and their controls.

It can be used to quickly obtain information such as window titles, process names, window classes, coordinates, and other data useful when developing AutoHotkey scripts.

## Included Third-Party Libraries

Although most of the code included through CoreLibsFor_AHK was written by me, the project also contains several third-party libraries.

### FindText

Original thread:

https://www.autohotkey.com/boards/viewtopic.php?f=6&t=17834

Community guide:

https://www.autohotkey.com/boards/viewtopic.php?f=7&p=456845#p456845

### Gdip

Official repository:

https://github.com/tariqporter/Gdip
