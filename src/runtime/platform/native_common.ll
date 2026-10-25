; Typed libc adapters. Language/runtime algorithms are implemented in Faz.

declare ptr @getenv(ptr)

declare ptr @fopen(ptr, ptr)

declare i64 @fread(ptr, i64, i64, ptr)

declare i64 @fwrite(ptr, i64, i64, ptr)

declare i32 @ferror(ptr)

declare i32 @feof(ptr)

declare i32 @fclose(ptr)

declare ptr @realpath(ptr, ptr)

declare ptr @mkdtemp(ptr)

declare i32 @mkstemp(ptr)

declare i32 @atexit(ptr)

declare i32 @unlink(ptr)

declare i32 @rmdir(ptr)

declare i32 @closedir(ptr)

declare i32 @waitpid(i32, ptr, i32)

declare void @exit(i32)

declare i32 @close(i32)

declare i64 @read(i32, ptr, i64)

declare i64 @write(i32, ptr, i64)

declare i32 @rename(ptr, ptr)

declare i32 @getcontext(ptr)

declare i32 @swapcontext(ptr, ptr)

declare i32 @munmap(ptr, i64)

declare i64 @recv(i32, ptr, i64, i32)

declare i64 @send(i32, ptr, i64, i32)

declare i32 @accept(i32, ptr, ptr)

declare i32 @bind(i32, ptr, i32)

declare i32 @listen(i32, i32)

declare i32 @socket(i32, i32, i32)

declare i32 @inet_pton(i32, ptr, ptr)

declare i32 @putchar(i32)

declare ptr @strstr(ptr, ptr)

declare ptr @strchr(ptr, i32)

declare i32 @printf(ptr, ...)

declare i32 @snprintf(ptr, i64, ptr, ...)

declare i32 @dprintf(i32, ptr, ...)

declare i32 @clock_gettime(i32, ptr)

declare i32 @posix_spawnp(ptr, ptr, ptr, ptr, ptr, ptr)

declare void @makecontext(ptr, ptr, i32, ...)

declare ptr @signal(i32, ptr)

declare i32 @setsockopt(i32, i32, i32, ptr, i32)

declare i32 @fcntl(i32, i32, ...)

declare ptr @mmap(ptr, i64, i32, i32, i32, i64)

declare i32 @mprotect(ptr, i64, i32)

declare i64 @sysconf(i32)

declare i32 @open(ptr, i32, ...)

declare ptr @strerror(i32)

define i64 @rt_os_getenv(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call ptr @getenv(ptr %v0)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

define i64 @rt_os_fopen(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call ptr @fopen(ptr %v0, ptr %v1)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

define i64 @rt_os_fread(i64 %a0, i64 %a1, i64 %a2, i64 %a3) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v3 = inttoptr i64 %a3 to ptr
  %r = call i64 @fread(ptr %v0, i64 %a1, i64 %a2, ptr %v3)
  ret i64 %r
}

define i64 @rt_os_fwrite(i64 %a0, i64 %a1, i64 %a2, i64 %a3) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v3 = inttoptr i64 %a3 to ptr
  %r = call i64 @fwrite(ptr %v0, i64 %a1, i64 %a2, ptr %v3)
  ret i64 %r
}

define i64 @rt_os_ferror(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @ferror(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_feof(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @feof(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_fclose(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @fclose(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_realpath(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call ptr @realpath(ptr %v0, ptr %v1)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

define i64 @rt_os_mkdtemp(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call ptr @mkdtemp(ptr %v0)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

define i64 @rt_os_mkstemp(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @mkstemp(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_atexit(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @atexit(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_unlink(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @unlink(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_rmdir(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @rmdir(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_closedir(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @closedir(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_waitpid(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %v2 = trunc i64 %a2 to i32
  %r = call i32 @waitpid(i32 %v0, ptr %v1, i32 %v2)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_exit(i64 %a0) {
entry:
  %v0 = trunc i64 %a0 to i32
  call void @exit(i32 %v0)
  ret i64 0
}

define i64 @rt_os_close(i64 %a0) {
entry:
  %v0 = trunc i64 %a0 to i32
  %r = call i32 @close(i32 %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_read(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i64 @read(i32 %v0, ptr %v1, i64 %a2)
  ret i64 %r
}

define i64 @rt_os_write(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i64 @write(i32 %v0, ptr %v1, i64 %a2)
  ret i64 %r
}

define i64 @rt_os_rename(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @rename(ptr %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_getcontext(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @getcontext(ptr %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_swapcontext(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @swapcontext(ptr %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_munmap(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call i32 @munmap(ptr %v0, i64 %a1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_recv(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i64 @recv(i32 %v0, ptr %v1, i64 %a2, i32 0)
  ret i64 %r
}

define i64 @rt_os_send(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i64 @send(i32 %v0, ptr %v1, i64 %a2, i32 0)
  ret i64 %r
}

define i64 @rt_os_accept(i64 %a0) {
entry:
  %v0 = trunc i64 %a0 to i32
  %r = call i32 @accept(i32 %v0, ptr null, ptr null)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_bind(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %v2 = trunc i64 %a2 to i32
  %r = call i32 @bind(i32 %v0, ptr %v1, i32 %v2)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_listen(i64 %a0, i64 %a1) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = trunc i64 %a1 to i32
  %r = call i32 @listen(i32 %v0, i32 %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_socket(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = trunc i64 %a1 to i32
  %v2 = trunc i64 %a2 to i32
  %r = call i32 @socket(i32 %v0, i32 %v1, i32 %v2)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_inet_pton(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %v2 = inttoptr i64 %a2 to ptr
  %r = call i32 @inet_pton(i32 %v0, ptr %v1, ptr %v2)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_putchar(i64 %a0) {
entry:
  %v0 = trunc i64 %a0 to i32
  %r = call i32 @putchar(i32 %v0)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_strstr(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call ptr @strstr(ptr %v0, ptr %v1)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

define i64 @rt_os_strchr(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = trunc i64 %a1 to i32
  %r = call ptr @strchr(ptr %v0, i32 %v1)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

@rt_os_fmt_int = private constant [5 x i8] c"%lld\00"

@rt_os_fmt_str = private constant [3 x i8] c"%s\00"

@rt_os_fmt_error = private constant [4 x i8] c"%s\0A\00"

@rt_os_true = private constant [5 x i8] c"True\00"

@rt_os_false = private constant [6 x i8] c"False\00"

@rt_os_fmt_panic = private constant [36 x i8] c"Faz runtime error at line %lld: %s\0A\00"

@rt_os_fmt_file = private constant [52 x i8] c"Faz runtime error at line %lld: cannot %s '%s': %s\0A\00"

@rt_os_fmt_stats = private constant [125 x i8] c"Faz GC: allocations=%lld collections=%lld allocated=%lld reclaimed=%lld live=%lld peak=%lld pause_ns=%lld max_pause_ns=%lld\0A\00"

@rt_os_fmt_http = private constant [138 x i8] c"HTTP/1.1 %lld %s\0D\0AContent-Type: text/plain; charset=utf-8\0D\0AContent-Length: %lld\0D\0AConnection: close\0D\0AX-Content-Type-Options: nosniff\0D\0A%s\0D\0A\00"

@rt_os_http_allow = private constant [13 x i8] c"Allow: GET\0D\0A\00"

@rt_os_empty = private constant [1 x i8] c"\00"


define i64 @rt_os_http_header(i64 %buffer, i64 %status, i64 %reason, i64 %size) {
  %p = inttoptr i64 %buffer to ptr
  %r = inttoptr i64 %reason to ptr
  %method = icmp eq i64 %status, 405
  %allow = select i1 %method, ptr @rt_os_http_allow, ptr @rt_os_empty
  %n = call i32 (ptr, i64, ptr, ...) @snprintf(ptr %p, i64 512, ptr @rt_os_fmt_http, i64 %status, ptr %r, i64 %size, ptr %allow)
  %out = sext i32 %n to i64
  ret i64 %out
}
define i64 @rt_os_format_int(i64 %buffer, i64 %value) {
  %p = inttoptr i64 %buffer to ptr
  %n = call i32 (ptr, i64, ptr, ...) @snprintf(ptr %p, i64 32, ptr @rt_os_fmt_int, i64 %value)
  ret i64 0
}
define i64 @rt_os_print(i64 %value, i64 %kind) {
  switch i64 %kind, label %string [i64 0, label %integer i64 1, label %boolean]
integer:
  %i = call i32 (ptr, ...) @printf(ptr @rt_os_fmt_int, i64 %value)
  ret i64 0
boolean:
  %truth = icmp ne i64 %value, 0
  %b = select i1 %truth, ptr @rt_os_true, ptr @rt_os_false
  %j = call i32 (ptr, ...) @printf(ptr @rt_os_fmt_str, ptr %b)
  ret i64 0
string:
  %p = inttoptr i64 %value to ptr
  %k = call i32 (ptr, ...) @printf(ptr @rt_os_fmt_str, ptr %p)
  ret i64 0
}
define i64 @rt_os_error(i64 %message) {
  %p = inttoptr i64 %message to ptr
  %n = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @rt_os_fmt_error, ptr %p)
  ret i64 0
}
define i64 @rt_os_panic(i64 %line, i64 %message) {
  %p = inttoptr i64 %message to ptr
  %n = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @rt_os_fmt_panic, i64 %line, ptr %p)
  call void @exit(i32 1)
  unreachable
}
define i64 @rt_os_file_error(i64 %operation, i64 %path, i64 %line) {
  %op = inttoptr i64 %operation to ptr
  %p = inttoptr i64 %path to ptr
  %err = call i64 @rt_os_errno()
  %e = trunc i64 %err to i32
  %why = call ptr @strerror(i32 %e)
  %n = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @rt_os_fmt_file, i64 %line, ptr %op, ptr %p, ptr %why)
  call void @exit(i32 1)
  unreachable
}
define i64 @rt_os_gc_stats(i64 %a, i64 %c, i64 %t, i64 %r, i64 %l, i64 %p, i64 %ns, i64 %max) {
  %n = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @rt_os_fmt_stats, i64 %a, i64 %c, i64 %t, i64 %r, i64 %l, i64 %p, i64 %ns, i64 %max)
  ret i64 0
}
define i64 @rt_os_spawn(i64 %pid, i64 %executable, i64 %arguments) {
  %p = inttoptr i64 %pid to ptr
  %e = inttoptr i64 %executable to ptr
  %a = inttoptr i64 %arguments to ptr
  %env = call ptr @rt_native_environment()
  %r = call i32 @posix_spawnp(ptr %p, ptr %e, ptr null, ptr null, ptr %a, ptr %env)
  %result = sext i32 %r to i64
  ret i64 %result
}
define i64 @rt_os_open_read(i64 %path) {
  %p = inttoptr i64 %path to ptr
  %r = call i32 (ptr, i32, ...) @open(ptr %p, i32 0)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_mprotect_stack(i64 %pointer, i64 %size) {
  %p = inttoptr i64 %pointer to ptr
  %r = call i32 @mprotect(ptr %p, i64 %size, i32 3)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_ignore_sigpipe() {
  %r = call ptr @signal(i32 13, ptr inttoptr (i64 1 to ptr))
  ret i64 0
}

; Process capture and file-system tooling adapters.
declare ptr @tmpfile()
declare i32 @fileno(ptr)
declare i32 @fseek(ptr, i64, i32)
declare i64 @ftell(ptr)
declare i32 @posix_spawn_file_actions_init(ptr)
declare i32 @posix_spawn_file_actions_adddup2(ptr, i32, i32)
declare i32 @posix_spawn_file_actions_destroy(ptr)
declare i32 @posix_spawnattr_init(ptr)
declare i32 @posix_spawnattr_setflags(ptr, i16)
declare i32 @posix_spawnattr_setpgroup(ptr, i32)
declare i32 @posix_spawnattr_destroy(ptr)
declare i32 @kill(i32, i32)
declare i32 @nanosleep(ptr, ptr)
declare i32 @setenv(ptr, ptr, i32)
declare i32 @access(ptr, i32)
declare i32 @symlink(ptr, ptr)
declare i32 @link(ptr, ptr)

define i64 @rt_os_tmpfile() {
  %p = call ptr @tmpfile()
  %r = ptrtoint ptr %p to i64
  ret i64 %r
}
define i64 @rt_os_fileno(i64 %file) {
  %p = inttoptr i64 %file to ptr
  %r = call i32 @fileno(ptr %p)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_seek_start(i64 %file) {
  %p = inttoptr i64 %file to ptr
  %r = call i32 @fseek(ptr %p, i64 0, i32 0)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_file_position(i64 %file) {
  %p = inttoptr i64 %file to ptr
  %r = call i64 @ftell(ptr %p)
  ret i64 %r
}
define i64 @rt_os_cloexec(i64 %fd) {
  %f = trunc i64 %fd to i32
  %r = call i32 (i32, i32, ...) @fcntl(i32 %f, i32 2, i32 1)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_actions_init(i64 %actions) {
  %p = inttoptr i64 %actions to ptr
  %r = call i32 @posix_spawn_file_actions_init(ptr %p)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_actions_dup2(i64 %actions, i64 %source, i64 %destination) {
  %p = inttoptr i64 %actions to ptr
  %a = trunc i64 %source to i32
  %b = trunc i64 %destination to i32
  %r = call i32 @posix_spawn_file_actions_adddup2(ptr %p, i32 %a, i32 %b)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_actions_destroy(i64 %actions) {
  %p = inttoptr i64 %actions to ptr
  %r = call i32 @posix_spawn_file_actions_destroy(ptr %p)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_attributes_init(i64 %attributes) {
  %p = inttoptr i64 %attributes to ptr
  %r = call i32 @posix_spawnattr_init(ptr %p)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_attributes_group(i64 %attributes) {
  %p = inttoptr i64 %attributes to ptr
  %r = call i32 @posix_spawnattr_setpgroup(ptr %p, i32 0)
  %bad = icmp ne i32 %r, 0
  br i1 %bad, label %error, label %flags
error:
  %err = sext i32 %r to i64
  ret i64 %err
flags:
  %f = call i32 @posix_spawnattr_setflags(ptr %p, i16 2)
  %out = sext i32 %f to i64
  ret i64 %out
}
define i64 @rt_os_attributes_destroy(i64 %attributes) {
  %p = inttoptr i64 %attributes to ptr
  %r = call i32 @posix_spawnattr_destroy(ptr %p)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_spawn_actions(i64 %pid, i64 %executable, i64 %arguments, i64 %actions, i64 %attributes) {
  %p = inttoptr i64 %pid to ptr
  %e = inttoptr i64 %executable to ptr
  %a = inttoptr i64 %arguments to ptr
  %f = inttoptr i64 %actions to ptr
  %attr = inttoptr i64 %attributes to ptr
  %env = call ptr @rt_native_environment()
  %r = call i32 @posix_spawnp(ptr %p, ptr %e, ptr %f, ptr %attr, ptr %a, ptr %env)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_kill(i64 %pid, i64 %signal) {
  %p = trunc i64 %pid to i32
  %s = trunc i64 %signal to i32
  %r = call i32 @kill(i32 %p, i32 %s)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_pause_poll() {
  %time = alloca [2 x i64], align 8
  store i64 0, ptr %time
  %ns = getelementptr i8, ptr %time, i64 8
  store i64 10000000, ptr %ns
  %r = call i32 @nanosleep(ptr %time, ptr null)
  ret i64 0
}
define i64 @rt_os_setenv(i64 %name, i64 %value) {
  %n = inttoptr i64 %name to ptr
  %v = inttoptr i64 %value to ptr
  %r = call i32 @setenv(ptr %n, ptr %v, i32 1)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_executable_access(i64 %path) {
  %p = inttoptr i64 %path to ptr
  %r = call i32 @access(ptr %p, i32 1)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_symlink(i64 %source, i64 %destination) {
  %s = inttoptr i64 %source to ptr
  %d = inttoptr i64 %destination to ptr
  %r = call i32 @symlink(ptr %s, ptr %d)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_link(i64 %source, i64 %destination) {
  %s = inttoptr i64 %source to ptr
  %d = inttoptr i64 %destination to ptr
  %r = call i32 @link(ptr %s, ptr %d)
  %out = sext i32 %r to i64
  ret i64 %out
}

; TCP test/client boundary. Network policy and timeout loops live in Faz.
declare i32 @connect(i32, ptr, i32)
declare i32 @getsockname(i32, ptr, ptr)
declare i32 @getsockopt(i32, i32, i32, ptr, ptr)
define i64 @rt_os_connect(i64 %fd, i64 %address, i64 %size) {
  %f = trunc i64 %fd to i32
  %p = inttoptr i64 %address to ptr
  %n = trunc i64 %size to i32
  %r = call i32 @connect(i32 %f, ptr %p, i32 %n)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_getsockname(i64 %fd, i64 %address) {
  %f = trunc i64 %fd to i32
  %p = inttoptr i64 %address to ptr
  %size = alloca i32, align 4
  store i32 16, ptr %size
  %r = call i32 @getsockname(i32 %f, ptr %p, ptr %size)
  %out = sext i32 %r to i64
  ret i64 %out
}

declare ptr @getcwd(ptr, i64)
declare i32 @chdir(ptr)
define i64 @rt_os_getcwd() {
  %p = call ptr @getcwd(ptr null, i64 0)
  %out = ptrtoint ptr %p to i64
  ret i64 %out
}
define i64 @rt_os_chdir(i64 %path) {
  %p = inttoptr i64 %path to ptr
  %r = call i32 @chdir(ptr %p)
  %out = sext i32 %r to i64
  ret i64 %out
}
