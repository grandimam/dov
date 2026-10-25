; Platform ABI constants and layouts; no language algorithms.

declare ptr @__error()





declare i32 @mkdir(ptr, i16)

declare i32 @fchmod(i32, i16)

declare i32 @poll(ptr, i32, i32)

define i64 @rt_os_stat(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @rt_native_stat(ptr %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_lstat(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @rt_native_lstat(ptr %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_fstat(i64 %a0, i64 %a1) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = inttoptr i64 %a1 to ptr
  %r = call i32 @rt_native_fstat(i32 %v0, ptr %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_readdir(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call ptr @rt_native_readdir(ptr %v0)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}


define i64 @rt_os_opendir(i64 %a0) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %r = call ptr @rt_native_opendir(ptr %v0)
  %out = ptrtoint ptr %r to i64
  ret i64 %out
}

declare ptr @dlsym(ptr, ptr)

@rt_os_symbol_stat = private constant [5 x i8] c"stat\00"

@rt_os_symbol_stat_64 = private constant [13 x i8] c"stat$INODE64\00"

define i32 @rt_native_stat(ptr %a0, ptr %a1) {
  %wide = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_stat_64)
  %missing = icmp eq ptr %wide, null
  br i1 %missing, label %plain, label %ready
plain:
  %narrow = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_stat)
  br label %ready
ready:
  %fn = phi ptr [%wide, %0], [%narrow, %plain]
  %r = call i32 %fn(ptr %a0, ptr %a1)
  ret i32 %r
}

@rt_os_symbol_lstat = private constant [6 x i8] c"lstat\00"

@rt_os_symbol_lstat_64 = private constant [14 x i8] c"lstat$INODE64\00"

define i32 @rt_native_lstat(ptr %a0, ptr %a1) {
  %wide = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_lstat_64)
  %missing = icmp eq ptr %wide, null
  br i1 %missing, label %plain, label %ready
plain:
  %narrow = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_lstat)
  br label %ready
ready:
  %fn = phi ptr [%wide, %0], [%narrow, %plain]
  %r = call i32 %fn(ptr %a0, ptr %a1)
  ret i32 %r
}

@rt_os_symbol_fstat = private constant [6 x i8] c"fstat\00"

@rt_os_symbol_fstat_64 = private constant [14 x i8] c"fstat$INODE64\00"

define i32 @rt_native_fstat(i32 %a0, ptr %a1) {
  %wide = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_fstat_64)
  %missing = icmp eq ptr %wide, null
  br i1 %missing, label %plain, label %ready
plain:
  %narrow = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_fstat)
  br label %ready
ready:
  %fn = phi ptr [%wide, %0], [%narrow, %plain]
  %r = call i32 %fn(i32 %a0, ptr %a1)
  ret i32 %r
}

@rt_os_symbol_readdir = private constant [8 x i8] c"readdir\00"

@rt_os_symbol_readdir_64 = private constant [16 x i8] c"readdir$INODE64\00"

define ptr @rt_native_readdir(ptr %a0) {
  %wide = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_readdir_64)
  %missing = icmp eq ptr %wide, null
  br i1 %missing, label %plain, label %ready
plain:
  %narrow = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_readdir)
  br label %ready
ready:
  %fn = phi ptr [%wide, %0], [%narrow, %plain]
  %r = call ptr %fn(ptr %a0)
  ret ptr %r
}

@rt_os_symbol_opendir = private constant [8 x i8] c"opendir\00"

@rt_os_symbol_opendir_64 = private constant [16 x i8] c"opendir$INODE64\00"

define ptr @rt_native_opendir(ptr %a0) {
  %wide = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_opendir_64)
  %missing = icmp eq ptr %wide, null
  br i1 %missing, label %plain, label %ready
plain:
  %narrow = call ptr @dlsym(ptr inttoptr (i64 -2 to ptr), ptr @rt_os_symbol_opendir)
  br label %ready
ready:
  %fn = phi ptr [%wide, %0], [%narrow, %plain]
  %r = call ptr %fn(ptr %a0)
  ret ptr %r
}

define i64 @rt_os_mkdir(i64 %a0, i64 %a1) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = trunc i64 %a1 to i16
  %r = call i32 @mkdir(ptr %v0, i16 %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_fchmod(i64 %a0, i64 %a1) {
entry:
  %v0 = trunc i64 %a0 to i32
  %v1 = trunc i64 %a1 to i16
  %r = call i32 @fchmod(i32 %v0, i16 %v1)
  %out = sext i32 %r to i64
  ret i64 %out
}

define i64 @rt_os_poll(i64 %a0, i64 %a1, i64 %a2) {
entry:
  %v0 = inttoptr i64 %a0 to ptr
  %v1 = trunc i64 %a1 to i32
  %v2 = trunc i64 %a2 to i32
  %r = call i32 @poll(ptr %v0, i32 %v1, i32 %v2)
  %out = sext i32 %r to i64
  ret i64 %out
}

@rt_os_platform_text = private constant [7 x i8] c"darwin\00"

define i64 @rt_os_platform() {
  %p = ptrtoint ptr @rt_os_platform_text to i64
  ret i64 %p
}

define i64 @rt_os_errno() {
  %p = call ptr @__error()
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}
define i64 @rt_os_set_errno(i64 %value) {
  %p = call ptr @__error()
  %v = trunc i64 %value to i32
  store i32 %v, ptr %p
  ret i64 0
}
define i64 @rt_os_nanoseconds() {
  %t = alloca [2 x i64], align 8
  %r = call i32 @clock_gettime(i32 6, ptr %t)
  %seconds = load i64, ptr %t
  %np = getelementptr i8, ptr %t, i64 8
  %nano = load i64, ptr %np
  %s = mul i64 %seconds, 1000000000
  %total = add i64 %s, %nano
  ret i64 %total
}
define i64 @rt_os_page_size() {
  %n = call i64 @sysconf(i32 29)
  ret i64 %n
}
define i64 @rt_os_mmap_stack(i64 %size) {
  %p = call ptr @mmap(ptr null, i64 %size, i32 0, i32 4098, i32 -1, i64 0)
  %r = ptrtoint ptr %p to i64
  ret i64 %r
}
define i64 @rt_os_prepare_context(i64 %context, i64 %base, i64 %size, i64 %scheduler, i64 %entry) {
  %p = inttoptr i64 %context to ptr
  %stack = getelementptr i8, ptr %p, i64 8
  store i64 %base, ptr %stack
  %ss = getelementptr i8, ptr %p, i64 16
  store i64 %size, ptr %ss
  %link = getelementptr i8, ptr %p, i64 32
  store i64 %scheduler, ptr %link
  %fn = inttoptr i64 %entry to ptr
  call void (ptr, ptr, i32, ...) @makecontext(ptr %p, ptr %fn, i32 0)
  ret i64 0
}
define i64 @rt_os_dirent_name(i64 %entry) {
  %p = add i64 %entry, 21
  ret i64 %p
}
define i64 @rt_os_stat_device(i64 %info) {
  %p = inttoptr i64 %info to ptr
  %v = load i32, ptr %p
  %r = zext i32 %v to i64
  ret i64 %r
}
define i64 @rt_os_stat_inode(i64 %info) {
  %p = inttoptr i64 %info to ptr
  %slot = getelementptr i8, ptr %p, i64 8
  %v = load i64, ptr %slot
  ret i64 %v
}

declare ptr @_NSGetEnviron()
define ptr @rt_native_environment() {
  %p = call ptr @_NSGetEnviron()
  %r = load ptr, ptr %p
  ret ptr %r
}
define i64 @rt_os_stat_mode(i64 %info) {
  %p = inttoptr i64 %info to ptr
  %slot = getelementptr i8, ptr %p, i64 4
  %v = load i16, ptr %slot
  %r = zext i16 %v to i64
  ret i64 %r
}

define i64 @rt_os_nonblocking(i64 %fd) {
  %f = trunc i64 %fd to i32
  %flags = call i32 (i32, i32, ...) @fcntl(i32 %f, i32 3, i32 0)
  %bad = icmp slt i32 %flags, 0
  br i1 %bad, label %failed, label %set
set:
  %next = or i32 %flags, 4
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
  %r = call i32 @setsockopt(i32 %f, i32 65535, i32 4, ptr %yes, i32 4)
  %out = sext i32 %r to i64
  ret i64 %out
}
define i64 @rt_os_would_block(i64 %error) {
  %yes = icmp eq i64 %error, 35
  %r = zext i1 %yes to i64
  ret i64 %r
}
define i64 @rt_os_connection_aborted(i64 %error) {
  %yes = icmp eq i64 %error, 53
  %r = zext i1 %yes to i64
  ret i64 %r
}
define i64 @rt_os_sockaddr_family(i64 %address) {
  %p = inttoptr i64 %address to ptr
  store i16 528, ptr %p
  ret i64 0
}

define i64 @rt_os_connect_pending(i64 %error) {
  %yes = icmp eq i64 %error, 36
  %r = zext i1 %yes to i64
  ret i64 %r
}
define i64 @rt_os_socket_error(i64 %fd) {
  %f = trunc i64 %fd to i32
  %value = alloca i32, align 4
  %size = alloca i32, align 4
  store i32 4, ptr %size
  %r = call i32 @getsockopt(i32 %f, i32 65535, i32 4103, ptr %value, ptr %size)
  %ok = icmp eq i32 %r, 0
  br i1 %ok, label %result, label %failed
result:
  %error = load i32, ptr %value
  %out = sext i32 %error to i64
  ret i64 %out
failed:
  ret i64 -1
}
