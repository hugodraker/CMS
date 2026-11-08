/* ============================================================================
 * TextUI Dispatch System - FSM Sys_Menu & SQL Queries Visual Editor + Tester
 * 
 * Features:
 *  - Mode Toggle: Edit `sys_menu` or `sql_queries` (Non-Menu Queries).
 *  - Test Menus & SQL Console Window:
 *      * Live interactive black terminal with keyboard & row-click testing.
 *      * Jump directly to the selected menu branch to test workflows.
 *      * Execute raw SQL queries and view live SQL execution logs.
 *  - Drag & Drop reordering (updates DB `id` sequence).
 *  - Duplicate, Copy, Paste, Find Orphans, Relational Renumbering, Del Tree.
 *
 * COMPILATION (MinGW GCC):
 *  gcc -Os -s -mwindows menu_editor.c sqlite3.c -o menu_editor.exe -lcomctl32 -lgdi32 -luser32
 * ============================================================================ */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include "sqlite3.h"

/* --- Resource IDs --- */
#define ID_LISTVIEW      101
#define ID_BTN_SAVE      102
#define ID_BTN_ADD       103
#define ID_BTN_DEL       104
#define ID_BTN_DELSUB    105
#define ID_BTN_COPY      106
#define ID_BTN_PASTE     107
#define ID_BTN_DUP       108
#define ID_BTN_ORPHAN    109
#define ID_BTN_RENUM     110
#define ID_BTN_RENUMSEC  111
#define ID_BTN_TEST      112
#define ID_BTN_MODE      113

#define ID_EDIT_MENUID   201
#define ID_EDIT_TEXT     202
#define ID_EDIT_NEXT     203
#define ID_EDIT_PREV     204
#define ID_EDIT_READ     205
#define ID_EDIT_WRITE    206

/* --- Test / SQL Console IDs --- */
#define ID_TEST_TERM     301
#define ID_TEST_SQLLOG   302
#define ID_TEST_SQLIN    303
#define ID_TEST_RUNSQL   304
#define ID_TEST_RESET    305
#define ID_TEST_JUMP     306
#define ID_TEST_CLEARLOG 307

/* --- Data Structures --- */
typedef struct {
    int id;           // Primary Key (ordering)
    char menuid[64];  // Or query 'name' in Query Mode
    char menutext[128];
    char nextid[64];
    char previd[64];
    char readquery[4096];  // Or 'query' in Query Mode
    char writequery[4096]; // Or 'timestamp' in Query Mode
    bool is_orphan;
} SysMenu;

#define MAX_MENUS 2500
static SysMenu g_menus[MAX_MENUS];
static int g_menuCount = 0;
static SysMenu g_clipboard = {0};
static bool g_hasClipboard = false;
static bool g_bQueryMode = false; // false = sys_menu, true = sql_queries

static sqlite3 *g_db = NULL;
static HWND g_hWnd, g_hList;
static HWND g_hLbls[6], g_hEdits[6];
static HWND g_hBtnDelSub, g_hBtnOrphan, g_hBtnRenum, g_hBtnRenumSec, g_hBtnMode, g_hBtnTest;

/* Test Console Window Handles & State */
static HWND g_hTestWnd = NULL, g_hTermEdit = NULL, g_hSqlLogEdit = NULL, g_hSqlInEdit = NULL;
static WNDPROC g_OldTermProc = NULL;
static HBRUSH g_hBlackBrush = NULL;

typedef struct {
    char userid[32];
    char branch[64];
    char stack[10][64];
    int stack_count;
} TestContext;

static TestContext g_testCtx;
static char g_termCmd[128] = {0};

/* Drag and Drop State */
static BOOL g_bDragging = FALSE;
static int g_iDragSource = -1;
static int g_iDropTarget = -1;

/* --- Utility Functions --- */
static void str_replace_all(char *str, const char *find, const char *replace) {
    if (!str || !find || !replace) return;
    size_t find_len = strlen(find);
    if (find_len == 0) return;
    size_t rep_len = strlen(replace);
    char temp[8192] = {0};
    char *insert = temp, *p = str;
    while (1) {
        char *match = strstr(p, find);
        if (!match) { strcpy(insert, p); break; }
        size_t len = match - p;
        if (insert - temp + len + rep_len >= sizeof(temp)) break;
        memcpy(insert, p, len); insert += len;
        memcpy(insert, replace, rep_len); insert += rep_len;
        p = match + find_len;
    }
    strcpy(str, temp);
}

static void EnsureTablesExist(void) {
    sqlite3_exec(g_db,
        "CREATE TABLE IF NOT EXISTS sys_menu ("
        "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,"
        "menuid TEXT NOT NULL DEFAULT '', menutext TEXT NOT NULL DEFAULT '',"
        "nextid TEXT NOT NULL DEFAULT '', previd TEXT NOT NULL DEFAULT '',"
        "readquery TEXT NOT NULL DEFAULT '', writequery TEXT NOT NULL DEFAULT '');"
        "CREATE TABLE IF NOT EXISTS sql_queries ("
        "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,"
        "name TEXT NOT NULL UNIQUE, query TEXT NOT NULL DEFAULT '',"
        "timestamp TEXT NOT NULL DEFAULT '');", NULL, NULL, NULL);
}

static void AppendSqlLog(const char *sql) {
    if (!g_hSqlLogEdit || !IsWindow(g_hSqlLogEdit) || !sql || !sql[0]) return;
    int len = GetWindowTextLengthA(g_hSqlLogEdit);
    if (len > 24000) {
        SetWindowTextA(g_hSqlLogEdit, "");
        len = 0;
    }
    SendMessageA(g_hSqlLogEdit, EM_SETSEL, len, len);
    SendMessageA(g_hSqlLogEdit, EM_REPLACESEL, FALSE, (LPARAM)sql);
    SendMessageA(g_hSqlLogEdit, EM_REPLACESEL, FALSE, (LPARAM)"\r\n");
    SendMessageA(g_hSqlLogEdit, EM_SCROLLCARET, 0, 0);
}

/* --- Database Operations --- */
static void LoadData(void) {
    g_menuCount = 0;
    char **res; int r, c;
    if (!g_bQueryMode) {
        if (sqlite3_get_table(g_db, "SELECT id, menuid, menutext, nextid, previd, readquery, writequery FROM sys_menu ORDER BY id ASC", &res, &r, &c, NULL) == SQLITE_OK) {
            for (int i = 1; i <= r && g_menuCount < MAX_MENUS; i++) {
                SysMenu *m = &g_menus[g_menuCount++];
                m->id = atoi(res[i*c + 0] ? res[i*c + 0] : "0");
                strncpy(m->menuid, res[i*c + 1] ? res[i*c + 1] : "", 63);
                strncpy(m->menutext, res[i*c + 2] ? res[i*c + 2] : "", 127);
                strncpy(m->nextid, res[i*c + 3] ? res[i*c + 3] : "", 63);
                strncpy(m->previd, res[i*c + 4] ? res[i*c + 4] : "", 63);
                strncpy(m->readquery, res[i*c + 5] ? res[i*c + 5] : "", 4095);
                strncpy(m->writequery, res[i*c + 6] ? res[i*c + 6] : "", 4095);
                m->is_orphan = false;
            }
            sqlite3_free_table(res);
        }
    } else {
        if (sqlite3_get_table(g_db, "SELECT id, name, query, timestamp FROM sql_queries ORDER BY id ASC", &res, &r, &c, NULL) == SQLITE_OK) {
            for (int i = 1; i <= r && g_menuCount < MAX_MENUS; i++) {
                SysMenu *m = &g_menus[g_menuCount++];
                memset(m, 0, sizeof(SysMenu));
                m->id = atoi(res[i*c + 0] ? res[i*c + 0] : "0");
                strncpy(m->menuid, res[i*c + 1] ? res[i*c + 1] : "", 63);
                strncpy(m->readquery, res[i*c + 2] ? res[i*c + 2] : "", 4095);
                strncpy(m->writequery, res[i*c + 3] ? res[i*c + 3] : "", 4095);
                strncpy(m->menutext, m->readquery, 120);
            }
            sqlite3_free_table(res);
        }
    }
}

static void SaveItemToDB(SysMenu *m) {
    char rq[8192], wq[8192], mt[256], id_s[128];
    strncpy(rq, m->readquery, 8191); rq[8191] = '\0'; str_replace_all(rq, "'", "''");
    strncpy(wq, m->writequery, 8191); wq[8191] = '\0'; str_replace_all(wq, "'", "''");
    strncpy(mt, m->menutext, 255); mt[255] = '\0'; str_replace_all(mt, "'", "''");
    strncpy(id_s, m->menuid, 127); id_s[127] = '\0'; str_replace_all(id_s, "'", "''");

    char query[18000];
    if (!g_bQueryMode) {
        snprintf(query, sizeof(query),
            "UPDATE sys_menu SET menuid='%s', menutext='%s', nextid='%s', previd='%s', readquery='%s', writequery='%s' WHERE id=%d;",
            id_s, mt, m->nextid, m->previd, rq, wq, m->id);
    } else {
        snprintf(query, sizeof(query),
            "UPDATE sql_queries SET name='%s', query='%s', timestamp=datetime('now') WHERE id=%d;",
            id_s, rq, m->id);
    }
    AppendSqlLog(query);
    sqlite3_exec(g_db, query, NULL, NULL, NULL);
}

static void InsertItemToDB(const char *menuid, SysMenu *src) {
    char rq[8192], wq[8192], mt[256], id_s[128];
    strncpy(rq, src->readquery, 8191); rq[8191] = '\0'; str_replace_all(rq, "'", "''");
    strncpy(wq, src->writequery, 8191); wq[8191] = '\0'; str_replace_all(wq, "'", "''");
    strncpy(mt, src->menutext, 255); mt[255] = '\0'; str_replace_all(mt, "'", "''");
    strncpy(id_s, menuid, 127); id_s[127] = '\0'; str_replace_all(id_s, "'", "''");

    char query[18000];
    if (!g_bQueryMode) {
        snprintf(query, sizeof(query),
            "INSERT INTO sys_menu (menuid, menutext, nextid, previd, readquery, writequery) VALUES ('%s', '%s', '%s', '%s', '%s', '%s');",
            id_s, mt, src->nextid, src->previd, rq, wq);
    } else {
        snprintf(query, sizeof(query),
            "INSERT INTO sql_queries (name, query, timestamp) VALUES ('%s', '%s', datetime('now'));",
            id_s, rq);
    }
    AppendSqlLog(query);
    sqlite3_exec(g_db, query, NULL, NULL, NULL);
}

static void RefreshListView(void) {
    SendMessage(g_hList, LVM_DELETEALLITEMS, 0, 0);
    for (int i = 0; i < g_menuCount; i++) {
        LVITEM lvi = {0};
        lvi.mask = LVIF_TEXT | LVIF_PARAM;
        lvi.iItem = i;
        lvi.lParam = i;
        
        char idStr[16]; snprintf(idStr, sizeof(idStr), "%d", g_menus[i].id);
        lvi.pszText = idStr;
        ListView_InsertItem(g_hList, &lvi);
        
        if (!g_bQueryMode) {
            char prefix[256] = "";
            if (g_menus[i].is_orphan) strcpy(prefix, "[ORPHAN] ");
            strcat(prefix, g_menus[i].menuid);
            ListView_SetItemText(g_hList, i, 1, prefix);
            ListView_SetItemText(g_hList, i, 2, g_menus[i].menutext);
            ListView_SetItemText(g_hList, i, 3, g_menus[i].nextid);
        } else {
            ListView_SetItemText(g_hList, i, 1, g_menus[i].menuid);
            ListView_SetItemText(g_hList, i, 2, g_menus[i].readquery);
            ListView_SetItemText(g_hList, i, 3, g_menus[i].writequery);
        }
    }
}

static void UpdateModeUI(void) {
    LVCOLUMN lvc = {0}; lvc.mask = LVCF_TEXT;
    if (!g_bQueryMode) {
        SetWindowTextA(g_hWnd, "Sys_Menu Advanced Visual Editor - [MODE: SYS_MENU]");
        SetWindowTextA(g_hBtnMode, "Mode: Non-Menu SQL");
        lvc.pszText = "MenuID"; ListView_SetColumn(g_hList, 1, &lvc);
        lvc.pszText = "Text"; ListView_SetColumn(g_hList, 2, &lvc);
        lvc.pszText = "NextID"; ListView_SetColumn(g_hList, 3, &lvc);

        SetWindowTextA(g_hLbls[0], "Menu ID:");
        SetWindowTextA(g_hLbls[4], "Read Query:");
        SetWindowTextA(g_hLbls[5], "Write Query:");
        for (int i = 1; i <= 3; i++) { ShowWindow(g_hLbls[i], SW_SHOW); ShowWindow(g_hEdits[i], SW_SHOW); }
        ShowWindow(g_hLbls[5], SW_SHOW); ShowWindow(g_hEdits[5], SW_SHOW);
        EnableWindow(g_hBtnDelSub, TRUE);
        EnableWindow(g_hBtnOrphan, TRUE);
        EnableWindow(g_hBtnRenum, TRUE);
        EnableWindow(g_hBtnRenumSec, TRUE);
    } else {
        SetWindowTextA(g_hWnd, "Sys_Menu Advanced Visual Editor - [MODE: NON-MENU QUERIES (sql_queries)]");
        SetWindowTextA(g_hBtnMode, "Mode: Sys_Menu");
        lvc.pszText = "Query Name"; ListView_SetColumn(g_hList, 1, &lvc);
        lvc.pszText = "SQL Query"; ListView_SetColumn(g_hList, 2, &lvc);
        lvc.pszText = "Timestamp"; ListView_SetColumn(g_hList, 3, &lvc);

        SetWindowTextA(g_hLbls[0], "Query Name (Key):");
        SetWindowTextA(g_hLbls[4], "SQL Query String (use {1}, {2}... for parameters):");
        SetWindowTextA(g_hLbls[5], "Last Updated Timestamp (Read-Only):");
        for (int i = 1; i <= 3; i++) { ShowWindow(g_hLbls[i], SW_HIDE); ShowWindow(g_hEdits[i], SW_HIDE); }
        EnableWindow(g_hBtnDelSub, FALSE);
        EnableWindow(g_hBtnOrphan, FALSE);
        EnableWindow(g_hBtnRenum, FALSE);
        EnableWindow(g_hBtnRenumSec, FALSE);
    }
    for (int i = 0; i < 6; i++) SetWindowTextA(g_hEdits[i], "");
    LoadData();
    RefreshListView();
}

/* --- Reordering --- */
static void ReassignIDsAndSave(void) {
    const char *tbl = g_bQueryMode ? "sql_queries" : "sys_menu";
    sqlite3_exec(g_db, "BEGIN TRANSACTION;", NULL, NULL, NULL);
    for (int i = 0; i < g_menuCount; i++) {
        int old_id = g_menus[i].id;
        int temp_id = (i + 1) + 100000;
        char query[128];
        snprintf(query, sizeof(query), "UPDATE %s SET id=%d WHERE id=%d;", tbl, temp_id, old_id);
        sqlite3_exec(g_db, query, NULL, NULL, NULL);
        g_menus[i].id = i + 1;
    }
    for (int i = 0; i < g_menuCount; i++) {
        char query[128];
        snprintf(query, sizeof(query), "UPDATE %s SET id=%d WHERE id=%d;", tbl, g_menus[i].id, g_menus[i].id + 100000);
        sqlite3_exec(g_db, query, NULL, NULL, NULL);
    }
    sqlite3_exec(g_db, "COMMIT;", NULL, NULL, NULL);
}

/* --- Editor Operations --- */
static void ApplyEdits(void) {
    int sel = ListView_GetNextItem(g_hList, -1, LVNI_SELECTED);
    if (sel < 0) return;
    SysMenu *m = &g_menus[sel];
    GetWindowTextA(g_hEdits[0], m->menuid, 63);
    GetWindowTextA(g_hEdits[1], m->menutext, 127);
    GetWindowTextA(g_hEdits[2], m->nextid, 63);
    GetWindowTextA(g_hEdits[3], m->previd, 63);
    GetWindowTextA(g_hEdits[4], m->readquery, 4095);
    GetWindowTextA(g_hEdits[5], m->writequery, 4095);
    SaveItemToDB(m);
    LoadData();
    RefreshListView();
    ListView_SetItemState(g_hList, sel, LVIS_SELECTED | LVIS_FOCUSED, LVIS_SELECTED | LVIS_FOCUSED);
}

static void AddNewItem(void) {
    if (!g_bQueryMode) {
        sqlite3_exec(g_db, "INSERT INTO sys_menu (menuid, menutext, nextid, previd) VALUES ('NEW', 'New Item', '100', '100');", NULL, NULL, NULL);
    } else {
        char q[256];
        snprintf(q, sizeof(q), "INSERT INTO sql_queries (name, query, timestamp) VALUES ('NEW_QUERY_%d', 'SELECT 1;', datetime('now'));", GetTickCount() % 10000);
        sqlite3_exec(g_db, q, NULL, NULL, NULL);
    }
    LoadData(); RefreshListView();
    ListView_SetItemState(g_hList, g_menuCount - 1, LVIS_SELECTED | LVIS_FOCUSED, LVIS_SELECTED | LVIS_FOCUSED);
    ListView_EnsureVisible(g_hList, g_menuCount - 1, FALSE);
}

static void DeleteSysMenuRow(int index) {
    if (index < 0 || index >= g_menuCount) return;
    char query[128];
    snprintf(query, sizeof(query), "DELETE FROM %s WHERE id=%d;", g_bQueryMode ? "sql_queries" : "sys_menu", g_menus[index].id);
    AppendSqlLog(query);
    sqlite3_exec(g_db, query, NULL, NULL, NULL);
    LoadData(); RefreshListView();
}

static void RecursiveDeleteSubmenus(const char *root_id, int depth) {
    if (depth > 20 || g_bQueryMode) return;
    for (int i = 0; i < g_menuCount; i++) {
        if (strcmp(g_menus[i].menuid, root_id) == 0) {
            char next[64]; strcpy(next, g_menus[i].nextid);
            char q[128]; snprintf(q, sizeof(q), "DELETE FROM sys_menu WHERE id=%d;", g_menus[i].id);
            sqlite3_exec(g_db, q, NULL, NULL, NULL);
            if (strlen(next) > 0 && strcmp(next, root_id) != 0) {
                RecursiveDeleteSubmenus(next, depth + 1);
            }
        }
    }
}

static void FindOrphans(void) {
    if (g_bQueryMode) return;
    for (int i = 0; i < g_menuCount; i++) {
        g_menus[i].is_orphan = true;
        if (strcmp(g_menus[i].menuid, "100") == 0 || strcmp(g_menus[i].menuid, "101") == 0 || strcmp(g_menus[i].menuid, "") == 0) {
            g_menus[i].is_orphan = false;
            continue;
        }
        for (int j = 0; j < g_menuCount; j++) {
            if (i != j && (strcmp(g_menus[j].nextid, g_menus[i].menuid) == 0 || strcmp(g_menus[j].previd, g_menus[i].menuid) == 0)) {
                g_menus[i].is_orphan = false;
                break;
            }
        }
    }
    RefreshListView();
}

/* --- Relational Renumbering Engine --- */
typedef struct {
    char old_id[64];
    char new_id[64];
} IDMap;

static void PerformRenumbering(const char *prefix, bool all) {
    if (g_bQueryMode) return;
    IDMap *map = malloc(sizeof(IDMap) * MAX_MENUS);
    int mapCount = 0;
    
    int next_int_id = 1;
    for (int i = 0; i < g_menuCount; i++) {
        if (all || (prefix && strncmp(g_menus[i].menuid, prefix, strlen(prefix)) == 0)) {
            bool exists = false;
            for (int k = 0; k < mapCount; k++) {
                if (strcmp(map[k].old_id, g_menus[i].menuid) == 0) { exists = true; break; }
            }
            if (!exists && strlen(g_menus[i].menuid) > 0) {
                strcpy(map[mapCount].old_id, g_menus[i].menuid);
                if (all) snprintf(map[mapCount].new_id, 64, "%d", next_int_id++);
                else snprintf(map[mapCount].new_id, 64, "%s%d", prefix, next_int_id++);
                mapCount++;
            }
        }
    }

    sqlite3_exec(g_db, "BEGIN TRANSACTION;", NULL, NULL, NULL);
    for (int i = 0; i < g_menuCount; i++) {
        bool changed = false;
        for (int k = 0; k < mapCount; k++) {
            if (strcmp(g_menus[i].menuid, map[k].old_id) == 0) { strcpy(g_menus[i].menuid, map[k].new_id); changed = true; }
            if (strcmp(g_menus[i].nextid, map[k].old_id) == 0) { strcpy(g_menus[i].nextid, map[k].new_id); changed = true; }
            if (strcmp(g_menus[i].previd, map[k].old_id) == 0) { strcpy(g_menus[i].previd, map[k].new_id); changed = true; }
        }
        if (changed) SaveItemToDB(&g_menus[i]);
    }
    sqlite3_exec(g_db, "COMMIT;", NULL, NULL, NULL);
    free(map);
    LoadData(); RefreshListView();
    MessageBox(g_hWnd, "Renumbering Complete.", "Success", MB_OK);
}

/* In-Memory Dialog Template for Prefix Input */
static char g_szPrefixInput[64] = {0};
INT_PTR CALLBACK PrefixDlgProc(HWND hDlg, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_INITDIALOG:
            SetWindowText(hDlg, "Renumber Section");
            CreateWindow("STATIC", "Enter MenuID Prefix (e.g., 'Q'):", WS_CHILD|WS_VISIBLE, 10, 10, 200, 20, hDlg, NULL, NULL, NULL);
            CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE, 10, 30, 200, 25, hDlg, (HMENU)101, NULL, NULL);
            CreateWindow("BUTTON", "OK", WS_CHILD|WS_VISIBLE|BS_DEFPUSHBUTTON, 10, 65, 80, 25, hDlg, (HMENU)IDOK, NULL, NULL);
            CreateWindow("BUTTON", "Cancel", WS_CHILD|WS_VISIBLE, 130, 65, 80, 25, hDlg, (HMENU)IDCANCEL, NULL, NULL);
            return TRUE;
        case WM_COMMAND:
            if (LOWORD(wParam) == IDOK) {
                GetDlgItemText(hDlg, 101, g_szPrefixInput, 63);
                EndDialog(hDlg, IDOK);
            } else if (LOWORD(wParam) == IDCANCEL) EndDialog(hDlg, IDCANCEL);
            break;
    }
    return FALSE;
}

/* ============================================================================
 * INTERACTIVE TEST MENUS & SQL CONSOLE ENGINE
 * ============================================================================ */
static void pushstack(TestContext *c, const char *val) {
    if (!val || strlen(val) == 0) return;
    if (c->stack_count < 10) strncpy(c->stack[c->stack_count++], val, 63);
    else {
        for (int i = 1; i < 10; i++) strcpy(c->stack[i - 1], c->stack[i]);
        strncpy(c->stack[9], val, 63);
    }
}
static const char* popstack(TestContext *c, int count) {
    static char ret[64]; ret[0] = '\0';
    if (count < 1) return ret;
    if (c->stack_count >= count) {
        strcpy(ret, c->stack[c->stack_count - count]); c->stack_count -= count;
    } else if (c->stack_count > 0) { strcpy(ret, c->stack[0]); c->stack_count = 0; }
    return ret;
}
static const char* readstack(TestContext *c, int depth) {
    if (c->stack_count < depth || depth < 1) return "";
    return c->stack[c->stack_count - depth];
}
static const char* check_num(int num) {
    static char buf[16]; snprintf(buf, sizeof(buf), "%d", num); return buf;
}

static void ExecTestWriteSQL(const char *sql) {
    if (!sql || !sql[0]) return;
    AppendSqlLog(sql);
    char *err = NULL;
    if (sqlite3_exec(g_db, sql, NULL, NULL, &err) != SQLITE_OK && err) {
        char msg[1024]; snprintf(msg, sizeof(msg), "-- SQL ERROR: %s", err);
        AppendSqlLog(msg);
        sqlite3_free(err);
    }
}

static void TestLoadMenu(TestContext *c, const char *typed_in) {
    char typedtext[1024]; strncpy(typedtext, typed_in, sizeof(typedtext) - 1); typedtext[1023] = '\0';
    if (strlen(c->branch) == 0) strcpy(c->branch, "100");

    int max_hops = 25;
    while (max_hops-- > 0) {
        char query[1024];
        snprintf(query, sizeof(query), "SELECT menuid, menutext, nextid, previd, readquery, writequery FROM sys_menu WHERE menuid='%s' ORDER BY id ASC", c->branch);
        AppendSqlLog(query);
        char **res; int rows, cols;
        if (sqlite3_get_table(g_db, query, &res, &rows, &cols, NULL) != SQLITE_OK) return;
        
        if (rows == 0) {
            char out[256]; snprintf(out, sizeof(out), "\r\n === Menu %s ===\r\n Menu not found: %s\r\n\r\n Enter 0 to reset: %s", c->branch, c->branch, g_termCmd);
            if (strcmp(typedtext, "0") == 0) {
                sqlite3_free_table(res);
                strcpy(c->branch, "100");
                typedtext[0] = '\0';
                continue;
            }
            SetWindowTextA(g_hTermEdit, out);
            sqlite3_free_table(res);
            return;
        }

        char buf[8192] = {0}; int num = 1; char rowid[128] = {0}; int continue_loop = 0;

        for (int i = 1; i <= rows; i++) {
            const char *menutext = res[i*cols+1] ? res[i*cols+1] : "";
            const char *nextbranch = res[i*cols+2] ? res[i*cols+2] : "";
            const char *prevbranch = res[i*cols+3] ? res[i*cols+3] : "";
            char readq[4096]; strcpy(readq, res[i*cols+4] ? res[i*cols+4] : "");
            char writeq[4096]; strcpy(writeq, res[i*cols+5] ? res[i*cols+5] : "");

            char safe_typed[1024]; strcpy(safe_typed, typedtext); str_replace_all(safe_typed, "'", "''");
            str_replace_all(readq, "$userid", c->userid); str_replace_all(writeq, "$userid", c->userid);

            if (strcmp(menutext, "screport") == 0 || strcmp(menutext, "qreport") == 0 || strcmp(menutext, "psreport") == 0 || strcmp(menutext, "invoice") == 0) {
                strcpy(c->branch, nextbranch);
                str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$prowid", readstack(c, 2));
                str_replace_all(writeq, "$pprowid", readstack(c, 3)); str_replace_all(writeq, "$ppprowid", readstack(c, 4));
                str_replace_all(writeq, "$typedtext", safe_typed);
                ExecTestWriteSQL(writeq);
                typedtext[0] = '\0'; pushstack(c, rowid); continue_loop = 1; break;
            }
            else if (strcmp(menutext, "ml") == 0) {
                strcpy(c->branch, nextbranch);
                str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$typedtext", safe_typed);
                ExecTestWriteSQL(writeq);
                typedtext[0] = '\0'; continue_loop = 1; break;
            }
            else if (strcmp(menutext, "") == 0 && strcmp(nextbranch, prevbranch) == 0) {
                strcpy(c->branch, nextbranch);
                str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$prowid", readstack(c, 2));
                str_replace_all(writeq, "$pprowid", readstack(c, 3)); str_replace_all(writeq, "$ppprowid", readstack(c, 4));
                str_replace_all(writeq, "$typedtext", safe_typed);
                ExecTestWriteSQL(writeq);
                
                str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$prowid", readstack(c, 2));
                str_replace_all(readq, "$pprowid", readstack(c, 3)); str_replace_all(readq, "$ppprowid", readstack(c, 4));
                str_replace_all(readq, "$typedtext", safe_typed);
                char **rq; int rr, rc;
                if (strlen(readq) > 0) {
                    AppendSqlLog(readq);
                    if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                        if (rr > 0 && rq[rc]) strcpy(rowid, rq[rc]);
                        sqlite3_free_table(rq);
                    }
                }
                typedtext[0] = '\0'; pushstack(c, rowid); continue_loop = 1; break;
            }
            else if (isdigit((unsigned char)menutext[0]) && atoi(menutext) > 0) {
                strcpy(c->branch, nextbranch); strcpy(rowid, popstack(c, atoi(menutext)));
                typedtext[0] = '\0'; continue_loop = 1; break;
            }
            else if (strcmp(typedtext, "0") == 0 && strcmp(nextbranch, prevbranch) != 0) {
                strcpy(rowid, popstack(c, 1)); strcpy(c->branch, prevbranch);
                typedtext[0] = '\0'; continue_loop = 1; break;
            }
            else if (strlen(typedtext) > 0 && strcmp(nextbranch, prevbranch) == 0 && strlen(menutext) > 0) {
                if (strlen(writeq) > 0 && strcmp(writeq, "c") != 0) {
                    str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$prowid", readstack(c, 2));
                    str_replace_all(writeq, "$pprowid", readstack(c, 3)); str_replace_all(writeq, "$ppprowid", readstack(c, 4));
                    str_replace_all(writeq, "$typedtext", safe_typed);
                    ExecTestWriteSQL(writeq);
                    
                    if (strlen(readq) > 0) {
                        str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$prowid", readstack(c, 2));
                        str_replace_all(readq, "$pprowid", readstack(c, 3)); str_replace_all(readq, "$ppprowid", readstack(c, 4));
                        str_replace_all(readq, "$typedtext", safe_typed);
                        AppendSqlLog(readq);
                        char **rq; int rr, rc;
                        if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                            if (rr > 0 && rq[rc]) pushstack(c, rq[rc]);
                            sqlite3_free_table(rq);
                        }
                    }
                } else if (strlen(writeq) > 0) pushstack(c, typedtext);
                strcpy(c->branch, prevbranch); typedtext[0] = '\0'; continue_loop = 1; break;
            }
            else if (strcmp(nextbranch, prevbranch) == 0) {
                if (strcmp(menutext, "bc") != 0) {
                    strcat(buf, " "); strcat(buf, menutext); strcat(buf, "\r\n");
                }
            }
            else if (strcmp(menutext, "SQLMenu") == 0) {
                str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$prowid", readstack(c, 2));
                str_replace_all(readq, "$pprowid", readstack(c, 2));
                str_replace_all(readq, "$ppprowid", readstack(c, 3)); str_replace_all(readq, "$typedtext", readstack(c, 3));
                
                char **rq; int rr, rc;
                if (strlen(readq) > 0) {
                    AppendSqlLog(readq);
                    if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                        int n = num;
                        for (int x = 1; x <= rr; x++) {
                            const char *val_col = (rc > 1) ? rq[x*rc + 1] : rq[x*rc + 0];
                            char line[512]; snprintf(line, sizeof(line), " %2d. %s\r\n", n, val_col ? val_col : "");
                            strcat(buf, line);
                            char check_typed[16]; snprintf(check_typed, sizeof(check_typed), "%d", n);
                            if (strcmp(writeq, "c") == 0 && strlen(typedtext) > 0) strcpy(check_typed, typedtext);
                            
                            if (strcmp(typedtext, check_typed) == 0) {
                                strcpy(rowid, rq[x*rc + 0] ? rq[x*rc + 0] : "");
                                str_replace_all(writeq, "$rowid", rowid);
                                str_replace_all(writeq, "$prowid", readstack(c, 1));
                                str_replace_all(writeq, "$pprowid", readstack(c, 2));
                                str_replace_all(writeq, "$ppprowid", readstack(c, 3));
                                if (strcmp(writeq, "c") != 0 && strlen(writeq) > 0) ExecTestWriteSQL(writeq);
                                strcpy(c->branch, nextbranch); typedtext[0] = '\0'; pushstack(c, rowid);
                                continue_loop = 1; break;
                            }
                            n++;
                        }
                        num = n - 1; sqlite3_free_table(rq);
                        if (continue_loop) break;
                    }
                }
            }
            else if (strcmp(typedtext, check_num(num)) == 0 && strcmp(nextbranch, prevbranch) != 0) {
                strcpy(c->branch, nextbranch); typedtext[0] = '\0'; pushstack(c, rowid); continue_loop = 1; break;
            }
            else if (strcmp(nextbranch, prevbranch) != 0 && strlen(menutext) > 0) {
                char dres[256] = {0};
                if (strlen(readq) > 0 && strlen(readstack(c, 1)) > 0) {
                    str_replace_all(readq, "$rowid", readstack(c, 1));
                    str_replace_all(readq, "$prowid", readstack(c, 2));
                    str_replace_all(readq, "$pprowid", readstack(c, 3));
                    str_replace_all(readq, "$ppprowid", readstack(c, 4));
                    AppendSqlLog(readq);
                    char **rq; int rr, rc;
                    if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                        if (rr > 0 && rq[rc]) strncpy(dres, rq[rc], 255);
                        sqlite3_free_table(rq);
                    }
                }
                char line[512]; snprintf(line, sizeof(line), " %2d. %s%s\r\n", num, menutext, dres);
                strcat(buf, line);
            }
            num++;
        }
        
        sqlite3_free_table(res);
        if (!continue_loop) {
            char stack_info[256] = {0};
            snprintf(stack_info, sizeof(stack_info), "[Stack: 1='%s' 2='%s' 3='%s']", readstack(c, 1), readstack(c, 2), readstack(c, 3));
            char full[8192];
            snprintf(full, sizeof(full), " === Menu %s ===  %s\r\n\r\n%s\r\n Enter choice (or 0): %s", c->branch, stack_info, buf, g_termCmd);
            SetWindowTextA(g_hTermEdit, full);
            int len = GetWindowTextLengthA(g_hTermEdit);
            SendMessageA(g_hTermEdit, EM_SETSEL, len, len);
            SendMessageA(g_hTermEdit, EM_SCROLLCARET, 0, 0);
            break;
        }
    }
}

LRESULT CALLBACK TestTermSubclassProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_CHAR) {
        if (wParam == '\r' || wParam == '\n') {
            char cmd[128]; strcpy(cmd, g_termCmd); g_termCmd[0] = '\0';
            TestLoadMenu(&g_testCtx, cmd);
        } else if (wParam == '\b') {
            int len = strlen(g_termCmd);
            if (len > 0) { g_termCmd[len - 1] = '\0'; TestLoadMenu(&g_testCtx, ""); }
        } else if (isprint((unsigned char)wParam)) {
            int len = strlen(g_termCmd);
            if (len < 126) { g_termCmd[len] = (char)wParam; g_termCmd[len + 1] = '\0'; TestLoadMenu(&g_testCtx, ""); }
        }
        return 0;
    } else if (msg == WM_KEYDOWN) {
        if (wParam == VK_RETURN || wParam == VK_BACK || wParam == VK_ESCAPE || wParam == VK_DELETE) return 0;
    } else if (msg == WM_LBUTTONDOWN) {
        SetFocus(hwnd);
        int pos = SendMessageA(hwnd, EM_CHARFROMPOS, 0, lParam);
        int line_idx = SendMessageA(hwnd, EM_LINEFROMCHAR, LOWORD(pos), 0);
        char lineBuf[256] = {0}; *((WORD*)lineBuf) = sizeof(lineBuf) - 1;
        int len = SendMessageA(hwnd, EM_GETLINE, line_idx, (LPARAM)lineBuf); lineBuf[len] = '\0';
        
        int choice = -1;
        if (sscanf(lineBuf, " %d.", &choice) == 1 || sscanf(lineBuf, "%d.", &choice) == 1) {
            char ch_str[16]; snprintf(ch_str, 15, "%d", choice);
            g_termCmd[0] = '\0';
            TestLoadMenu(&g_testCtx, ch_str);
        }
        return 0;
    }
    return CallWindowProc(g_OldTermProc, hwnd, msg, wParam, lParam);
}

LRESULT CALLBACK TestWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE: {
            HFONT hFont = CreateFont(15, 0, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, 0, 0, DEFAULT_QUALITY, DEFAULT_PITCH, "Segoe UI");
            HFONT hMono = CreateFont(16, 0, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, 0, 0, DEFAULT_QUALITY, FIXED_PITCH, "Consolas");

            CreateWindow("STATIC", "Interactive Menu Terminal (Type + Enter, or Click any numbered row):", WS_CHILD|WS_VISIBLE, 10, 8, 460, 20, hwnd, NULL, NULL, NULL);
            g_hTermEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL|ES_MULTILINE|ES_READONLY, 10, 30, 480, 440, hwnd, (HMENU)ID_TEST_TERM, NULL, NULL);
            SendMessage(g_hTermEdit, WM_SETFONT, (WPARAM)hMono, TRUE);
            g_OldTermProc = (WNDPROC)SetWindowLongPtr(g_hTermEdit, GWLP_WNDPROC, (LONG_PTR)TestTermSubclassProc);

            CreateWindow("BUTTON", "Reset to Menu 100", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 10, 480, 150, 30, hwnd, (HMENU)ID_TEST_RESET, NULL, NULL);
            CreateWindow("BUTTON", "Jump to Selected Menu", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 170, 480, 170, 30, hwnd, (HMENU)ID_TEST_JUMP, NULL, NULL);

            CreateWindow("STATIC", "Live SQL Execution Log & Query Runner:", WS_CHILD|WS_VISIBLE, 500, 8, 350, 20, hwnd, NULL, NULL, NULL);
            g_hSqlLogEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL|WS_HSCROLL|ES_MULTILINE|ES_READONLY, 500, 30, 420, 240, hwnd, (HMENU)ID_TEST_SQLLOG, NULL, NULL);
            SendMessage(g_hSqlLogEdit, WM_SETFONT, (WPARAM)hMono, TRUE);

            CreateWindow("STATIC", "SQL Query Input / Results:", WS_CHILD|WS_VISIBLE, 500, 278, 250, 20, hwnd, NULL, NULL, NULL);
            g_hSqlInEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "SELECT * FROM sys_menu LIMIT 10;", WS_CHILD|WS_VISIBLE|WS_VSCROLL|WS_HSCROLL|ES_MULTILINE|ES_WANTRETURN, 500, 300, 420, 170, hwnd, (HMENU)ID_TEST_SQLIN, NULL, NULL);
            SendMessage(g_hSqlInEdit, WM_SETFONT, (WPARAM)hMono, TRUE);

            CreateWindow("BUTTON", "Execute SQL Query", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 500, 480, 160, 30, hwnd, (HMENU)ID_TEST_RUNSQL, NULL, NULL);
            CreateWindow("BUTTON", "Clear Log", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 670, 480, 110, 30, hwnd, (HMENU)ID_TEST_CLEARLOG, NULL, NULL);
            break;
        }
        case WM_CTLCOLOREDIT:
        case WM_CTLCOLORSTATIC: {
            if ((HWND)lParam == g_hTermEdit) {
                HDC hdc = (HDC)wParam;
                SetTextColor(hdc, RGB(250, 250, 250));
                SetBkColor(hdc, RGB(0, 0, 0));
                return (LRESULT)g_hBlackBrush;
            }
            break;
        }
        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_TEST_RESET) {
                g_testCtx.stack_count = 0;
                strcpy(g_testCtx.branch, "100");
                g_termCmd[0] = '\0';
                TestLoadMenu(&g_testCtx, "");
                SetFocus(g_hTermEdit);
            } else if (LOWORD(wParam) == ID_TEST_JUMP) {
                int sel = ListView_GetNextItem(g_hList, -1, LVNI_SELECTED);
                if (sel >= 0 && !g_bQueryMode && strlen(g_menus[sel].menuid) > 0) {
                    strcpy(g_testCtx.branch, g_menus[sel].menuid);
                } else {
                    strcpy(g_testCtx.branch, "100");
                }
                g_termCmd[0] = '\0';
                TestLoadMenu(&g_testCtx, "");
                SetFocus(g_hTermEdit);
            } else if (LOWORD(wParam) == ID_TEST_CLEARLOG) {
                SetWindowTextA(g_hSqlLogEdit, "");
            } else if (LOWORD(wParam) == ID_TEST_RUNSQL) {
                char query[8192]; GetWindowTextA(g_hSqlInEdit, query, sizeof(query));
                AppendSqlLog(query);
                char **res; int r, c; char *err = NULL;
                if (sqlite3_get_table(g_db, query, &res, &r, &c, &err) == SQLITE_OK) {
                    char out[16384] = {0};
                    int off = snprintf(out, sizeof(out), "%s\r\n/* --- Result (%d rows) --- */\r\n", query, r);
                    for (int i = 0; i <= r && off < (int)sizeof(out) - 256; i++) {
                        for (int j = 0; j < c; j++) {
                            off += snprintf(out + off, sizeof(out) - off, "%s%s", res[i*c+j] ? res[i*c+j] : "NULL", (j == c - 1) ? "" : " | ");
                        }
                        off += snprintf(out + off, sizeof(out) - off, "\r\n");
                    }
                    SetWindowTextA(g_hSqlInEdit, out);
                    sqlite3_free_table(res);
                    LoadData(); RefreshListView();
                } else {
                    char out[8192];
                    snprintf(out, sizeof(out), "%s\r\n/* ERROR: %s */", query, err ? err : "Unknown Error");
                    SetWindowTextA(g_hSqlInEdit, out);
                    if (err) sqlite3_free(err);
                }
            }
            break;
        }
        case WM_CLOSE:
            ShowWindow(hwnd, SW_HIDE);
            return 0;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

static void OpenTestConsole(void) {
    if (!g_hTestWnd) {
        WNDCLASSEX wcTest = { sizeof(WNDCLASSEX), CS_HREDRAW|CS_VREDRAW, TestWndProc, 0, 0, GetModuleHandle(NULL), NULL, LoadCursor(NULL, IDC_ARROW), (HBRUSH)(COLOR_BTNFACE + 1), NULL, "FSMTestConsole", NULL };
        RegisterClassEx(&wcTest);
        g_hTestWnd = CreateWindowEx(WS_EX_DLGMODALFRAME, "FSMTestConsole", "Test Menus & Interactive SQL Console", WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX, CW_USEDEFAULT, CW_USEDEFAULT, 945, 560, g_hWnd, NULL, GetModuleHandle(NULL), NULL);
    }

    int sel = ListView_GetNextItem(g_hList, -1, LVNI_SELECTED);
    if (sel >= 0) {
        if (!g_bQueryMode && strlen(g_menus[sel].menuid) > 0) {
            strcpy(g_testCtx.branch, g_menus[sel].menuid);
            if (strlen(g_menus[sel].readquery) > 0) SetWindowTextA(g_hSqlInEdit, g_menus[sel].readquery);
        } else if (g_bQueryMode && strlen(g_menus[sel].readquery) > 0) {
            SetWindowTextA(g_hSqlInEdit, g_menus[sel].readquery);
        }
    }
    if (strlen(g_testCtx.branch) == 0) strcpy(g_testCtx.branch, "100");
    strcpy(g_testCtx.userid, "0");

    ShowWindow(g_hTestWnd, SW_SHOW);
    SetForegroundWindow(g_hTestWnd);
    TestLoadMenu(&g_testCtx, "");
    SetFocus(g_hTermEdit);
}

/* --- UI Handlers --- */
static void OnListSelect(void) {
    int sel = ListView_GetNextItem(g_hList, -1, LVNI_SELECTED);
    if (sel >= 0) {
        SysMenu *m = &g_menus[sel];
        SetWindowTextA(g_hEdits[0], m->menuid);
        SetWindowTextA(g_hEdits[1], m->menutext);
        SetWindowTextA(g_hEdits[2], m->nextid);
        SetWindowTextA(g_hEdits[3], m->previd);
        SetWindowTextA(g_hEdits[4], m->readquery);
        SetWindowTextA(g_hEdits[5], m->writequery);
    }
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE: {
            int wLeft = 400, btnW = 85;
            g_hBlackBrush = CreateSolidBrush(RGB(0, 0, 0));
            
            g_hList = CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTVIEW, "", 
                WS_CHILD | WS_VISIBLE | LVS_REPORT | LVS_SHOWSELALWAYS | LVS_SINGLESEL, 
                10, 10, wLeft, 650, hwnd, (HMENU)ID_LISTVIEW, NULL, NULL);
            ListView_SetExtendedListViewStyle(g_hList, LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES);
            
            LVCOLUMN lvc = {0}; lvc.mask = LVCF_TEXT | LVCF_WIDTH;
            lvc.pszText = "ID"; lvc.cx = 45; ListView_InsertColumn(g_hList, 0, &lvc);
            lvc.pszText = "MenuID"; lvc.cx = 85; ListView_InsertColumn(g_hList, 1, &lvc);
            lvc.pszText = "Text"; lvc.cx = 165; ListView_InsertColumn(g_hList, 2, &lvc);
            lvc.pszText = "NextID"; lvc.cx = 75; ListView_InsertColumn(g_hList, 3, &lvc);

            int eX = wLeft + 20, eY = 10, eW = 620;
            const char* lbls[] = {"Menu ID:", "Menu Text:", "Next ID:", "Prev ID:", "Read Query:", "Write Query:"};
            for (int i = 0; i < 6; i++) {
                g_hLbls[i] = CreateWindow("STATIC", lbls[i], WS_CHILD|WS_VISIBLE, eX, eY, eW, 20, hwnd, NULL, NULL, NULL);
                int h = (i >= 4) ? 175 : 25;
                DWORD style = WS_CHILD|WS_VISIBLE|WS_BORDER | ((i >= 4) ? (ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL|ES_WANTRETURN) : ES_AUTOHSCROLL);
                g_hEdits[i] = CreateWindow("EDIT", "", style, eX, eY + 20, eW, h, hwnd, (HMENU)(ID_EDIT_MENUID + i), NULL, NULL);
                eY += h + 28;
            }

            int bX = wLeft + 20; eY -= 10;
            CreateWindow("BUTTON", "Apply Edits", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX, eY, btnW, 30, hwnd, (HMENU)ID_BTN_SAVE, NULL, NULL);
            CreateWindow("BUTTON", "Add New", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=btnW+5, eY, btnW, 30, hwnd, (HMENU)ID_BTN_ADD, NULL, NULL);
            CreateWindow("BUTTON", "Delete", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=btnW+5, eY, btnW, 30, hwnd, (HMENU)ID_BTN_DEL, NULL, NULL);
            g_hBtnDelSub = CreateWindow("BUTTON", "Del Tree", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=btnW+5, eY, btnW, 30, hwnd, (HMENU)ID_BTN_DELSUB, NULL, NULL);
            CreateWindow("BUTTON", "Copy", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=btnW+15, eY, btnW-20, 30, hwnd, (HMENU)ID_BTN_COPY, NULL, NULL);
            CreateWindow("BUTTON", "Paste", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=btnW-15, eY, btnW-20, 30, hwnd, (HMENU)ID_BTN_PASTE, NULL, NULL);
            CreateWindow("BUTTON", "Duplicate", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=btnW-15, eY, btnW, 30, hwnd, (HMENU)ID_BTN_DUP, NULL, NULL);

            bX = wLeft + 20; eY += 38;
            g_hBtnOrphan = CreateWindow("BUTTON", "Find Orphans", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX, eY, 100, 30, hwnd, (HMENU)ID_BTN_ORPHAN, NULL, NULL);
            g_hBtnRenum = CreateWindow("BUTTON", "Renum ALL", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=105, eY, 100, 30, hwnd, (HMENU)ID_BTN_RENUM, NULL, NULL);
            g_hBtnRenumSec = CreateWindow("BUTTON", "Renum Section", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=105, eY, 110, 30, hwnd, (HMENU)ID_BTN_RENUMSEC, NULL, NULL);
            g_hBtnTest = CreateWindow("BUTTON", "Test Menus / SQL", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=120, eY, 135, 30, hwnd, (HMENU)ID_BTN_TEST, NULL, NULL);
            g_hBtnMode = CreateWindow("BUTTON", "Mode: Non-Menu SQL", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, bX+=140, eY, 150, 30, hwnd, (HMENU)ID_BTN_MODE, NULL, NULL);

            EnsureTablesExist();
            LoadData();
            RefreshListView();
            break;
        }
        case WM_NOTIFY: {
            LPNMHDR nmh = (LPNMHDR)lParam;
            if (nmh->idFrom == ID_LISTVIEW) {
                if (nmh->code == LVN_ITEMCHANGED) {
                    LPNMLISTVIEW pnmv = (LPNMLISTVIEW)lParam;
                    if (pnmv->uNewState & LVIS_SELECTED) OnListSelect();
                } else if (nmh->code == LVN_BEGINDRAG) {
                    LPNMLISTVIEW pnmv = (LPNMLISTVIEW)lParam;
                    g_iDragSource = pnmv->iItem;
                    g_bDragging = TRUE;
                    SetCapture(hwnd);
                    SetCursor(LoadCursor(NULL, IDC_SIZENS));
                }
            }
            break;
        }
        case WM_MOUSEMOVE: {
            if (g_bDragging) {
                LVHITTESTINFO ht;
                ht.pt.x = LOWORD(lParam); ht.pt.y = HIWORD(lParam);
                ClientToScreen(hwnd, &ht.pt);
                ScreenToClient(g_hList, &ht.pt);
                ListView_HitTest(g_hList, &ht);
                if (ht.iItem >= 0) {
                    ListView_SetItemState(g_hList, ht.iItem, LVIS_DROPHILITED, LVIS_DROPHILITED);
                }
            }
            break;
        }
        case WM_LBUTTONUP: {
            if (g_bDragging) {
                g_bDragging = FALSE; ReleaseCapture();
                LVHITTESTINFO ht;
                ht.pt.x = LOWORD(lParam); ht.pt.y = HIWORD(lParam);
                ClientToScreen(hwnd, &ht.pt); ScreenToClient(g_hList, &ht.pt);
                ListView_HitTest(g_hList, &ht);
                
                for (int i = 0; i < g_menuCount; i++) ListView_SetItemState(g_hList, i, 0, LVIS_DROPHILITED);
                
                g_iDropTarget = ht.iItem;
                if (g_iDropTarget >= 0 && g_iDropTarget != g_iDragSource) {
                    SysMenu temp = g_menus[g_iDragSource];
                    if (g_iDragSource < g_iDropTarget) {
                        memmove(&g_menus[g_iDragSource], &g_menus[g_iDragSource + 1], (g_iDropTarget - g_iDragSource) * sizeof(SysMenu));
                    } else {
                        memmove(&g_menus[g_iDropTarget + 1], &g_menus[g_iDropTarget], (g_iDragSource - g_iDropTarget) * sizeof(SysMenu));
                    }
                    g_menus[g_iDropTarget] = temp;
                    ReassignIDsAndSave();
                    RefreshListView();
                    ListView_SetItemState(g_hList, g_iDropTarget, LVIS_SELECTED | LVIS_FOCUSED, LVIS_SELECTED | LVIS_FOCUSED);
                }
            }
            break;
        }
        case WM_COMMAND: {
            int sel = ListView_GetNextItem(g_hList, -1, LVNI_SELECTED);
            switch (LOWORD(wParam)) {
                case ID_BTN_SAVE: ApplyEdits(); break;
                case ID_BTN_ADD: AddNewItem(); break;
                case ID_BTN_DEL: if (sel >= 0) DeleteSysMenuRow(sel); break;
                case ID_BTN_DELSUB: 
                    if (sel >= 0 && !g_bQueryMode && MessageBox(hwnd, "Delete this menu and ALL downstream submenus recursively?", "Confirm", MB_YESNO) == IDYES) {
                        RecursiveDeleteSubmenus(g_menus[sel].menuid, 0); LoadData(); RefreshListView();
                    } break;
                case ID_BTN_COPY: 
                    if (sel >= 0) { g_clipboard = g_menus[sel]; g_hasClipboard = true; } break;
                case ID_BTN_PASTE: 
                    if (g_hasClipboard) {
                        char new_id[64]; snprintf(new_id, sizeof(new_id), "%s_COPY", g_clipboard.menuid);
                        InsertItemToDB(new_id, &g_clipboard);
                        LoadData(); RefreshListView();
                    } break;
                case ID_BTN_DUP:
                    if (sel >= 0) {
                        char new_id[64]; snprintf(new_id, sizeof(new_id), "%s_DUP", g_menus[sel].menuid);
                        InsertItemToDB(new_id, &g_menus[sel]);
                        LoadData(); RefreshListView();
                    } break;
                case ID_BTN_ORPHAN: FindOrphans(); break;
                case ID_BTN_RENUM: 
                    if (!g_bQueryMode && MessageBox(hwnd, "Renumber ALL menus to shortest IDs (1, 2, 3...)?\nThis will update all links.", "Confirm", MB_YESNO) == IDYES) PerformRenumbering(NULL, true); 
                    break;
                case ID_BTN_RENUMSEC: {
                    if (g_bQueryMode) break;
                    WORD dlgTemplate[512] = {0};
                    LPDLGTEMPLATE lpdt = (LPDLGTEMPLATE)dlgTemplate;
                    lpdt->style = WS_POPUP | WS_BORDER | WS_SYSMENU | DS_MODALFRAME | WS_CAPTION;
                    lpdt->cdit = 0; lpdt->x = 10; lpdt->y = 10; lpdt->cx = 120; lpdt->cy = 60;
                    if (DialogBoxIndirect(GetModuleHandle(NULL), lpdt, hwnd, PrefixDlgProc) == IDOK && strlen(g_szPrefixInput) > 0) {
                        PerformRenumbering(g_szPrefixInput, false);
                    }
                    break;
                }
                case ID_BTN_TEST: OpenTestConsole(); break;
                case ID_BTN_MODE:
                    g_bQueryMode = !g_bQueryMode;
                    UpdateModeUI();
                    break;
            }
            break;
        }
        case WM_DESTROY:
            if (g_hBlackBrush) DeleteObject(g_hBlackBrush);
            sqlite3_close(g_db);
            PostQuitMessage(0); return 0;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    INITCOMMONCONTROLSEX icex = { sizeof(INITCOMMONCONTROLSEX), ICC_LISTVIEW_CLASSES };
    InitCommonControlsEx(&icex);
    
    sqlite3_open("db.db", &g_db);
    
    WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_HREDRAW|CS_VREDRAW, WndProc, 0, 0, hInstance, NULL, LoadCursor(NULL,IDC_ARROW), (HBRUSH)(COLOR_WINDOW), NULL, "FSMEditor", NULL };
    RegisterClassEx(&wc);
    
    g_hWnd = CreateWindowEx(0, "FSMEditor", "Sys_Menu Advanced Visual Editor - [MODE: SYS_MENU]", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 1080, 720, NULL, NULL, hInstance, NULL);
    
    ShowWindow(g_hWnd, nCmdShow); UpdateWindow(g_hWnd);
    MSG msg; while (GetMessage(&msg, NULL, 0, 0)) { TranslateMessage(&msg); DispatchMessage(&msg); }
    return (int)msg.wParam;
}