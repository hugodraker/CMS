TextUI Dispatch System & FSM Suite
A lightweight, high-performance Field Service Management (FSM) and ERP Dispatch System written in native Win32 C and backed by SQLite3.
Originally designed in AutoIt, this suite has been modernized into standalone, zero-dependency C executables (compiled via MinGW/GCC) featuring an SQL-driven Finite State Machine (FSM) menu engine, dual-protocol TCP networking (Telnet ASCII + 6-bit RLE compressed packets), interactive click-or-type terminal UIs, and automated Typst document generation.
🚀 Suite Components
The project consists of three core Win32 C applications sharing a unified SQLite database (`db.db`):
1. TextUI Dispatch Server (`cms03.c`)
The core multi-client application server and local dispatch console.
Dual-Protocol TCP Server (Port 23):
Standard Telnet Clients: Connects raw ASCII terminal clients (e.g., PuTTY, Windows Telnet, handheld barcode terminals) with per-connection login state, trusted IP auto-login, and a 4-level relational row-ID stack (`$rowid`, `$prowid`, `$pprowid`, `$ppprowid`).
Binary CRUD Clients (`\xA6` Protocol): Automatically detects binary packets using 6-bit character packing and Run-Length Encoding (RLE) for fast remote table queries.
Interactive Local Terminal: Features a classic black-and-white console where operators can either type menu numbers/text via keyboard or click anywhere on a numbered menu row to trigger actions immediately.
Built-in Admin Tools: Includes a live SQL Console, User Management GUI, and transactional CSV Import/Export utilities.
Typst Document Engine: Generates clean `.typ` markup files for Service Calls (`screport`), Quotes (`qreport`), Packing Slips (`psreport`), and Invoices (`invoice`).
2. Sys_Menu & SQL Visual Editor (`menu_editor.c`)
A dedicated developer IDE for building, refactoring, and testing the database-driven menu tree (`sys_menu`) and system queries (`sql_queries`).
Drag-and-Drop Reordering: Physically reorder menu items in the ListView and automatically re-sequence primary key IDs in the database.
Relational Renumbering:
Renumber All: Compresses the entire menu tree into the shortest possible sequential IDs (`1, 2, 3...`) while automatically updating all `nextid` and `previd` links.
Renumber Section: Target specific menu prefixes (e.g., `Q`, `D`, `S`) to cleanly re-index isolated modules.
Tree & Orphan Management: Detect orphaned menu branches (`[ORPHAN]`), duplicate items, copy/paste rows, or recursively delete entire downstream submenu trees.
Mode Toggle: Switch seamlessly between editing `sys_menu` state nodes and `sql_queries` (non-menu parameterized system queries).
Integrated Test Console: Launch a live sandbox terminal and SQL query runner to test menu flows, inspect stack states (`[Stack: 1=... 2=... 3=...]`), and debug SQL output in real time.
3. Universal CRUD Client (`fsm_client.c`)
A remote Win32 GUI client that connects to the Dispatch Server over TCP Port 23 using the compressed `\xA6` binary protocol.
Dynamic Schema Grid: Adapts input fields dynamically across 10 core FSM tables (`companies`, `contacts`, `addresses`, `equipments`, `quotes`, `dispatch`, `service_calls`, `inventory`, `shelf`, `service_contracts`).
Bandwidth-Optimized Protocol: Compresses SQL payloads using 6-bit character encoding and RLE compression (`\x1B` run markers) with checksum verification.
🛠️ Compilation Instructions
All applications are written in standard Win32 C and require MinGW-w64 (GCC) and the SQLite3 Amalgamation (`sqlite3.c` and `sqlite3.h`) in the same directory.
1. Build the Dispatch Server
```
gcc -Os -s -mwindows cms03.c sqlite3.c -o cms03.exe -lws2_32 -lcomctl32 -lgdi32 -lcomdlg32

```
2. Build the Visual Menu & Query Editor
```
gcc -Os -s -mwindows menu_editor.c sqlite3.c -o menu_editor.exe -lcomctl32 -lgdi32 -luser32

```
3. Build the Remote CRUD Client
```
gcc -Os -s -Wl,--subsystem,windows -mwindows fsm_client.c -o fsm_client.exe -lcomctl32 -lws2_32 -lgdi32

```
🗄️ Database Architecture
The system relies on `db.db` (SQLite3 in WAL mode). Aside from standard business tables (`dispatch`, `servicecall`, `inventory`, `quote`, `invoice`, `user`, etc.), the application logic is driven by two meta-tables:
`sys_menu` (State Machine Engine)
Controls every screen, prompt, and action in the TextUI interface:
Column	Description
`id`	Execution and display order of the menu item.
`menuid`	Current menu branch identifier (e.g., `100` for Main Menu, `Q03` for Quote Editor).
`menutext`	Display label or special engine keyword (`SQLMenu`, `ml`, `bc`, `screport`, `qreport`, `psreport`, `invoice`, or numeric stack pop count).
`nextid`	Target `menuid` branch when selected.
`previd`	Target `menuid` branch when pressing `0` (Back) or completing an input prompt.
`readquery`	SQL `SELECT` query executed to display dynamic values or populate `SQLMenu` lists.
`writequery`	SQL `INSERT`/`UPDATE`/`DELETE` executed upon user input or selection.
Dynamic Query Variables
Inside `readquery` and `writequery`, the engine automatically substitutes the following state variables:
`$userid` — Authenticated User ID of the active session.
`$typedtext` — Sanitized text or number entered by the user.
`$rowid` — Top of the session's selection stack (Depth 1).
`$prowid` — Previous selection on the stack (Depth 2).
`$pprowid` — Depth 3 selection on the stack.
`$ppprowid` — Depth 4 selection on the stack.
`sql_queries` (System Query Store)
Stores parameterized application queries (`{1}`, `{2}`, etc.) cached in memory at startup for fast execution.
💻 Usage Guide
Initialize the Database:
Place `db.db` in the application directory (or import your `.sql` schema via `File -> Import DB` in `cms03.exe`).
Run the Server (`cms03.exe`):
The server automatically listens on TCP port `23` and opens the local terminal at Menu `100`.
Click any numbered line (e.g., `1. Edit Your Service Call`) or type the number + `Enter` to navigate.
Enter `0` at any menu to pop the stack and return to the previous branch.
Connect via Telnet:
Open any Telnet client and connect to `127.0.0.1:23`:
```
   telnet 127.0.0.1 23
   
   ```
Edit Menus & Test Workflows (`menu_editor.exe`):
Launch `menu_editor.exe` to inspect or modify menu branches.
Click Test Menus / SQL to open the interactive sandbox and verify changes immediately without restarting the server.
📄 License
Released into the Public Domain. Provided "as is" without warranty of any kind.
