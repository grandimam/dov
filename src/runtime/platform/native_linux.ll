; Platform ABI constants and layouts; no language algorithms.

declare ptr @__errno_location()

declare i32 @stat(ptr, ptr)

declare i32 @lstat(ptr, ptr)

declare i32 @fstat(i32, ptr)

declare ptr @readdir(ptr)

declare i32 @mkdir(ptr, i32)

declare i32 @fchmod(i32, i32)

declare i32 @poll(ptr, i64, i32)

define i64 @rt_os_stat(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @stat(ptr %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_lstat(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @lstat(ptr %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_fstat(i64 %a0, i64 %a1) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @fstat(i32 %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_readdir(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call ptr @readdir(ptr %v0)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

declare ptr @opendir(ptr)

define i64 @rt_os_opendir(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call ptr @opendir(ptr %v0)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

define i64 @rt_os_mkdir(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = trunc i64 %a1 to i32
  %r = call i32 @mkdir(ptr %v0, i32 %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_fchmod(i64 %a0, i64 %a1) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = trunc i64 %a1 to i32
  %r = call i32 @fchmod(i32 %v0, i32 %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_poll(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v2 = trunc i64 %a2 to i32
  %r = call i32 @poll(ptr %v0, i64 %a1, i32 %v2)
  %out = sext i32 %r to i64
  ret i64 %out
}

@rt_os_platform_text = private constant [6 x i8] c"linux\00"

define i64 @rt_os_platform() {
  %p = ptrtoint ptr @rt_os_platform_text to i64
  ret i64 %p
}

define i64 @rt_os_errno() {
  %p = call ptr @__errno_location()
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}
define i64 @rt_os_set_errno(i64 %value) {
  %p = call ptr @__errno_location()
  %v = trunc i64 %value to i32
  store i32 %v, ptr %p
  ret i64 0
}
define i64 @rt_os_nanoseconds() {
  %t = alloca [2 x i64], align 8
  %r = call i32 @clock_gettime(i32 1, ptr %t)
  %seconds = load i64, ptr %t
  %np = getelementptr i8, ptr %t, i64 8
  %nano = load i64, ptr %np
  %s = mul i64 %seconds, 1000000000
  %total = add i64 %s, %nano
  ret i64 %total
}
define i64 @rt_os_page_size() {
  %n = call i64 @sysconf(i32 30)
  ret i64 %n
}
define i64 @rt_os_mmap_stack(i64 %size) {
  %p = call ptr @mmap(ptr null, i64 %size, i32 0, i32 34, i32 -1, i64 0)
  %r = ptrtoint ptr %p to i64
  ret i64 %r
}
define i64 @rt_os_prepare_context(i64 %context, i64 %base, i64 %size, i64 %scheduler, i64 %entry) {
  %p = inttoptr i64 %context to ptr
  %stack = getelementptr i8, ptr %p, i64 16
  store i64 %base, ptr %stack
  %ss = getelementptr i8, ptr %p, i64 32
  store i64 %size, ptr %ss
  %link = getelementptr i8, ptr %p, i64 8
  store i64 %scheduler, ptr %link
  %fn = inttoptr i64 %entry to ptr
  call void (ptr, ptr, i32, ...) @makecontext(ptr %p, ptr %fn, i32 0)
  ret i64 0
}
define i64 @rt_os_dirent_name(i64 %entry) {
  %p = add i64 %entry, 19
  ret i64 %p
}
define i64 @rt_os_stat_device(i64 %info) {
  %p = inttoptr i64 %info to ptr
  %v = load i64, ptr %p
  %r = add i64 %v, 0
  ret i64 %r
}
define i64 @rt_os_stat_inode(i64 %info) {
  %p = inttoptr i64 %info to ptr
  %slot = getelementptr i8, ptr %p, i64 8
  %v = load i64, ptr %slot
  ret i64 %v
}

@environ = external global ptr
declare i32 @uname(ptr)
define ptr @rt_native_environment() {
  %r = load ptr, ptr @environ
  ret ptr %r
}
; Linux arm64 stat mode lives at 16; x86_64 at 24. uname is an OS ABI query.
define i64 @rt_os_stat_mode(i64 %info) {
  %uts = alloca [512 x i8], align 8
  %ok = call i32 @uname(ptr %uts)
  %machine = getelementptr i8, ptr %uts, i64 260
  %first = load i8, ptr %machine
  %arm = icmp eq i8 %first, 97
  %offset = select i1 %arm, i64 16, i64 24
  %p = inttoptr i64 %info to ptr
  %slot = getelementptr i8, ptr %p, i64 %offset
  %v = load i32, ptr %slot
  %r = zext i32 %v to i64
  ret i64 %r
}

define i64 @rt_os_nonblocking(i64 %fd) {
  %f = trunc i64 %fd to i32
  %flags = call i32 (i32, i32, ...) @fcntl(i32 %f, i32 3, i32 0)
  %bad = icmp slt i32 %flags, 0
  br i1 %bad, label %failed, label %set
set:
  %next = or i32 %flags, 2048
  %r = call i32 (i32, i32, ...) @fcntl(i32 %f, i32 4, i32 %next)
  %ok = icmp eq i32 %r, 0
  %out = zext i1 %ok to i64
  ret i64 %out
failed:
  ret i64 0
}
define i64 @rt_os_reuse_address(i64 %fd) {
  %f = trunc i64 %fd to i32
  %yes = alloca i32, align 4
  store i32 1, ptr %yes
  %r = call i32 @setsockopt(i32 %f, i32 1, i32 2, ptr %yes, i32 4)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_would_block(i64 %error) {
  %yes = icmp eq i64 %error, 11
  %r = zext i1 %yes to i64
  ret i64 %r
}
define i64 @rt_os_connection_aborted(i64 %error) {
  %yes = icmp eq i64 %error, 103
  %r = zext i1 %yes to i64
  ret i64 %r
}
define i64 @rt_os_sockaddr_family(i64 %address) {
  %p = inttoptr i64 %address to ptr
  store i16 2, ptr %p
  ret i64 0
}

define i64 @rt_os_connect_pending(i64 %error) {
  %yes = icmp eq i64 %error, 115
  %r = zext i1 %yes to i64
  ret i64 %r
}
define i64 @rt_os_socket_error(i64 %fd) {
  %f = trunc i64 %fd to i32
  %value = alloca i32, align 4
  %size = alloca i32, align 4
  store i32 4, ptr %size
  %r = call i32 @getsockopt(i32 %f, i32 1, i32 4, ptr %value, ptr %size)
  %ok = icmp eq i32 %r, 0
  br i1 %ok, label %result, label %failed
result:
  %error = load i32, ptr %value
  %out = sext i32 %error to i64
  ret i64 %out
failed:
  ret i64 -1
}
