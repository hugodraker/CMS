/* ============================================================================
 * TextUI Dispatch Server & Engine (Win32 C / GCC)
 * 
 * Features:
 *   - Native Win32 C server using SQLite3 (`sqlite3.h`).
 *   - Implements the dynamic `sys_menu` engine.
 *   - Multi-client TCP Server (Port 23): Telnet & Binary UI clients.
 *   - AutoIt-Style Terminal GUI + Dialogs (SQL Console, Users, CSV).
 *
 * COMPILATION (MinGW GCC):
 *   gcc -Os -s -mwindows -o cms03.exe cms03.c sqlite3.c -lws2_32 -lcomctl32 -lgdi32 -lcomdlg32
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
#include "sqlite3.h"
#define BIND_PORT           23
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
static HWND g_hMainWnd, g_hListConns, g_hTerminalEdit;
static HWND g_hSqlWnd, g_hSqlEdit1, g_hSqlEdit2;
static HWND g_hUserWnd, g_hUserList, g_hUserInput[13];
static HWND g_hCsvWnd, g_hCsvList, g_hCsvBtnImp, g_hCsvBtnExp;
static WNDPROC g_OldTerminalProc;
static HBRUSH g_hBlackBrush;

typedef struct {
    SOCKET sock;
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
 * DYNAMIC SQL MENU ENGINE (Ported from AutoIt loadmenu)
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
                    char **rq; int rr, rc;
                    if (sqlite3_get_table(g_db, readq, &rq, &rr, &rc, NULL) == SQLITE_OK) {
                        if (rr > 0 && rq[rc]) strcpy(dres, rq[rc]);
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
            strcat(buf, "\r\n Enter choice (or 0): ");
            if (c == &g_clients[0]) {
                char full[8192]; snprintf(full, sizeof(full), "\r\n === Menu %s ===\r\n\r\n%s%s", c->branch, buf, g_terminal_cmd);
                SetWindowTextA(g_hTerminalEdit, full);
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
 * RLE \xA6 COMPRESSION HELPERS
 * ============================================================================ */
static unsigned char CharTo6Bit(char c) {
    if (c >= 'A' && c <= 'Z') return c - 'A';
    if (c >= 'a' && c <= 'z') return c - 'a' + 26;
    if (c >= '0' && c <= '9') return c - '0' + 52;
    if (c == ' ') return 62;
    return 63;
}
static char Bit6ToChar(unsigned char b) {
    if (b < 26) return 'A' + b;
    if (b < 52) return 'a' + (b - 26);
    if (b < 62) return '0' + (b - 52);
    if (b == 62) return ' ';
    return '\0';
}
static int Pack6Bit(const char* in, int in_len, char* out, int out_max) {
    unsigned int buf = 0; int len = 0, o = 0;
    for (int i = 0; i < in_len; i++) {
        unsigned char b6 = CharTo6Bit(in[i]); buf = (buf << 6) | b6; len += 6;
        if (b6 == 63) { buf = (buf << 8) | in[i]; len += 8; }
        while (len >= 8) { if (o >= out_max) return -1; len -= 8; out[o++] = (char)((buf >> len) & 0xFF); }
    }
    if (len > 0) { if (o >= out_max) return -1; out[o++] = (char)((buf << (8 - len)) & 0xFF); }
    return o;
}
static int Unpack6Bit(const char* in, int in_len, char* out, int out_max) {
    unsigned int buf = 0; int len = 0, i = 0, o = 0;
    while (i < in_len || len >= 6) {
        while (len < 14 && i < in_len) { buf = (buf << 8) | (unsigned char)in[i++]; len += 8; }
        if (len < 6) break;
        unsigned char b6 = (buf >> (len - 6)) & 0x3F; len -= 6;
        if (b6 == 63) {
            if (len < 8) { if (i < in_len) { buf = (buf << 8) | (unsigned char)in[i++]; len += 8; } else break; }
            unsigned char raw = (buf >> (len - 8)) & 0xFF; len -= 8;
            if (o < out_max) out[o++] = (char)raw;
            if (raw == '\0') break;
        } else { if (o < out_max) out[o++] = Bit6ToChar(b6); }
    }
    if (o < out_max) out[o] = '\0'; return o;
}
static int CompressRLE(const char* in, int in_len, char* out, int out_max) {
    int i = 0, o = 0;
    while (i < in_len && o < out_max - 4) {
        int r = 1; while (i + r < in_len && in[i + r] == in[i] && r < 255) r++;
        if (r >= 3 || in[i] == '\x1B') { out[o++] = '\x1B'; out[o++] = (char)r; out[o++] = in[i]; i += r; } 
        else { for (int j = 0; j < r; j++) out[o++] = in[i]; i += r; }
    }
    return o;
}
static int DecompressRLE(const char* in, int in_len, char* out, int out_max) {
    int i = 0, o = 0;
    while (i < in_len && o < out_max - 1) {
        if (in[i] == '\x1B') {
            if (i + 2 >= in_len) break;
            unsigned char r = (unsigned char)in[i+1]; char v = in[i+2];
            for (int j = 0; j < r && o < out_max - 1; j++) out[o++] = v; i += 3;
        } else out[o++] = in[i++];
    }
    out[o] = '\0'; return o;
}

/* ============================================================================
 * CLIENT HANDLER
 * ============================================================================ */
static void HandleClientData(int idx) {
    ClientContext *c = &g_clients[idx];
    char temp[8192];
    int n = recv(c->sock, temp, sizeof(temp) - 1, 0);
    
    if (n <= 0) {
        if (n < 0 && WSAGetLastError() == WSAEWOULDBLOCK) return;
        closesocket(c->sock); c->sock = INVALID_SOCKET;
        SendMessage(g_hListConns, LB_DELETESTRING, idx, 0);
        return;
    }
    
    if (temp[0] == '\xA6') {
        char uncomp[32768], raw[32768];
        int u_sz = DecompressRLE(temp + 1, n - 1, uncomp, sizeof(uncomp));
        Unpack6Bit(uncomp, u_sz, raw, sizeof(raw));
        char *p_user = raw, *p_pass = strstr(raw, "\xA6"), *p_query = NULL;
        if (p_pass) { *p_pass++ = '\0'; p_query = strstr(p_pass, "\xA6"); if (p_query) *p_query++ = '\0'; }
        if (!p_query) p_query = raw;

        char resp_body[65536] = {0}; char **res; int r, cl; char *err;
        if (sqlite3_get_table(g_db, p_query, &res, &r, &cl, &err) == SQLITE_OK) {
            int off = 0;
            for (int i = 0; i <= r; i++) {
                for (int j = 0; j < cl; j++) off += snprintf(resp_body + off, sizeof(resp_body) - off, "%s%s", res[i*cl+j]?res[i*cl+j]:"", (j==cl-1)?"":"\t");
                off += snprintf(resp_body + off, sizeof(resp_body) - off, "\r\n");
            }
            sqlite3_free_table(res);
        } else {
            sqlite3_exec(g_db, p_query, NULL, NULL, &err);
            if (err) { snprintf(resp_body, sizeof(resp_body), "ERROR: %s\r\n", err); sqlite3_free(err); } 
            else snprintf(resp_body, sizeof(resp_body), "SUCCESS\r\n");
        }
        char packed[65536], comp[65536];
        int p_len = Pack6Bit(resp_body, strlen(resp_body) + 1, packed, sizeof(packed));
        int c_len = CompressRLE(packed, p_len, comp, sizeof(comp));
        char send_buf[65536]; send_buf[0] = '\xA6'; memcpy(send_buf + 1, comp, c_len);
        send(c->sock, send_buf, c_len + 1, 0);
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

/* ============================================================================
 * DIALOG PROCEDURES
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
        } else if (LOWORD(wParam) == ID_USER_LIST && HIWORD(wParam) == LBN_SELCHANGE) {
            int sel = SendMessage(g_hUserList, LB_GETCURSEL, 0, 0);
            if (sel >= 0) {
                char name[128]; SendMessage(g_hUserList, LB_GETTEXT, sel, (LPARAM)name);
                char q[256]; _GetQuery(q, "GET_USER_BY_FULLNAME", name, NULL, NULL);
                char **res; int r, c;
                if (sqlite3_get_table(g_db, q, &res, &r, &c, NULL) == SQLITE_OK && r > 0) {
                    for (int i = 0; i < 13; i++) SetWindowTextA(g_hUserInput[i], res[c + i + 1] ? res[c + i + 1] : "");
                }
                sqlite3_free_table(res);
            }
        } else if (LOWORD(wParam) == ID_CSV_EXPORT || LOWORD(wParam) == ID_CSV_IMPORT) {
            int sel = SendMessage(g_hCsvList, LB_GETCURSEL, 0, 0);
            if (sel < 0) return 0;
            char tbl[128]; SendMessage(g_hCsvList, LB_GETTEXT, sel, (LPARAM)tbl);
            
            OPENFILENAMEA ofn; char szFile[260] = {0};
            ZeroMemory(&ofn, sizeof(ofn));
            ofn.lStructSize = sizeof(ofn); ofn.hwndOwner = hwnd;
            ofn.lpstrFile = szFile; ofn.nMaxFile = sizeof(szFile);
            ofn.lpstrFilter = "CSV\0*.csv\0"; ofn.nFilterIndex = 1;
            
            if (LOWORD(wParam) == ID_CSV_EXPORT) {
                ofn.Flags = OFN_PATHMUSTEXIST | OFN_OVERWRITEPROMPT;
                if (GetSaveFileNameA(&ofn)) {
                    char q[256]; snprintf(q, sizeof(q), "SELECT * FROM %s;", tbl);
                    char **res; int r, c;
                    if (sqlite3_get_table(g_db, q, &res, &r, &c, NULL) == SQLITE_OK) {
                        FILE *fp = fopen(szFile, "w");
                        for (int i = 0; i <= r; i++) {
                            for (int j = 0; j < c; j++) fprintf(fp, "\"%s\"%s", res[i*c+j]?res[i*c+j]:"", (j==c-1)?"\n":",");
                        }
                        fclose(fp); sqlite3_free_table(res);
                    }
                }
            } else {
                ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;
                if (GetOpenFileNameA(&ofn)) {
                    FILE *fp = fopen(szFile, "r");
                    if (fp) {
                        char line[4096];
                        sqlite3_exec(g_db, "BEGIN TRANSACTION;", NULL, NULL, NULL);
                        if (fgets(line, sizeof(line), fp)) {
                            TrimStr(line);
                            while (fgets(line, sizeof(line), fp)) {
                                TrimStr(line); char *tok = strtok(line, ",");
                                char q[4096]; snprintf(q, sizeof(q), "INSERT OR IGNORE INTO %s VALUES (", tbl);
                                while (tok) {
                                    strcat(q, "'"); strcat(q, tok); strcat(q, "',");
                                    tok = strtok(NULL, ",");
                                }
                                q[strlen(q)-1] = ')'; strcat(q, ";");
                                sqlite3_exec(g_db, q, NULL, NULL, NULL);
                            }
                        }
                        sqlite3_exec(g_db, "COMMIT;", NULL, NULL, NULL);
                        fclose(fp);
                    }
                }
            }
        }
    } else if (msg == WM_CLOSE) {
        ShowWindow(hwnd, SW_HIDE); return 0;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

/* ============================================================================
 * SUBCLASS PROCEDURES
 * ============================================================================ */
LRESULT CALLBACK TerminalSubclassProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_CHAR) {
        if (wParam == '\r' || wParam == '\n') {
            loadmenu(&g_clients[0], g_terminal_cmd); g_terminal_cmd[0] = '\0';
            loadmenu(&g_clients[0], ""); 
        } else if (wParam == '\b' && strlen(g_terminal_cmd) > 0) {
            g_terminal_cmd[strlen(g_terminal_cmd) - 1] = '\0'; loadmenu(&g_clients[0], "");
        } else if (isprint((unsigned char)wParam) && strlen(g_terminal_cmd) < 127) {
            g_terminal_cmd[strlen(g_terminal_cmd)] = (char)wParam; loadmenu(&g_clients[0], "");
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
LRESULT CALLBACK MainWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE: {
            // Build Menus
            HMENU hMenu = CreateMenu();
            HMENU hFile = CreatePopupMenu();
            AppendMenu(hFile, MF_STRING, IDM_FILE_EXPORT_DB, "Export DB");
            AppendMenu(hFile, MF_STRING, IDM_FILE_IMPORT_DB, "Import DB");
            AppendMenu(hFile, MF_STRING, IDM_FILE_EXPORT_CSV, "Export CSV");
            AppendMenu(hFile, MF_STRING, IDM_FILE_IMPORT_CSV, "Import CSV");
            AppendMenu(hFile, MF_SEPARATOR, 0, NULL);
            AppendMenu(hFile, MF_STRING, IDM_FILE_EXIT, "Exit");
            AppendMenu(hMenu, MF_POPUP, (UINT_PTR)hFile, "File");
            
            HMENU hSetup = CreatePopupMenu();
            AppendMenu(hSetup, MF_STRING, IDM_SETUP_USER, "Edit User");
            AppendMenu(hSetup, MF_STRING, IDM_SETUP_EMAIL, "Edit Email");
            AppendMenu(hMenu, MF_POPUP, (UINT_PTR)hSetup, "Setup");

            HMENU hServer = CreatePopupMenu();
            AppendMenu(hServer, MF_STRING, IDM_SERVER_ON, "On");
            AppendMenu(hServer, MF_STRING, IDM_SERVER_OFF, "Off");
            AppendMenu(hMenu, MF_POPUP, (UINT_PTR)hServer, "Server");

            HMENU hConn = CreatePopupMenu();
            AppendMenu(hConn, MF_STRING, IDM_CONN_CHECK, "Check connections");
            AppendMenu(hConn, MF_STRING, IDM_CONN_SQL, "SQL Console");
            AppendMenu(hConn, MF_STRING, IDM_CONN_TELNET, "Telnet Console");
            AppendMenu(hConn, MF_STRING, IDM_CONN_CMD, "Command Console");
            AppendMenu(hConn, MF_STRING, IDM_CONN_CLOSE, "Close");
            AppendMenu(hConn, MF_SEPARATOR, 0, NULL);
            AppendMenu(hConn, MF_STRING, IDM_CONN_CLOSEALL, "Close All");
            AppendMenu(hMenu, MF_POPUP, (UINT_PTR)hConn, "Connection");
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

            // Dialogs
            WNDCLASSEX wcDlg = { sizeof(WNDCLASSEX), CS_HREDRAW | CS_VREDRAW, DialogWndProc, 0, 0, GetModuleHandle(NULL), NULL, LoadCursor(NULL, IDC_ARROW), (HBRUSH)(COLOR_WINDOW), NULL, "DialogClass", NULL };
            RegisterClassEx(&wcDlg);

            // SQL Console
            g_hSqlWnd = CreateWindowEx(WS_EX_DLGMODALFRAME, "DialogClass", "SQL Console", WS_POPUP|WS_CAPTION|WS_SYSMENU, 100, 100, 615, 480, hwnd, NULL, NULL, NULL);
            g_hSqlEdit2 = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL, 11, 9, 589, 225, g_hSqlWnd, NULL, NULL, NULL);
            g_hSqlEdit1 = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL, 11, 240, 589, 153, g_hSqlWnd, NULL, NULL, NULL);
            CreateWindow("BUTTON", "Execute Query", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 10, 396, 276, 34, g_hSqlWnd, (HMENU)ID_SQL_EXECUTE, NULL, NULL);
            CreateWindow("BUTTON", "Close", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 326, 396, 276, 33, g_hSqlWnd, (HMENU)ID_SQL_CLOSE, NULL, NULL);
            SendMessage(g_hSqlEdit1, WM_SETFONT, (WPARAM)hFont, TRUE); SendMessage(g_hSqlEdit2, WM_SETFONT, (WPARAM)hFont, TRUE);

            // User Editor
            g_hUserWnd = CreateWindowEx(WS_EX_DLGMODALFRAME, "DialogClass", "Users", WS_POPUP|WS_CAPTION|WS_SYSMENU, 150, 150, 561, 450, hwnd, NULL, NULL, NULL);
            g_hUserList = CreateWindowEx(WS_EX_CLIENTEDGE, "LISTBOX", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL|LBS_NOTIFY, 16, 16, 145, 370, g_hUserWnd, (HMENU)ID_USER_LIST, NULL, NULL);
            const char *lbls[] = {"ID", "Name", "Login", "Full Name", "Phone", "Email", "Privilege", "Password", "Trusted IP", "Home Menu", "Inventory Barcode", "Disabled", "Notes"};
            for (int i = 0; i < 13; i++) {
                CreateWindow("STATIC", lbls[i], WS_CHILD|WS_VISIBLE, 176, 16 + (i * 24), 100, 20, g_hUserWnd, NULL, NULL, NULL);
                g_hUserInput[i] = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE, 280, 14 + (i * 24), 250, 21, g_hUserWnd, NULL, NULL, NULL);
            }
            CreateWindow("BUTTON", "Close", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 176, 352, 97, 33, g_hUserWnd, (HMENU)ID_USER_CLOSE, NULL, NULL);
            CreateWindow("BUTTON", "Add User", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 280, 352, 97, 33, g_hUserWnd, (HMENU)ID_USER_ADD, NULL, NULL);
            CreateWindow("BUTTON", "Apply", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 384, 352, 97, 33, g_hUserWnd, (HMENU)ID_USER_APPLY, NULL, NULL);

            // CSV Export
            g_hCsvWnd = CreateWindowEx(WS_EX_DLGMODALFRAME, "DialogClass", "Select Item", WS_POPUP|WS_CAPTION|WS_SYSMENU, 200, 200, 255, 450, hwnd, NULL, NULL, NULL);
            g_hCsvList = CreateWindowEx(WS_EX_CLIENTEDGE, "LISTBOX", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL, 16, 16, 209, 344, g_hCsvWnd, (HMENU)ID_CSV_LIST, NULL, NULL);
            g_hCsvBtnImp = CreateWindow("BUTTON", "Import CSV", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 16, 368, 209, 33, g_hCsvWnd, (HMENU)ID_CSV_IMPORT, NULL, NULL);
            g_hCsvBtnExp = CreateWindow("BUTTON", "Export CSV", WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON, 16, 368, 209, 33, g_hCsvWnd, (HMENU)ID_CSV_EXPORT, NULL, NULL);

            g_OldTerminalProc = (WNDPROC)SetWindowLongPtr(g_hTerminalEdit, GWLP_WNDPROC, (LONG_PTR)TerminalSubclassProc);
            for (int i = 0; i < MAX_CLIENTS; i++) g_clients[i].sock = INVALID_SOCKET;

            strcpy(g_clients[0].userid, "1"); strcpy(g_clients[0].branch, "");
            loadmenu(&g_clients[0], "");

            SetTimer(hwnd, 1, 20, NULL);
            break;
        }
        case WM_COMMAND: {
            if (LOWORD(wParam) == IDM_CONN_SQL) ShowWindow(g_hSqlWnd, SW_SHOW);
            else if (LOWORD(wParam) == IDM_SETUP_USER) {
                SendMessage(g_hUserList, LB_RESETCONTENT, 0, 0);
                char **res; int r, c;
                if (sqlite3_get_table(g_db, "SELECT fullname FROM user", &res, &r, &c, NULL) == SQLITE_OK) {
                    for (int i = 1; i <= r; i++) SendMessage(g_hUserList, LB_ADDSTRING, 0, (LPARAM)res[i*c]);
                    sqlite3_free_table(res);
                }
                ShowWindow(g_hUserWnd, SW_SHOW);
            }
            else if (LOWORD(wParam) == IDM_FILE_EXPORT_CSV || LOWORD(wParam) == IDM_FILE_IMPORT_CSV) {
                SendMessage(g_hCsvList, LB_RESETCONTENT, 0, 0);
                char **res; int r, c;
                if (sqlite3_get_table(g_db, "SELECT tbl_name FROM sqlite_master WHERE type='table'", &res, &r, &c, NULL) == SQLITE_OK) {
                    for (int i = 1; i <= r; i++) SendMessage(g_hCsvList, LB_ADDSTRING, 0, (LPARAM)res[i*c]);
                    sqlite3_free_table(res);
                }
                ShowWindow(g_hCsvBtnImp, LOWORD(wParam) == IDM_FILE_IMPORT_CSV ? SW_SHOW : SW_HIDE);
                ShowWindow(g_hCsvBtnExp, LOWORD(wParam) == IDM_FILE_EXPORT_CSV ? SW_SHOW : SW_HIDE);
                ShowWindow(g_hCsvWnd, SW_SHOW);
            }
            else if (LOWORD(wParam) == IDM_FILE_EXIT) PostQuitMessage(0);
            break;
        }
        case WM_CTLCOLOREDIT: case WM_CTLCOLORSTATIC: {
            if ((HWND)lParam == g_hTerminalEdit) {
                SetTextColor((HDC)wParam, RGB(250, 250, 250)); SetBkColor((HDC)wParam, RGB(0, 0, 0));
                return (LRESULT)g_hBlackBrush;
            } break;
        }
        case WM_TIMER: {
            if (g_listen_sock != INVALID_SOCKET) {
                struct sockaddr_in client_addr; int addr_len = sizeof(client_addr);
                SOCKET s = accept(g_listen_sock, (struct sockaddr*)&client_addr, &addr_len);
                if (s != INVALID_SOCKET) {
                    u_long mode = 1; ioctlsocket(s, FIONBIO, &mode);
                    int slot = -1;
                    for (int i = 1; i < MAX_CLIENTS; i++) {
                        if (g_clients[i].sock == INVALID_SOCKET) { slot = i; break; }
                    }
                    if (slot != -1) {
                        g_clients[slot].sock = s; g_clients[slot].stack_count = 0;
                        strcpy(g_clients[slot].userid, "1"); strcpy(g_clients[slot].branch, "");
                        loadmenu(&g_clients[slot], "");
                    } else closesocket(s);
                }
                for (int i = 1; i < MAX_CLIENTS; i++) {
                    if (g_clients[i].sock != INVALID_SOCKET) HandleClientData(i);
                }
            }
            break;
        }
        case WM_DESTROY:
            if (g_hBlackBrush) DeleteObject(g_hBlackBrush);
            if (g_listen_sock != INVALID_SOCKET) closesocket(g_listen_sock);
            if (g_db) sqlite3_close(g_db);
            WSACleanup(); PostQuitMessage(0); return 0;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    WSADATA wsa; WSAStartup(MAKEWORD(2,2), &wsa);
    INITCOMMONCONTROLSEX icex = { sizeof(INITCOMMONCONTROLSEX), ICC_WIN95_CLASSES }; InitCommonControlsEx(&icex);
    
    sqlite3_open("db.db", &g_db); sqlite3_exec(g_db, "PRAGMA journal_mode=WAL;", NULL, NULL, NULL);
    _CacheQueries();

    g_listen_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    u_long non_block = 1; ioctlsocket(g_listen_sock, FIONBIO, &non_block);
    
    /* 
     * FIX: Renamed 's_addr' variable to 'server_addr'. 
     * 's_addr' is a macro in winsock2.h defined as 'S_un.S_addr' which 
     * breaks compilation when used as a local variable name.
     */
    struct sockaddr_in server_addr = {0}; 
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(BIND_PORT); 
    server_addr.sin_addr.s_addr = INADDR_ANY;
    
    bind(g_listen_sock, (struct sockaddr*)&server_addr, sizeof(server_addr));
    listen(g_listen_sock, 8);

    WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_HREDRAW|CS_VREDRAW, MainWndProc, 0, 0, hInstance, NULL, LoadCursor(NULL,IDC_ARROW), (HBRUSH)(COLOR_WINDOW+1), NULL, "ServerClass", NULL };
    RegisterClassEx(&wc);

    g_hMainWnd = CreateWindowEx(0, "ServerClass", "TextUI Dispatch Server (SQLite Backend)", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 850, 520, NULL, NULL, hInstance, NULL);

    ShowWindow(g_hMainWnd, nCmdShow); UpdateWindow(g_hMainWnd);
    MSG msg; while (GetMessage(&msg, NULL, 0, 0)) { TranslateMessage(&msg); DispatchMessage(&msg); }
    return (int)msg.wParam;
}
