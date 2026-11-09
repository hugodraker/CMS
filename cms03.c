/* ============================================================================
 * TextUI Dispatch System (cms03.c)
 * 
 * Features:
 *   - Native Win32 C server using SQLite3 (`sqlite3.h`).
 *   - Implements the dynamic `sys_menu` FSM engine.
 *   - Multi-client TCP Server (Port 23): Telnet & Binary UI clients.
 *   - Embedded HTTP Server (Port 8080): Modern mobile-friendly Web GUI.
 *       * Translates FSM nodes into HTML5 Date/Time widgets and buttons.
 *
 * COMPILATION (MinGW GCC):
 *  gcc -Os -s -mwindows -o cms03.exe cms03.c sqlite3.c -lws2_32 -lcomctl32 -lgdi32 -lcomdlg32 -lshell32
 * ============================================================================ */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winsock2.h>
#include <commctrl.h>
#include <commdlg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <shellapi.h>
#include "sqlite3.h"

#define BIND_PORT           23
#define HTTP_PORT           8080
#define MAX_CLIENTS         64

/* Menu IDs */
#define IDM_FILE_EXPORT_DB  101
#define IDM_FILE_IMPORT_DB  102
#define IDM_FILE_EXPORT_CSV 103
#define IDM_FILE_IMPORT_CSV 104
#define IDM_FILE_EXIT       105
#define IDM_SETUP_USER      106
#define IDM_SETUP_EMAIL     107
#define IDM_SERVER_ON       108
#define IDM_SERVER_OFF      109
#define IDM_CONN_CHECK      110
#define IDM_CONN_SQL        111
#define IDM_CONN_TELNET     112
#define IDM_CONN_CMD        113
#define IDM_CONN_CLOSE      114
#define IDM_CONN_CLOSEALL   115
#define IDM_SERVER_WEB_ON   116
#define IDM_SERVER_WEB_OFF  117

/* Control IDs */
#define ID_LIST_CONNS       2001
#define ID_TERMINAL_EDIT    2002
#define ID_SQL_EXECUTE      3001
#define ID_SQL_CLOSE        3002
#define ID_USER_ADD         3003
#define ID_USER_APPLY       3004
#define ID_USER_CLOSE       3005
#define ID_USER_LIST        3006
#define ID_CSV_IMPORT       3007
#define ID_CSV_EXPORT       3008
#define ID_CSV_LIST         3009

/* ============================================================================
 * GLOBALS
 * ============================================================================ */
sqlite3 *g_db = NULL;
static SOCKET g_listen_sock = INVALID_SOCKET;
static SOCKET g_http_sock = INVALID_SOCKET;

static HWND g_hMainWnd, g_hListConns, g_hTerminalEdit;
static HWND g_hSqlWnd, g_hSqlEdit1, g_hSqlEdit2;
static HWND g_hUserWnd, g_hUserList, g_hUserInput[13];
static HWND g_hCsvWnd, g_hCsvList, g_hCsvBtnImp, g_hCsvBtnExp;
static WNDPROC g_OldTerminalProc;
static HBRUSH g_hBlackBrush;

typedef struct {
    SOCKET sock;
    int is_http;
    char userid[32];
    char branch[64];
    char rx_buf[1024];
    int rx_len;
    char stack[10][64];
    int stack_count;
    char login_buf[64];
    char pass_buf[64];
} ClientContext;

static ClientContext g_clients[MAX_CLIENTS];
static char g_terminal_cmd[128] = {0};
static char g_aQueryCache[100][2][4096];
static int g_query_cache_count = 0;

/* ============================================================================
 * UTILITIES & DB HELPERS
 * ============================================================================ */
static void TrimStr(char *str) {
    char *p = str;
    while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n') p++;
    if (p != str) memmove(str, p, strlen(p) + 1);
    size_t len = strlen(str);
    while (len > 0 && (str[len - 1] == ' ' || str[len - 1] == '\t' || str[len - 1] == '\r' || str[len - 1] == '\n')) {
        str[--len] = '\0';
    }
}

static void str_replace_all(char *str, const char *find, const char *replace) {
    if (!str || !find || !replace) return;
    size_t find_len = strlen(find);
    if (find_len == 0) return;
    size_t rep_len = strlen(replace);
    char temp[8192] = {0}; char *insert = temp; char *p = str;
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

static void UrlDecode(char *str) {
    char *pstr = str, *buf = malloc(strlen(str) + 1), *pbuf = buf;
    while (*pstr) {
        if (*pstr == '%') {
            if (pstr[1] && pstr[2]) {
                int c; sscanf(pstr + 1, "%2x", &c);
                *pbuf++ = (char)c; pstr += 3;
            } else pstr++;
        } else if (*pstr == '+') { *pbuf++ = ' '; pstr++; }
        else { *pbuf++ = *pstr++; }
    }
    *pbuf = '\0'; strcpy(str, buf); free(buf);
}

static void _CacheQueries() {
    char **res; int r, c;
    if (sqlite3_get_table(g_db, "SELECT name, query FROM sql_queries;", &res, &r, &c, NULL) == SQLITE_OK) {
        g_query_cache_count = 0;
        for (int i = 1; i <= r && i < 100; i++) {
            strncpy(g_aQueryCache[g_query_cache_count][0], res[i*c+0], 4095);
            strncpy(g_aQueryCache[g_query_cache_count][1], res[i*c+1], 4095);
            g_query_cache_count++;
        }
        sqlite3_free_table(res);
    }
}

static void _GetQuery(char *out, const char *name, const char *p1, const char *p2, const char *p3) {
    out[0] = '\0';
    for (int i = 0; i < g_query_cache_count; i++) {
        if (strcmp(g_aQueryCache[i][0], name) == 0) {
            strcpy(out, g_aQueryCache[i][1]);
            break;
        }
    }
    if (p1) str_replace_all(out, "{1}", p1);
    if (p2) str_replace_all(out, "{2}", p2);
    if (p3) str_replace_all(out, "{3}", p3);
}

static void _SQLConsoleAddlog(const char *query) {
    int len = GetWindowTextLength(g_hSqlEdit2);
    SendMessage(g_hSqlEdit2, EM_SETSEL, len, len);
    SendMessage(g_hSqlEdit2, EM_REPLACESEL, 0, (LPARAM)query);
    SendMessage(g_hSqlEdit2, EM_REPLACESEL, 0, (LPARAM)"\r\n");

    char safe_q[4096]; strncpy(safe_q, query, 4095);
    str_replace_all(safe_q, "'", "''");
    char log_q[4096];
    _GetQuery(log_q, "INSERT_LOG_QUERY", safe_q, "NOW", NULL);
    if (strlen(log_q) > 0) sqlite3_exec(g_db, log_q, NULL, NULL, NULL);
}

/* ============================================================================
 * STACK & TYPST
 * ============================================================================ */
static void pushstack(ClientContext *c, const char *val) {
    if (!val || strlen(val) == 0) return;
    if (c->stack_count < 10) strncpy(c->stack[c->stack_count++], val, 63);
    else {
        for (int i = 1; i < 10; i++) strcpy(c->stack[i - 1], c->stack[i]);
        strncpy(c->stack[9], val, 63);
    }
}
static const char* popstack(ClientContext *c, int count) {
    static char ret[64]; ret[0] = '\0';
    if (count < 1) return ret;
    if (c->stack_count >= count) {
        strcpy(ret, c->stack[c->stack_count - count]); c->stack_count -= count;
    } else if (c->stack_count > 0) { strcpy(ret, c->stack[0]); c->stack_count = 0; }
    return ret;
}
static const char* readstack(ClientContext *c, int depth) {
    if (c->stack_count < depth || depth < 1) return "";
    return c->stack[c->stack_count - depth];
}

static void Typst_Generate(const char *type, const char *id) {
    CreateDirectory("Dispatch", NULL); CreateDirectory("Quote", NULL);
    char fn[256];
    if (strcmp(type, "SC") == 0) sprintf(fn, "Dispatch/%s%08d.typ", type, atoi(id));
    else sprintf(fn, "Quote/%s%07d.typ", type, atoi(id));
    FILE *fp = fopen(fn, "w");
    if (fp) {
        fprintf(fp, "#set page(width: 612pt, height: 792pt, margin: 42pt)\n#set text(size: 12pt, font: \"Helvetica\")\n\n#align(center)[= Document %s %s]\n", type, id);
        fclose(fp);
    }
}

/* ============================================================================
 * DYNAMIC SQL MENU ENGINE (FSM CORE)
 * ============================================================================ */
static const char* check_num(int num) {
    static char buf[16]; snprintf(buf, sizeof(buf), "%d", num); return buf;
}

static void loadmenu(ClientContext *c, const char *typed_in) {
    char typedtext[1024]; strncpy(typedtext, typed_in, sizeof(typedtext) - 1); typedtext[1023] = '\0';
    
    if (strlen(c->branch) == 0) {
        char query[256]; _GetQuery(query, "GET_USER_MENU", c->userid, NULL, NULL);
        char **res; int r, cl;
        if (sqlite3_get_table(g_db, query, &res, &r, &cl, NULL) == SQLITE_OK) {
            if (r > 0 && res[1]) strcpy(c->branch, res[1]); else strcpy(c->branch, "100");
            sqlite3_free_table(res);
        }
    }

    while (1) {
        char query[1024]; _GetQuery(query, "GET_SYS_MENU", c->branch, NULL, NULL);
        char **res; int rows, cols;
        if (sqlite3_get_table(g_db, query, &res, &rows, &cols, NULL) != SQLITE_OK) return;
        
        if (rows == 0) {
            char out[128]; snprintf(out, sizeof(out), "Menu not found: %s\r\n", c->branch);
            if (c->is_http) { sqlite3_free_table(res); return; }
            if (c == &g_clients[0]) SetWindowTextA(g_hTerminalEdit, out);
            else send(c->sock, out, strlen(out), 0);
            sqlite3_free_table(res); return;
        }

        char buf[8192] = {0}; int num = 1; char rowid[128] = {0}; int continue_loop = 0;

        for (int i = 1; i <= rows; i++) {
            const char *menuid = res[i*cols+0]?res[i*cols+0]:"";
            const char *menutext = res[i*cols+1]?res[i*cols+1]:"";
            const char *nextbranch = res[i*cols+2]?res[i*cols+2]:"";
            const char *prevbranch = res[i*cols+3]?res[i*cols+3]:"";
            char readq[4096]; strcpy(readq, res[i*cols+4]?res[i*cols+4]:"");
            char writeq[4096]; strcpy(writeq, res[i*cols+5]?res[i*cols+5]:"");

            char safe_typed[1024]; strcpy(safe_typed, typedtext); str_replace_all(safe_typed, "'", "''");
            str_replace_all(readq, "$userid", c->userid); str_replace_all(writeq, "$userid", c->userid);

            if (strcmp(menutext, "screport") == 0 || strcmp(menutext, "qreport") == 0 || strcmp(menutext, "psreport") == 0 || strcmp(menutext, "invoice") == 0) {
                strcpy(c->branch, nextbranch);
                str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$prowid", readstack(c, 2));
                str_replace_all(writeq, "$pprowid", readstack(c, 3)); str_replace_all(writeq, "$ppprowid", readstack(c, 4));
                str_replace_all(writeq, "$typedtext", safe_typed);
                if (strlen(writeq) > 0) sqlite3_exec(g_db, writeq, NULL, NULL, NULL);
                str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$typedtext", safe_typed);
                char **rq; int rr, rc;
                if (strlen(readq) > 0 && sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                    if (rr > 0 && rq[rc]) {
                        strcpy(rowid, rq[rc]);
                        if (strcmp(menutext, "screport") == 0) Typst_Generate("SC", rowid);
                        if (strcmp(menutext, "qreport") == 0) Typst_Generate("Q", rowid);
                        if (strcmp(menutext, "psreport") == 0) Typst_Generate("PS", rowid);
                        if (strcmp(menutext, "invoice") == 0) Typst_Generate("I", rowid);
                    }
                    sqlite3_free_table(rq);
                }
                typedtext[0] = '\0'; pushstack(c, rowid); continue_loop = 1; break;
            }
            else if (strcmp(menutext, "ml") == 0) {
                strcpy(c->branch, nextbranch);
                str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$typedtext", safe_typed);
                if (strlen(writeq) > 0) sqlite3_exec(g_db, writeq, NULL, NULL, NULL);
                typedtext[0] = '\0'; continue_loop = 1; break;
            }
            else if (strcmp(menutext, "") == 0 && strcmp(nextbranch, prevbranch) == 0) {
                strcpy(c->branch, nextbranch);
                str_replace_all(writeq, "$rowid", readstack(c, 1)); str_replace_all(writeq, "$prowid", readstack(c, 2));
                str_replace_all(writeq, "$pprowid", readstack(c, 3)); str_replace_all(writeq, "$ppprowid", readstack(c, 4));
                str_replace_all(writeq, "$typedtext", safe_typed);
                if (strlen(writeq) > 0) sqlite3_exec(g_db, writeq, NULL, NULL, NULL);
                
                str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$prowid", readstack(c, 2));
                str_replace_all(readq, "$pprowid", readstack(c, 3)); str_replace_all(readq, "$ppprowid", readstack(c, 4));
                str_replace_all(readq, "$typedtext", safe_typed);
                char **rq; int rr, rc;
                if (strlen(readq) > 0 && sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                    if (rr > 0 && rq[rc]) strcpy(rowid, rq[rc]);
                    sqlite3_free_table(rq);
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
                    sqlite3_exec(g_db, writeq, NULL, NULL, NULL);
                    
                    if (strlen(readq) > 0) {
                        str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$prowid", readstack(c, 2));
                        str_replace_all(readq, "$pprowid", readstack(c, 3)); str_replace_all(readq, "$ppprowid", readstack(c, 4));
                        str_replace_all(readq, "$typedtext", safe_typed);
                        char **rq; int rr, rc;
                        if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                            if (rr > 0 && rq[rc]) pushstack(c, rq[rc]);
                            sqlite3_free_table(rq);
                        }
                    }
                } else if (strlen(writeq) > 0) pushstack(c, typedtext);
                strcpy(c->branch, prevbranch); typedtext[0] = '\0'; continue_loop = 1; break;
            }
            else if (strcmp(menutext, "SQLMenu") == 0) {
                str_replace_all(readq, "$rowid", readstack(c, 1)); str_replace_all(readq, "$prowid", readstack(c, 2));
                str_replace_all(readq, "$pprowid", readstack(c, 2)); /* AutoIt quirk */ 
                str_replace_all(readq, "$ppprowid", readstack(c, 3)); str_replace_all(readq, "$typedtext", readstack(c, 3));
                
                char **rq; int rr, rc;
                if (strlen(readq) > 0 && sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                    int n = num;
                    for (int x = 1; x <= rr; x++) {
                        char line[512]; snprintf(line, sizeof(line), " %2d. %s\r\n", n, rq[x*rc + 1] ? rq[x*rc + 1] : "");
                        strcat(buf, line);
                        char check_typed[16]; snprintf(check_typed, sizeof(check_typed), "%d", n);
                        if (strcmp(writeq, "c") == 0) strcpy(check_typed, "1");
                        
                        if (strcmp(typedtext, check_typed) == 0) {
                            strcpy(rowid, rq[x*rc + 0] ? rq[x*rc + 0] : "");
                            str_replace_all(writeq, "$rowid", rowid);
                            str_replace_all(writeq, "$prowid", readstack(c, 1));
                            str_replace_all(writeq, "$pprowid", readstack(c, 2));
                            str_replace_all(writeq, "$ppprowid", readstack(c, 3));
                            if (strcmp(writeq, "c") != 0 && strlen(writeq) > 0) sqlite3_exec(g_db, writeq, NULL, NULL, NULL);
                            strcpy(c->branch, nextbranch); typedtext[0] = '\0'; pushstack(c, rowid);
                            continue_loop = 1; break;
                        }
                        n++;
                    }
                    num = n - 1; sqlite3_free_table(rq);
                    if (continue_loop) break;
                }
            }
            else if (strcmp(typedtext, check_num(num)) == 0 && strcmp(nextbranch, prevbranch) != 0 && strcmp(menutext, "SQLMenu") != 0) {
                strcpy(c->branch, nextbranch); typedtext[0] = '\0'; pushstack(c, rowid); continue_loop = 1; break;
            }
            else if (strcmp(nextbranch, prevbranch) != 0 && strcmp(menutext, "SQLMenu") != 0 && strlen(menutext) > 0) {
                char dynamic_res[256] = {0};
                if (strlen(readq) > 0 && strlen(readstack(c, 1)) > 0) {
                    str_replace_all(readq, "$rowid", readstack(c, 1));
                    str_replace_all(readq, "$prowid", readstack(c, 2));
                    str_replace_all(readq, "$pprowid", readstack(c, 3));
                    str_replace_all(readq, "$ppprowid", readstack(c, 4));
                    char **rq; int rr, rc;
                    if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                        if (rr > 0 && rq[rc]) strcpy(dynamic_res, rq[rc]);
                        sqlite3_free_table(rq);
                    }
                }
                char line[512]; snprintf(line, sizeof(line), " %2d. %s%s\r\n", num, menutext, dynamic_res);
                strcat(buf, line);
            }
            num++;
        }
        
        sqlite3_free_table(res);
        if (!continue_loop) {
            if (c->is_http) return; // Headless execution completed.

            strcat(buf, "\r\n Enter choice (or 0): ");
            if (c == &g_clients[0]) {
                char full_display[8192];
                snprintf(full_display, sizeof(full_display), "\r\n === Menu %s ===\r\n\r\n%s%s", c->branch, buf, g_terminal_cmd);
                SetWindowTextA(g_hTerminalEdit, full_display);
                int len = GetWindowTextLength(g_hTerminalEdit);
                SendMessage(g_hTerminalEdit, EM_SETSEL, len, len);
                SendMessage(g_hTerminalEdit, EM_SCROLLCARET, 0, 0);
            } else {
                send(c->sock, buf, strlen(buf), 0);
            }
            break;
        }
    }
}

/* ============================================================================
 * HTTP SERVER & JSON API
 * ============================================================================ */
static void ServeJSONMenu(SOCKET client_sock, const char *branch, const char *choice) {
    // Dedicated Web Client Context (Slot 1)
    ClientContext *c = &g_clients[1];
    c->is_http = 1;
    if (strlen(c->userid) == 0) { strcpy(c->userid, "1"); strcpy(c->branch, "100"); }
    
    if (branch && strlen(branch) > 0) strncpy(c->branch, branch, 63);
    
    // Evaluate choice implicitly updating the FSM database & state
    if (choice && strlen(choice) > 0) loadmenu(c, choice);
    
    // Construct active FSM node representation in JSON
    char query[1024];
    snprintf(query, sizeof(query), "SELECT menuid, menutext, nextid, previd, readquery FROM sys_menu WHERE menuid='%s' ORDER BY id ASC", c->branch);
    char **res; int rows, cols;
    
    char json[16384] = {0};
    strcpy(json, "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nAccess-Control-Allow-Origin: *\r\n\r\n");
    strcat(json, "{ \"title\": \"Menu "); strcat(json, c->branch); strcat(json, "\", \"items\": [");
    
    if (sqlite3_get_table(g_db, query, &res, &rows, &cols, NULL) == SQLITE_OK) {
        int num = 1; bool first = true;
        for (int i = 1; i <= rows; i++) {
            const char *menutext = res[i*cols+1] ? res[i*cols+1] : "";
            const char *nextbranch = res[i*cols+2] ? res[i*cols+2] : "";
            const char *prevbranch = res[i*cols+3] ? res[i*cols+3] : "";
            char readq[4096]; strcpy(readq, res[i*cols+4] ? res[i*cols+4] : "");
            str_replace_all(readq, "$userid", c->userid);
            
            if (strcmp(menutext, "") == 0 && strcmp(nextbranch, prevbranch) == 0) continue;
            if (strcmp(menutext, "ml") == 0) continue;
            if (isdigit((unsigned char)menutext[0]) && atoi(menutext) > 0) continue;
            if (strcmp(menutext, "bc") == 0) continue;
            
            if (strcmp(menutext, "SQLMenu") == 0) {
                str_replace_all(readq, "$rowid", readstack(c, 1)); 
                str_replace_all(readq, "$prowid", readstack(c, 2));
                str_replace_all(readq, "$pprowid", readstack(c, 2));
                str_replace_all(readq, "$ppprowid", readstack(c, 3)); 
                char **rq; int rr, rc;
                if (strlen(readq) > 0 && sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                    for (int x = 1; x <= rr; x++) {
                        if (!first) strcat(json, ",");
                        first = false;
                        const char *val_col = (rc > 1) ? rq[x*rc + 1] : rq[x*rc + 0];
                        char item[1024]; char safe_text[512]; strncpy(safe_text, val_col ? val_col : "", 511);
                        str_replace_all(safe_text, "\"", "\\\""); str_replace_all(safe_text, "\r", ""); str_replace_all(safe_text, "\n", " ");
                        snprintf(item, sizeof(item), "{\"id\": \"%d\", \"is_input\": false, \"text\": \"%s\"}", num, safe_text);
                        strcat(json, item); num++;
                    }
                    sqlite3_free_table(rq);
                }
            } else if (strcmp(nextbranch, prevbranch) == 0 && strlen(menutext) > 0) {
                // Determine intelligent HTML widget based on context text
                char type[32] = "text";
                char lower_text[256];
                for (int k = 0; menutext[k] && k < 255; k++) lower_text[k] = tolower(menutext[k]);
                lower_text[strlen(menutext)] = '\0';
                if (strstr(lower_text, "date")) strcpy(type, "date");
                else if (strstr(lower_text, "time") || strstr(lower_text, "arrival") || strstr(lower_text, "hour")) strcpy(type, "time");
                
                if (!first) strcat(json, ",");
                first = false;
                char item[1024]; char safe_text[512]; strncpy(safe_text, menutext, 511); str_replace_all(safe_text, "\"", "\\\"");
                snprintf(item, sizeof(item), "{\"id\": \"%d\", \"is_input\": true, \"type\": \"%s\", \"text\": \"%s\"}", num, type, safe_text);
                strcat(json, item); num++;
            } else if (strcmp(nextbranch, prevbranch) != 0 && strlen(menutext) > 0) {
                char dres[256] = {0};
                if (strlen(readq) > 0 && strlen(readstack(c, 1)) > 0) {
                    str_replace_all(readq, "$rowid", readstack(c, 1));
                    str_replace_all(readq, "$prowid", readstack(c, 2));
                    str_replace_all(readq, "$pprowid", readstack(c, 3));
                    str_replace_all(readq, "$ppprowid", readstack(c, 4));
                    char **rq; int rr, rc;
                    if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                        if (rr > 0 && rq[rc]) strncpy(dres, rq[rc], 255);
                        sqlite3_free_table(rq);
                    }
                }
                if (!first) strcat(json, ",");
                first = false;
                char item[1024]; char safe_text[512]; snprintf(safe_text, 511, "%s%s", menutext, dres);
                str_replace_all(safe_text, "\"", "\\\""); str_replace_all(safe_text, "\r", ""); str_replace_all(safe_text, "\n", " ");
                snprintf(item, sizeof(item), "{\"id\": \"%d\", \"is_input\": false, \"text\": \"%s\"}", num, safe_text);
                strcat(json, item); num++;
            }
        }
        sqlite3_free_table(res);
    }
    strcat(json, "], \"branch\": \""); strcat(json, c->branch); strcat(json, "\" }");
    send(client_sock, json, strlen(json), 0);
    closesocket(client_sock);
}

static void ServeHTMLGUI(SOCKET client_sock) {
    const char *html = 
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
        "<!DOCTYPE html><html><head><title>FSM Web GUI</title>"
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        "<style>"
        "body { font-family: 'Segoe UI', Arial, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 15px; }"
        ".card { background: #1e293b; padding: 25px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.5); max-width: 600px; margin: 20px auto; }"
        "h2 { margin-top: 0; font-weight: 400; border-bottom: 1px solid #334155; padding-bottom: 10px; color: #38bdf8; }"
        "h3 { color: #e2e8f0; margin-top: 5px; font-weight: 600; }"
        "button, .input-btn { display: block; width: 100%; padding: 14px; margin: 10px 0; background: #38bdf8; color: #0f172a; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; text-align: left; transition: background 0.2s; }"
        "button:hover, .input-btn:hover { background: #0284c7; color: #f8fafc; }"
        "button.back-btn { background: #475569; color: #f8fafc; text-align: center; margin-top: 25px; }"
        "button.back-btn:hover { background: #334155; }"
        ".input-group { background: #334155; padding: 15px; border-radius: 6px; margin: 10px 0; border: 1px solid #475569; }"
        ".input-group label { display: block; margin-bottom: 8px; font-size: 15px; font-weight: bold; color: #cbd5e1; }"
        ".flex-row { display: flex; gap: 10px; }"
        "input { flex: 1; padding: 12px; border-radius: 4px; border: 1px solid #475569; background: #1e293b; color: #f8fafc; font-size: 16px; }"
        ".input-btn { width: auto; margin: 0; padding: 12px 20px; text-align: center; }"
        "</style></head>"
        "<body><div class=\"card\">"
        "<h2>TextUI Web Dispatch</h2>"
        "<div id=\"menu-container\">Loading...</div>"
        "</div>"
        "<script>"
        "let currentBranch = '100';"
        "function loadMenu(branch, choice) {"
        "  fetch('/api/menu?branch=' + branch + (choice ? '&choice=' + encodeURIComponent(choice) : ''))"
        "    .then(res => res.json())"
        "    .then(data => {"
        "       currentBranch = data.branch;"
        "       let html = '<h3>' + data.title + '</h3>';"
        "       data.items.forEach(item => {"
        "          if (item.is_input) {"
        "             html += `<div class=\"input-group\">"
        "                        <label>${item.text}</label>"
        "                        <div class=\"flex-row\">"
        "                          <input type=\"${item.type}\" id=\"inp_${item.id}\" />"
        "                          <button class=\"input-btn\" onclick=\"submitInput('${data.branch}', '${item.id}')\">Submit</button>"
        "                        </div>"
        "                      </div>`;"
        "          } else {"
        "             html += `<button onclick=\"loadMenu('${data.branch}', '${item.id}')\">${item.id}. ${item.text}</button>`;"
        "          }"
        "       });"
        "       html += `<button class=\"back-btn\" onclick=\"loadMenu('${data.branch}', '0')\">0. Back / Reset</button>`;"
        "       document.getElementById('menu-container').innerHTML = html;"
        "    });"
        "}"
        "function submitInput(branch, id) {"
        "  let val = document.getElementById('inp_' + id).value;"
        "  if (!val) return;"
        "  loadMenu(branch, val);"
        "}"
        "loadMenu('100', '');"
        "</script></body></html>";

    send(client_sock, html, strlen(html), 0);
    closesocket(client_sock);
}

static void PollWebServer(void) {
    if (g_http_sock == INVALID_SOCKET) return;
    struct sockaddr_in c_addr; int a_len = sizeof(c_addr);
    SOCKET s = accept(g_http_sock, (struct sockaddr*)&c_addr, &a_len);
    if (s != INVALID_SOCKET) {
        char req[2048];
        int n = recv(s, req, sizeof(req)-1, 0);
        if (n > 0) {
            req[n] = '\0';
            if (strncmp(req, "GET /api/menu", 13) == 0) {
                char branch[64] = {0}, choice[1024] = {0};
                char *b_ptr = strstr(req, "branch=");
                if (b_ptr) sscanf(b_ptr + 7, "%63[^& \r\n]", branch);
                char *c_ptr = strstr(req, "choice=");
                if (c_ptr) {
                    sscanf(c_ptr + 7, "%1023[^& \r\n]", choice);
                    UrlDecode(choice);
                }
                ServeJSONMenu(s, branch, choice);
            } else {
                ServeHTMLGUI(s);
            }
        } else {
            closesocket(s);
        }
    }
}

/* ============================================================================
 * TELNET & WIN32 LOCAL TERMINAL EVENT LOOP
 * ============================================================================ */
static void HandleClientData(int idx) {
    ClientContext *c = &g_clients[idx];
    char temp[4096];
    int n = recv(c->sock, temp, sizeof(temp) - 1, 0);
    
    if (n < 0) {
        if (WSAGetLastError() == WSAEWOULDBLOCK) return;
        closesocket(c->sock); c->sock = INVALID_SOCKET;
        SendMessage(g_hListConns, LB_DELETESTRING, idx, 0);
        return;
    } else if (n == 0) {
        closesocket(c->sock); c->sock = INVALID_SOCKET;
        SendMessage(g_hListConns, LB_DELETESTRING, idx, 0);
        return;
    }
    
    for (int i = 0; i < n; i++) {
        if (temp[i] == '\n' || temp[i] == '\r') {
            if (c->rx_len > 0) {
                c->rx_buf[c->rx_len] = '\0';
                if (strlen(c->userid) == 0) {
                    if (strlen(c->login_buf) == 0) {
                        strcpy(c->login_buf, c->rx_buf);
                        send(c->sock, "Password: ", 10, 0);
                    } else {
                        strcpy(c->pass_buf, c->rx_buf);
                        char q[256]; _GetQuery(q, "CHECK_USER_LOGIN", c->login_buf, c->pass_buf, NULL);
                        char **res; int r, cl;
                        if (sqlite3_get_table(g_db, q, &res, &r, &cl, NULL) == SQLITE_OK && r > 0) {
                            strcpy(c->userid, res[cl+2]);
                            send(c->sock, "\r\nLogged in.\r\n", 14, 0);
                            loadmenu(c, "");
                        } else {
                            send(c->sock, "\r\nBYE\r\n", 7, 0);
                            closesocket(c->sock); c->sock = INVALID_SOCKET;
                        }
                        sqlite3_free_table(res);
                        c->login_buf[0] = '\0'; c->pass_buf[0] = '\0';
                    }
                } else {
                    loadmenu(c, c->rx_buf);
                }
                c->rx_len = 0;
            }
        } else if (temp[i] == '\b' && c->rx_len > 0) c->rx_len--;
        else if (isprint((unsigned char)temp[i]) && c->rx_len < sizeof(c->rx_buf) - 1) c->rx_buf[c->rx_len++] = temp[i];
    }
}

LRESULT CALLBACK TerminalSubclassProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_CHAR) {
        if (wParam == '\r' || wParam == '\n') {
            loadmenu(&g_clients[0], g_terminal_cmd); g_terminal_cmd[0] = '\0';
            loadmenu(&g_clients[0], ""); 
        } else if (wParam == '\b' && strlen(g_terminal_cmd) > 0) {
            g_terminal_cmd[strlen(g_terminal_cmd) - 1] = '\0'; loadmenu(&g_clients[0], "");
        } else if (isprint((unsigned char)wParam) && strlen(g_terminal_cmd) < 127) {
            g_terminal_cmd[strlen(g_terminal_cmd)] = (char)wParam; g_terminal_cmd[strlen(g_terminal_cmd) + 1] = '\0';
            loadmenu(&g_clients[0], "");
        }
        return 0;
    } else if (msg == WM_KEYDOWN) {
        if (wParam == VK_RETURN || wParam == VK_BACK || wParam == VK_ESCAPE || wParam == VK_DELETE) return 0;
    } else if (msg == WM_LBUTTONDOWN) {
        int pos = SendMessage(hwnd, EM_CHARFROMPOS, 0, lParam);
        int line_idx = SendMessage(hwnd, EM_LINEFROMCHAR, LOWORD(pos), 0);
        char lineBuf[256] = {0}; *((WORD*)lineBuf) = sizeof(lineBuf) - 1;
        int len = SendMessage(hwnd, EM_GETLINE, line_idx, (LPARAM)lineBuf); lineBuf[len] = '\0';
        
        int choice = -1;
        if (sscanf(lineBuf, " %d.", &choice) == 1 || sscanf(lineBuf, "%d.", &choice) == 1) {
            char ch_str[16]; snprintf(ch_str, 15, "%d", choice);
            loadmenu(&g_clients[0], ch_str); g_terminal_cmd[0] = '\0'; loadmenu(&g_clients[0], "");
        }
    } else if (msg == WM_PASTE || msg == WM_CUT || msg == WM_COPY) return 0;
    return CallWindowProc(g_OldTerminalProc, hwnd, msg, wParam, lParam);
}

/* ============================================================================
 * MAIN WINDOW PROCEDURE & UI SETUP
 * ============================================================================ */
LRESULT CALLBACK DialogWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_COMMAND) {
        if (LOWORD(wParam) == ID_SQL_CLOSE || LOWORD(wParam) == ID_USER_CLOSE) {
            ShowWindow(hwnd, SW_HIDE);
        } else if (LOWORD(wParam) == ID_SQL_EXECUTE) {
            char query[4096]; GetWindowTextA(g_hSqlEdit1, query, sizeof(query));
            _SQLConsoleAddlog(query);
            char **res; int r, c; char *err;
            if (sqlite3_get_table(g_db, query, &res, &r, &c, &err) == SQLITE_OK) {
                char out[8192] = {0};
                for (int i = 0; i <= r; i++) {
                    for (int j = 0; j < c; j++) {
                        strcat(out, res[i*c+j]?res[i*c+j]:""); strcat(out, (j==c-1)?"":"\t");
                    }
                    strcat(out, "\r\n");
                }
                strcat(query, "\r\n"); strcat(query, out);
                SetWindowTextA(g_hSqlEdit1, query);
                sqlite3_free_table(res);
            } else {
                char err_buf[512]; snprintf(err_buf, sizeof(err_buf), "\r\nERROR: %s", err);
                strcat(query, err_buf); SetWindowTextA(g_hSqlEdit1, query); sqlite3_free(err);
            }
        }
    } else if (msg == WM_CLOSE) {
        ShowWindow(hwnd, SW_HIDE); return 0;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

LRESULT CALLBACK MainWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE: {
            // Build Menus
            HMENU hMenu = CreateMenu();
            HMENU hServer = CreatePopupMenu();
            AppendMenu(hServer, MF_STRING, IDM_SERVER_ON, "Start Telnet Server (23)");
            AppendMenu(hServer, MF_STRING, IDM_SERVER_OFF, "Stop Telnet Server");
            AppendMenu(hServer, MF_SEPARATOR, 0, NULL);
            AppendMenu(hServer, MF_STRING, IDM_SERVER_WEB_ON, "Start Web GUI (8080)");
            AppendMenu(hServer, MF_STRING, IDM_SERVER_WEB_OFF, "Stop Web GUI");
            AppendMenu(hMenu, MF_POPUP, (UINT_PTR)hServer, "Server");
            
            HMENU hConn = CreatePopupMenu();
            AppendMenu(hConn, MF_STRING, IDM_CONN_SQL, "SQL Console");
            AppendMenu(hConn, MF_STRING, IDM_CONN_TELNET, "Telnet CMD");
            AppendMenu(hMenu, MF_POPUP, (UINT_PTR)hConn, "Tools");
            SetMenu(hwnd, hMenu);

            // Build GUI Widgets
            HFONT hFont = CreateFont(16,0,0,0,FW_NORMAL,0,0,0,ANSI_CHARSET,0,0,DEFAULT_QUALITY,DEFAULT_PITCH,"Segoe UI");
            HFONT hMono = CreateFont(16,0,0,0,FW_NORMAL,0,0,0,ANSI_CHARSET,0,0,DEFAULT_QUALITY,FIXED_PITCH,"Consolas");
            g_hBlackBrush = CreateSolidBrush(RGB(0, 0, 0));

            CreateWindow("STATIC", "Connections:", WS_CHILD|WS_VISIBLE, 10, 10, 180, 20, hwnd, NULL, NULL, NULL);
            g_hListConns = CreateWindowEx(WS_EX_CLIENTEDGE, "LISTBOX", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL, 10, 30, 180, 420, hwnd, (HMENU)ID_LIST_CONNS, NULL, NULL);
            g_hTerminalEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL|ES_MULTILINE|ES_READONLY, 200, 10, 620, 440, hwnd, (HMENU)ID_TERMINAL_EDIT, NULL, NULL);
            SendMessage(g_hListConns, WM_SETFONT, (WPARAM)hFont, TRUE);
            SendMessage(g_hTerminalEdit, WM_SETFONT, (WPARAM)hMono, TRUE);

            g_OldTerminalProc = (WNDPROC)SetWindowLongPtr(g_hTerminalEdit, GWLP_WNDPROC, (LONG_PTR)TerminalSubclassProc);
            for (int i = 0; i < MAX_CLIENTS; i++) g_clients[i].sock = INVALID_SOCKET;

            // Initialize Local Terminal Context (Slot 0)
            strcpy(g_clients[0].userid, "1"); strcpy(g_clients[0].branch, "");
            loadmenu(&g_clients[0], "");

            // Pre-create SQL Window Dialog (Hidden)
            WNDCLASSEX wcDlg = { sizeof(WNDCLASSEX), CS_HREDRAW | CS_VREDRAW, DialogWndProc, 0, 0, GetModuleHandle(NULL), NULL, LoadCursor(NULL, IDC_ARROW), (HBRUSH)(COLOR_WINDOW), NULL, "DialogClass", NULL };
            RegisterClassEx(&wcDlg);
            g_hSqlWnd = CreateWindowEx(WS_EX_DLGMODALFRAME, "DialogClass", "SQL Console", WS_POPUP|WS_CAPTION|WS_SYSMENU, 100, 100, 615, 480, hwnd, NULL, NULL, NULL);
            g_hSqlEdit2 = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL, 11, 9, 589, 225, g_hSqlWnd, NULL, NULL, NULL);
            g_hSqlEdit1 = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL, 11, 240, 589, 153, g_hSqlWnd, NULL, NULL, NULL);
            CreateWindow("BUTTON", "Execute Query", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 10, 396, 276, 34, g_hSqlWnd, (HMENU)ID_SQL_EXECUTE, NULL, NULL);
            CreateWindow("BUTTON", "Close", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 326, 396, 276, 33, g_hSqlWnd, (HMENU)ID_SQL_CLOSE, NULL, NULL);
            SendMessage(g_hSqlEdit1, WM_SETFONT, (WPARAM)hFont, TRUE); SendMessage(g_hSqlEdit2, WM_SETFONT, (WPARAM)hFont, TRUE);

            SetTimer(hwnd, 1, 20, NULL);
            break;
        }
        case WM_COMMAND: {
            if (LOWORD(wParam) == IDM_CONN_SQL) ShowWindow(g_hSqlWnd, SW_SHOW);
            else if (LOWORD(wParam) == IDM_CONN_TELNET) ShellExecute(NULL, "open", "telnet.exe", "127.0.0.1 23", NULL, SW_SHOW);
            else if (LOWORD(wParam) == IDM_SERVER_ON && g_listen_sock == INVALID_SOCKET) {
                g_listen_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
                u_long non_block = 1; ioctlsocket(g_listen_sock, FIONBIO, &non_block);
                struct sockaddr_in telnet_srv_addr = {0}; 
                telnet_srv_addr.sin_family = AF_INET;
                telnet_srv_addr.sin_port = htons(BIND_PORT); 
                telnet_srv_addr.sin_addr.s_addr = INADDR_ANY;
                bind(g_listen_sock, (struct sockaddr*)&telnet_srv_addr, sizeof(telnet_srv_addr));
                listen(g_listen_sock, 8);
                MessageBox(hwnd, "Telnet Server Started on Port 23.", "Info", MB_OK);
            }
            else if (LOWORD(wParam) == IDM_SERVER_OFF && g_listen_sock != INVALID_SOCKET) {
                closesocket(g_listen_sock); g_listen_sock = INVALID_SOCKET;
                for (int i = 1; i < MAX_CLIENTS; i++) if (g_clients[i].sock != INVALID_SOCKET && !g_clients[i].is_http) {
                    closesocket(g_clients[i].sock); g_clients[i].sock = INVALID_SOCKET;
                    SendMessage(g_hListConns, LB_DELETESTRING, i, 0);
                }
            }
            else if (LOWORD(wParam) == IDM_SERVER_WEB_ON && g_http_sock == INVALID_SOCKET) {
                g_http_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
                u_long non_block = 1; ioctlsocket(g_http_sock, FIONBIO, &non_block);
                struct sockaddr_in web_srv_addr = {0}; 
                web_srv_addr.sin_family = AF_INET;
                web_srv_addr.sin_port = htons(HTTP_PORT); 
                web_srv_addr.sin_addr.s_addr = INADDR_ANY;
                bind(g_http_sock, (struct sockaddr*)&web_srv_addr, sizeof(web_srv_addr));
                listen(g_http_sock, 16);
                MessageBox(hwnd, "Web GUI Server Started on http://localhost:8080/", "Info", MB_OK);
            }
            else if (LOWORD(wParam) == IDM_SERVER_WEB_OFF && g_http_sock != INVALID_SOCKET) {
                closesocket(g_http_sock); g_http_sock = INVALID_SOCKET;
            }
            break;
        }
        case WM_CTLCOLOREDIT: case WM_CTLCOLORSTATIC: {
            if ((HWND)lParam == g_hTerminalEdit) {
                SetTextColor((HDC)wParam, RGB(250, 250, 250)); SetBkColor((HDC)wParam, RGB(0, 0, 0));
                return (LRESULT)g_hBlackBrush;
            } break;
        }
        case WM_TIMER: {
            // Telnet Accept Loop
            if (g_listen_sock != INVALID_SOCKET) {
                struct sockaddr_in client_addr; int addr_len = sizeof(client_addr);
                SOCKET s = accept(g_listen_sock, (struct sockaddr*)&client_addr, &addr_len);
                if (s != INVALID_SOCKET) {
                    u_long mode = 1; ioctlsocket(s, FIONBIO, &mode);
                    int slot = -1;
                    for (int i = 2; i < MAX_CLIENTS; i++) {
                        if (g_clients[i].sock == INVALID_SOCKET) { slot = i; break; }
                    }
                    if (slot != -1) {
                        g_clients[slot].sock = s; g_clients[slot].stack_count = 0; g_clients[slot].is_http = 0;
                        g_clients[slot].userid[0] = '\0'; g_clients[slot].branch[0] = '\0';
                        char buf[128]; snprintf(buf, sizeof(buf), "[Slot %d] %s", slot, inet_ntoa(client_addr.sin_addr));
                        SendMessage(g_hListConns, LB_ADDSTRING, 0, (LPARAM)buf);
                        send(s, "Login: ", 7, 0);
                    } else closesocket(s);
                }
                for (int i = 2; i < MAX_CLIENTS; i++) {
                    if (g_clients[i].sock != INVALID_SOCKET && !g_clients[i].is_http) HandleClientData(i);
                }
            }
            // Web Server Accept Loop
            PollWebServer();
            break;
        }
        case WM_DESTROY:
            if (g_hBlackBrush) DeleteObject(g_hBlackBrush);
            if (g_listen_sock != INVALID_SOCKET) closesocket(g_listen_sock);
            if (g_http_sock != INVALID_SOCKET) closesocket(g_http_sock);
            if (g_db) sqlite3_close(g_db);
            WSACleanup(); PostQuitMessage(0); return 0;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    WSADATA wsa; WSAStartup(MAKEWORD(2,2), &wsa);
    INITCOMMONCONTROLSEX icex = { sizeof(INITCOMMONCONTROLSEX), ICC_LISTVIEW_CLASSES }; InitCommonControlsEx(&icex);
    
    sqlite3_open("db.db", &g_db); sqlite3_exec(g_db, "PRAGMA journal_mode=WAL;", NULL, NULL, NULL);
    _CacheQueries();

    WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_HREDRAW|CS_VREDRAW, MainWndProc, 0, 0, hInstance, NULL, LoadCursor(NULL,IDC_ARROW), (HBRUSH)(COLOR_WINDOW+1), NULL, "ServerClass", NULL };
    RegisterClassEx(&wc);

    g_hMainWnd = CreateWindowEx(0, "ServerClass", "TextUI FSM Dispatch Server (with Web GUI)", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 850, 520, NULL, NULL, hInstance, NULL);

    ShowWindow(g_hMainWnd, nCmdShow); UpdateWindow(g_hMainWnd);
    MSG msg; while (GetMessage(&msg, NULL, 0, 0)) { TranslateMessage(&msg); DispatchMessage(&msg); }
    return (int)msg.wParam;
}