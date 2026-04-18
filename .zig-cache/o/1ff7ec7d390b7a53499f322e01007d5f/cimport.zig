const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __aro_max_align_ll: c_longlong = 0,
    __aro_max_align_ld: c_longdouble = 0,
};
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
pub const __fsid_t = extern struct {
    __val: [2]c_int = @import("std").mem.zeroes([2]c_int),
};
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __suseconds64_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*anyopaque;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
pub const int_least8_t = __int_least8_t;
pub const int_least16_t = __int_least16_t;
pub const int_least32_t = __int_least32_t;
pub const int_least64_t = __int_least64_t;
pub const uint_least8_t = __uint_least8_t;
pub const uint_least16_t = __uint_least16_t;
pub const uint_least32_t = __uint_least32_t;
pub const uint_least64_t = __uint_least64_t;
pub const int_fast8_t = i8;
pub const int_fast16_t = c_long;
pub const int_fast32_t = c_long;
pub const int_fast64_t = c_long;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = c_ulong;
pub const uint_fast32_t = c_ulong;
pub const uint_fast64_t = c_ulong;
pub const intmax_t = __intmax_t;
pub const uintmax_t = __uintmax_t;
pub const struct___va_list_tag_1 = extern struct {
    unnamed_0: c_uint = 0,
    unnamed_1: c_uint = 0,
    unnamed_2: ?*anyopaque = null,
    unnamed_3: ?*anyopaque = null,
};
pub const __builtin_va_list = [1]struct___va_list_tag_1;
pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
const union_unnamed_2 = extern union {
    __wch: c_uint,
    __wchb: [4]u8,
};
pub const __mbstate_t = extern struct {
    __count: c_int = 0,
    __value: union_unnamed_2 = @import("std").mem.zeroes(union_unnamed_2),
};
pub const struct__G_fpos_t = extern struct {
    __pos: __off_t = 0,
    __state: __mbstate_t = @import("std").mem.zeroes(__mbstate_t),
};
pub const __fpos_t = struct__G_fpos_t;
pub const struct__G_fpos64_t = extern struct {
    __pos: __off64_t = 0,
    __state: __mbstate_t = @import("std").mem.zeroes(__mbstate_t),
};
pub const __fpos64_t = struct__G_fpos64_t;
pub const struct__IO_marker = opaque {}; // /usr/include/bits/types/struct_FILE.h:75:7: warning: struct demoted to opaque type - has bitfield
pub const struct__IO_FILE = opaque {
    pub const fclose = __root.fclose;
    pub const fflush = __root.fflush;
    pub const fflush_unlocked = __root.fflush_unlocked;
    pub const setbuf = __root.setbuf;
    pub const setvbuf = __root.setvbuf;
    pub const setbuffer = __root.setbuffer;
    pub const setlinebuf = __root.setlinebuf;
    pub const fprintf = __root.fprintf;
    pub const vfprintf = __root.vfprintf;
    pub const fscanf = __root.fscanf;
    pub const vfscanf = __root.vfscanf;
    pub const fgetc = __root.fgetc;
    pub const getc = __root.getc;
    pub const getc_unlocked = __root.getc_unlocked;
    pub const fgetc_unlocked = __root.fgetc_unlocked;
    pub const getw = __root.getw;
    pub const fseek = __root.fseek;
    pub const ftell = __root.ftell;
    pub const rewind = __root.rewind;
    pub const fseeko = __root.fseeko;
    pub const ftello = __root.ftello;
    pub const fgetpos = __root.fgetpos;
    pub const fsetpos = __root.fsetpos;
    pub const clearerr = __root.clearerr;
    pub const feof = __root.feof;
    pub const ferror = __root.ferror;
    pub const clearerr_unlocked = __root.clearerr_unlocked;
    pub const feof_unlocked = __root.feof_unlocked;
    pub const ferror_unlocked = __root.ferror_unlocked;
    pub const fileno = __root.fileno;
    pub const fileno_unlocked = __root.fileno_unlocked;
    pub const pclose = __root.pclose;
    pub const flockfile = __root.flockfile;
    pub const ftrylockfile = __root.ftrylockfile;
    pub const funlockfile = __root.funlockfile;
    pub const __uflow = __root.__uflow;
    pub const __overflow = __root.__overflow;
    pub const gguf_init_from_file_ptr = __root.gguf_init_from_file_ptr;
    pub const llama_model_load_from_file_ptr = __root.llama_model_load_from_file_ptr;
    pub const unlocked = __root.fflush_unlocked;
    pub const uflow = __root.__uflow;
    pub const overflow = __root.__overflow;
    pub const ptr = __root.gguf_init_from_file_ptr;
};
pub const __FILE = struct__IO_FILE;
pub const FILE = struct__IO_FILE;
pub const struct__IO_codecvt = opaque {};
pub const struct__IO_wide_data = opaque {};
pub const _IO_lock_t = anyopaque;
pub const cookie_read_function_t = fn (__cookie: ?*anyopaque, __buf: [*c]u8, __nbytes: usize) callconv(.c) __ssize_t;
pub const cookie_write_function_t = fn (__cookie: ?*anyopaque, __buf: [*c]const u8, __nbytes: usize) callconv(.c) __ssize_t;
pub const cookie_seek_function_t = fn (__cookie: ?*anyopaque, __pos: [*c]__off64_t, __w: c_int) callconv(.c) c_int;
pub const cookie_close_function_t = fn (__cookie: ?*anyopaque) callconv(.c) c_int;
pub const struct__IO_cookie_io_functions_t = extern struct {
    read: ?*const cookie_read_function_t = null,
    write: ?*const cookie_write_function_t = null,
    seek: ?*const cookie_seek_function_t = null,
    close: ?*const cookie_close_function_t = null,
};
pub const cookie_io_functions_t = struct__IO_cookie_io_functions_t;
pub const off_t = __off_t;
pub const fpos_t = __fpos_t;
pub extern var stdin: ?*FILE;
pub extern var stdout: ?*FILE;
pub extern var stderr: ?*FILE;
pub extern fn remove(__filename: [*c]const u8) c_int;
pub extern fn rename(__old: [*c]const u8, __new: [*c]const u8) c_int;
pub extern fn renameat(__oldfd: c_int, __old: [*c]const u8, __newfd: c_int, __new: [*c]const u8) c_int;
pub extern fn fclose(__stream: ?*FILE) c_int;
pub extern fn tmpfile() ?*FILE;
pub extern fn tmpnam([*c]u8) [*c]u8;
pub extern fn tmpnam_r(__s: [*c]u8) [*c]u8;
pub extern fn tempnam(__dir: [*c]const u8, __pfx: [*c]const u8) [*c]u8;
pub extern fn fflush(__stream: ?*FILE) c_int;
pub extern fn fflush_unlocked(__stream: ?*FILE) c_int;
pub extern fn fopen(noalias __filename: [*c]const u8, noalias __modes: [*c]const u8) ?*FILE;
pub extern fn freopen(noalias __filename: [*c]const u8, noalias __modes: [*c]const u8, noalias __stream: ?*FILE) ?*FILE;
pub extern fn fdopen(__fd: c_int, __modes: [*c]const u8) ?*FILE;
pub extern fn fopencookie(noalias __magic_cookie: ?*anyopaque, noalias __modes: [*c]const u8, __io_funcs: cookie_io_functions_t) ?*FILE;
pub extern fn fmemopen(__s: ?*anyopaque, __len: usize, __modes: [*c]const u8) ?*FILE;
pub extern fn open_memstream(__bufloc: [*c][*c]u8, __sizeloc: [*c]usize) ?*FILE;
pub extern fn setbuf(noalias __stream: ?*FILE, noalias __buf: [*c]u8) void;
pub extern fn setvbuf(noalias __stream: ?*FILE, noalias __buf: [*c]u8, __modes: c_int, __n: usize) c_int;
pub extern fn setbuffer(noalias __stream: ?*FILE, noalias __buf: [*c]u8, __size: usize) void;
pub extern fn setlinebuf(__stream: ?*FILE) void;
pub extern fn fprintf(noalias __stream: ?*FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn printf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sprintf(noalias __s: [*c]u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfprintf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vprintf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vsprintf(noalias __s: [*c]u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn snprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vsnprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vasprintf(noalias __ptr: [*c][*c]u8, noalias __f: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn __asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn vdprintf(__fd: c_int, noalias __fmt: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn dprintf(__fd: c_int, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn fscanf(noalias __stream: ?*FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn scanf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfscanf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vscanf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vsscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn fgetc(__stream: ?*FILE) c_int;
pub extern fn getc(__stream: ?*FILE) c_int;
pub extern fn getchar() c_int;
pub extern fn getc_unlocked(__stream: ?*FILE) c_int;
pub extern fn getchar_unlocked() c_int;
pub extern fn fgetc_unlocked(__stream: ?*FILE) c_int;
pub extern fn fputc(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putc(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putchar(__c: c_int) c_int;
pub extern fn fputc_unlocked(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putc_unlocked(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putchar_unlocked(__c: c_int) c_int;
pub extern fn getw(__stream: ?*FILE) c_int;
pub extern fn putw(__w: c_int, __stream: ?*FILE) c_int;
pub extern fn fgets(noalias __s: [*c]u8, __n: c_int, noalias __stream: ?*FILE) [*c]u8;
pub extern fn __getdelim(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, __delimiter: c_int, noalias __stream: ?*FILE) __ssize_t;
pub extern fn getdelim(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, __delimiter: c_int, noalias __stream: ?*FILE) __ssize_t;
pub extern fn getline(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, noalias __stream: ?*FILE) __ssize_t;
pub extern fn fputs(noalias __s: [*c]const u8, noalias __stream: ?*FILE) c_int;
pub extern fn puts(__s: [*c]const u8) c_int;
pub extern fn ungetc(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn fread(noalias __ptr: ?*anyopaque, __size: usize, __n: usize, noalias __stream: ?*FILE) usize;
pub extern fn fwrite(noalias __ptr: ?*const anyopaque, __size: usize, __n: usize, noalias __s: ?*FILE) usize;
pub extern fn fread_unlocked(noalias __ptr: ?*anyopaque, __size: usize, __n: usize, noalias __stream: ?*FILE) usize;
pub extern fn fwrite_unlocked(noalias __ptr: ?*const anyopaque, __size: usize, __n: usize, noalias __stream: ?*FILE) usize;
pub extern fn fseek(__stream: ?*FILE, __off: c_long, __whence: c_int) c_int;
pub extern fn ftell(__stream: ?*FILE) c_long;
pub extern fn rewind(__stream: ?*FILE) void;
pub extern fn fseeko(__stream: ?*FILE, __off: __off_t, __whence: c_int) c_int;
pub extern fn ftello(__stream: ?*FILE) __off_t;
pub extern fn fgetpos(noalias __stream: ?*FILE, noalias __pos: [*c]fpos_t) c_int;
pub extern fn fsetpos(__stream: ?*FILE, __pos: [*c]const fpos_t) c_int;
pub extern fn clearerr(__stream: ?*FILE) void;
pub extern fn feof(__stream: ?*FILE) c_int;
pub extern fn ferror(__stream: ?*FILE) c_int;
pub extern fn clearerr_unlocked(__stream: ?*FILE) void;
pub extern fn feof_unlocked(__stream: ?*FILE) c_int;
pub extern fn ferror_unlocked(__stream: ?*FILE) c_int;
pub extern fn perror(__s: [*c]const u8) void;
pub extern fn fileno(__stream: ?*FILE) c_int;
pub extern fn fileno_unlocked(__stream: ?*FILE) c_int;
pub extern fn pclose(__stream: ?*FILE) c_int;
pub extern fn popen(__command: [*c]const u8, __modes: [*c]const u8) ?*FILE;
pub extern fn ctermid(__s: [*c]u8) [*c]u8;
pub extern fn flockfile(__stream: ?*FILE) void;
pub extern fn ftrylockfile(__stream: ?*FILE) c_int;
pub extern fn funlockfile(__stream: ?*FILE) void;
pub extern fn __uflow(?*FILE) c_int;
pub extern fn __overflow(?*FILE, c_int) c_int;
pub const ggml_abort_callback_t = ?*const fn (error_message: [*c]const u8) callconv(.c) void;
pub extern fn ggml_set_abort_callback(callback: ggml_abort_callback_t) ggml_abort_callback_t;
pub extern fn ggml_abort(file: [*c]const u8, line: c_int, fmt: [*c]const u8, ...) noreturn;
pub const GGML_STATUS_ALLOC_FAILED: c_int = -2;
pub const GGML_STATUS_FAILED: c_int = -1;
pub const GGML_STATUS_SUCCESS: c_int = 0;
pub const GGML_STATUS_ABORTED: c_int = 1;
pub const enum_ggml_status = c_int;
pub extern fn ggml_status_to_string(status: enum_ggml_status) [*c]const u8;
pub const ggml_fp16_t = u16;
pub extern fn ggml_fp16_to_fp32(ggml_fp16_t) f32;
pub extern fn ggml_fp32_to_fp16(f32) ggml_fp16_t;
pub extern fn ggml_fp16_to_fp32_row([*c]const ggml_fp16_t, [*c]f32, i64) void;
pub extern fn ggml_fp32_to_fp16_row([*c]const f32, [*c]ggml_fp16_t, i64) void;
pub const ggml_bf16_t = extern struct {
    bits: u16 = 0,
    pub const ggml_bf16_to_fp32 = __root.ggml_bf16_to_fp32;
    pub const ggml_bf16_to_fp32_row = __root.ggml_bf16_to_fp32_row;
    pub const ggml_cpu_bf16_to_fp32 = __root.ggml_cpu_bf16_to_fp32;
    pub const fp32 = __root.ggml_bf16_to_fp32;
    pub const row = __root.ggml_bf16_to_fp32_row;
};
pub extern fn ggml_fp32_to_bf16(f32) ggml_bf16_t;
pub extern fn ggml_bf16_to_fp32(ggml_bf16_t) f32;
pub extern fn ggml_bf16_to_fp32_row([*c]const ggml_bf16_t, [*c]f32, i64) void;
pub extern fn ggml_fp32_to_bf16_row_ref([*c]const f32, [*c]ggml_bf16_t, i64) void;
pub extern fn ggml_fp32_to_bf16_row([*c]const f32, [*c]ggml_bf16_t, i64) void;
pub const struct_ggml_object = opaque {
    pub const ggml_print_object = __root.ggml_print_object;
    pub const object = __root.ggml_print_object;
};
pub const struct_ggml_context = opaque {
    pub const ggml_print_objects = __root.ggml_print_objects;
    pub const ggml_reset = __root.ggml_reset;
    pub const ggml_free = __root.ggml_free;
    pub const ggml_used_mem = __root.ggml_used_mem;
    pub const ggml_get_no_alloc = __root.ggml_get_no_alloc;
    pub const ggml_set_no_alloc = __root.ggml_set_no_alloc;
    pub const ggml_get_mem_buffer = __root.ggml_get_mem_buffer;
    pub const ggml_get_mem_size = __root.ggml_get_mem_size;
    pub const ggml_get_max_tensor_size = __root.ggml_get_max_tensor_size;
    pub const ggml_new_tensor = __root.ggml_new_tensor;
    pub const ggml_new_tensor_1d = __root.ggml_new_tensor_1d;
    pub const ggml_new_tensor_2d = __root.ggml_new_tensor_2d;
    pub const ggml_new_tensor_3d = __root.ggml_new_tensor_3d;
    pub const ggml_new_tensor_4d = __root.ggml_new_tensor_4d;
    pub const ggml_new_buffer = __root.ggml_new_buffer;
    pub const ggml_dup_tensor = __root.ggml_dup_tensor;
    pub const ggml_view_tensor = __root.ggml_view_tensor;
    pub const ggml_get_first_tensor = __root.ggml_get_first_tensor;
    pub const ggml_get_next_tensor = __root.ggml_get_next_tensor;
    pub const ggml_get_tensor = __root.ggml_get_tensor;
    pub const ggml_dup = __root.ggml_dup;
    pub const ggml_dup_inplace = __root.ggml_dup_inplace;
    pub const ggml_add = __root.ggml_add;
    pub const ggml_add_inplace = __root.ggml_add_inplace;
    pub const ggml_add_cast = __root.ggml_add_cast;
    pub const ggml_add_id = __root.ggml_add_id;
    pub const ggml_add1 = __root.ggml_add1;
    pub const ggml_add1_inplace = __root.ggml_add1_inplace;
    pub const ggml_acc = __root.ggml_acc;
    pub const ggml_acc_inplace = __root.ggml_acc_inplace;
    pub const ggml_sub = __root.ggml_sub;
    pub const ggml_sub_inplace = __root.ggml_sub_inplace;
    pub const ggml_mul = __root.ggml_mul;
    pub const ggml_mul_inplace = __root.ggml_mul_inplace;
    pub const ggml_div = __root.ggml_div;
    pub const ggml_div_inplace = __root.ggml_div_inplace;
    pub const ggml_sqr = __root.ggml_sqr;
    pub const ggml_sqr_inplace = __root.ggml_sqr_inplace;
    pub const ggml_sqrt = __root.ggml_sqrt;
    pub const ggml_sqrt_inplace = __root.ggml_sqrt_inplace;
    pub const ggml_log = __root.ggml_log;
    pub const ggml_log_inplace = __root.ggml_log_inplace;
    pub const ggml_expm1 = __root.ggml_expm1;
    pub const ggml_expm1_inplace = __root.ggml_expm1_inplace;
    pub const ggml_softplus = __root.ggml_softplus;
    pub const ggml_softplus_inplace = __root.ggml_softplus_inplace;
    pub const ggml_sin = __root.ggml_sin;
    pub const ggml_sin_inplace = __root.ggml_sin_inplace;
    pub const ggml_cos = __root.ggml_cos;
    pub const ggml_cos_inplace = __root.ggml_cos_inplace;
    pub const ggml_sum = __root.ggml_sum;
    pub const ggml_sum_rows = __root.ggml_sum_rows;
    pub const ggml_cumsum = __root.ggml_cumsum;
    pub const ggml_mean = __root.ggml_mean;
    pub const ggml_argmax = __root.ggml_argmax;
    pub const ggml_count_equal = __root.ggml_count_equal;
    pub const ggml_repeat = __root.ggml_repeat;
    pub const ggml_repeat_4d = __root.ggml_repeat_4d;
    pub const ggml_repeat_back = __root.ggml_repeat_back;
    pub const ggml_concat = __root.ggml_concat;
    pub const ggml_abs = __root.ggml_abs;
    pub const ggml_abs_inplace = __root.ggml_abs_inplace;
    pub const ggml_sgn = __root.ggml_sgn;
    pub const ggml_sgn_inplace = __root.ggml_sgn_inplace;
    pub const ggml_neg = __root.ggml_neg;
    pub const ggml_neg_inplace = __root.ggml_neg_inplace;
    pub const ggml_step = __root.ggml_step;
    pub const ggml_step_inplace = __root.ggml_step_inplace;
    pub const ggml_tanh = __root.ggml_tanh;
    pub const ggml_tanh_inplace = __root.ggml_tanh_inplace;
    pub const ggml_elu = __root.ggml_elu;
    pub const ggml_elu_inplace = __root.ggml_elu_inplace;
    pub const ggml_relu = __root.ggml_relu;
    pub const ggml_leaky_relu = __root.ggml_leaky_relu;
    pub const ggml_relu_inplace = __root.ggml_relu_inplace;
    pub const ggml_sigmoid = __root.ggml_sigmoid;
    pub const ggml_sigmoid_inplace = __root.ggml_sigmoid_inplace;
    pub const ggml_gelu = __root.ggml_gelu;
    pub const ggml_gelu_inplace = __root.ggml_gelu_inplace;
    pub const ggml_gelu_erf = __root.ggml_gelu_erf;
    pub const ggml_gelu_erf_inplace = __root.ggml_gelu_erf_inplace;
    pub const ggml_gelu_quick = __root.ggml_gelu_quick;
    pub const ggml_gelu_quick_inplace = __root.ggml_gelu_quick_inplace;
    pub const ggml_silu = __root.ggml_silu;
    pub const ggml_silu_inplace = __root.ggml_silu_inplace;
    pub const ggml_silu_back = __root.ggml_silu_back;
    pub const ggml_hardswish = __root.ggml_hardswish;
    pub const ggml_hardsigmoid = __root.ggml_hardsigmoid;
    pub const ggml_exp = __root.ggml_exp;
    pub const ggml_exp_inplace = __root.ggml_exp_inplace;
    pub const ggml_floor = __root.ggml_floor;
    pub const ggml_floor_inplace = __root.ggml_floor_inplace;
    pub const ggml_ceil = __root.ggml_ceil;
    pub const ggml_ceil_inplace = __root.ggml_ceil_inplace;
    pub const ggml_round = __root.ggml_round;
    pub const ggml_round_inplace = __root.ggml_round_inplace;
    pub const ggml_trunc = __root.ggml_trunc;
    pub const ggml_trunc_inplace = __root.ggml_trunc_inplace;
    pub const ggml_xielu = __root.ggml_xielu;
    pub const ggml_glu = __root.ggml_glu;
    pub const ggml_reglu = __root.ggml_reglu;
    pub const ggml_reglu_swapped = __root.ggml_reglu_swapped;
    pub const ggml_geglu = __root.ggml_geglu;
    pub const ggml_geglu_swapped = __root.ggml_geglu_swapped;
    pub const ggml_swiglu = __root.ggml_swiglu;
    pub const ggml_swiglu_swapped = __root.ggml_swiglu_swapped;
    pub const ggml_geglu_erf = __root.ggml_geglu_erf;
    pub const ggml_geglu_erf_swapped = __root.ggml_geglu_erf_swapped;
    pub const ggml_geglu_quick = __root.ggml_geglu_quick;
    pub const ggml_geglu_quick_swapped = __root.ggml_geglu_quick_swapped;
    pub const ggml_glu_split = __root.ggml_glu_split;
    pub const ggml_reglu_split = __root.ggml_reglu_split;
    pub const ggml_geglu_split = __root.ggml_geglu_split;
    pub const ggml_swiglu_split = __root.ggml_swiglu_split;
    pub const ggml_geglu_erf_split = __root.ggml_geglu_erf_split;
    pub const ggml_geglu_quick_split = __root.ggml_geglu_quick_split;
    pub const ggml_swiglu_oai = __root.ggml_swiglu_oai;
    pub const ggml_norm = __root.ggml_norm;
    pub const ggml_norm_inplace = __root.ggml_norm_inplace;
    pub const ggml_rms_norm = __root.ggml_rms_norm;
    pub const ggml_rms_norm_inplace = __root.ggml_rms_norm_inplace;
    pub const ggml_group_norm = __root.ggml_group_norm;
    pub const ggml_group_norm_inplace = __root.ggml_group_norm_inplace;
    pub const ggml_l2_norm = __root.ggml_l2_norm;
    pub const ggml_l2_norm_inplace = __root.ggml_l2_norm_inplace;
    pub const ggml_rms_norm_back = __root.ggml_rms_norm_back;
    pub const ggml_mul_mat = __root.ggml_mul_mat;
    pub const ggml_mul_mat_id = __root.ggml_mul_mat_id;
    pub const ggml_out_prod = __root.ggml_out_prod;
    pub const ggml_scale = __root.ggml_scale;
    pub const ggml_scale_inplace = __root.ggml_scale_inplace;
    pub const ggml_scale_bias = __root.ggml_scale_bias;
    pub const ggml_scale_bias_inplace = __root.ggml_scale_bias_inplace;
    pub const ggml_set = __root.ggml_set;
    pub const ggml_set_inplace = __root.ggml_set_inplace;
    pub const ggml_set_1d = __root.ggml_set_1d;
    pub const ggml_set_1d_inplace = __root.ggml_set_1d_inplace;
    pub const ggml_set_2d = __root.ggml_set_2d;
    pub const ggml_set_2d_inplace = __root.ggml_set_2d_inplace;
    pub const ggml_cpy = __root.ggml_cpy;
    pub const ggml_cast = __root.ggml_cast;
    pub const ggml_cont = __root.ggml_cont;
    pub const ggml_cont_1d = __root.ggml_cont_1d;
    pub const ggml_cont_2d = __root.ggml_cont_2d;
    pub const ggml_cont_3d = __root.ggml_cont_3d;
    pub const ggml_cont_4d = __root.ggml_cont_4d;
    pub const ggml_reshape = __root.ggml_reshape;
    pub const ggml_reshape_1d = __root.ggml_reshape_1d;
    pub const ggml_reshape_2d = __root.ggml_reshape_2d;
    pub const ggml_reshape_3d = __root.ggml_reshape_3d;
    pub const ggml_reshape_4d = __root.ggml_reshape_4d;
    pub const ggml_view_1d = __root.ggml_view_1d;
    pub const ggml_view_2d = __root.ggml_view_2d;
    pub const ggml_view_3d = __root.ggml_view_3d;
    pub const ggml_view_4d = __root.ggml_view_4d;
    pub const ggml_permute = __root.ggml_permute;
    pub const ggml_transpose = __root.ggml_transpose;
    pub const ggml_get_rows = __root.ggml_get_rows;
    pub const ggml_get_rows_back = __root.ggml_get_rows_back;
    pub const ggml_set_rows = __root.ggml_set_rows;
    pub const ggml_diag = __root.ggml_diag;
    pub const ggml_diag_mask_inf = __root.ggml_diag_mask_inf;
    pub const ggml_diag_mask_inf_inplace = __root.ggml_diag_mask_inf_inplace;
    pub const ggml_diag_mask_zero = __root.ggml_diag_mask_zero;
    pub const ggml_diag_mask_zero_inplace = __root.ggml_diag_mask_zero_inplace;
    pub const ggml_soft_max = __root.ggml_soft_max;
    pub const ggml_soft_max_inplace = __root.ggml_soft_max_inplace;
    pub const ggml_soft_max_ext = __root.ggml_soft_max_ext;
    pub const ggml_soft_max_ext_inplace = __root.ggml_soft_max_ext_inplace;
    pub const ggml_soft_max_ext_back = __root.ggml_soft_max_ext_back;
    pub const ggml_soft_max_ext_back_inplace = __root.ggml_soft_max_ext_back_inplace;
    pub const ggml_rope = __root.ggml_rope;
    pub const ggml_rope_inplace = __root.ggml_rope_inplace;
    pub const ggml_rope_ext = __root.ggml_rope_ext;
    pub const ggml_rope_multi = __root.ggml_rope_multi;
    pub const ggml_rope_ext_inplace = __root.ggml_rope_ext_inplace;
    pub const ggml_rope_multi_inplace = __root.ggml_rope_multi_inplace;
    pub const ggml_rope_custom = __root.ggml_rope_custom;
    pub const ggml_rope_custom_inplace = __root.ggml_rope_custom_inplace;
    pub const ggml_rope_ext_back = __root.ggml_rope_ext_back;
    pub const ggml_rope_multi_back = __root.ggml_rope_multi_back;
    pub const ggml_clamp = __root.ggml_clamp;
    pub const ggml_im2col = __root.ggml_im2col;
    pub const ggml_im2col_back = __root.ggml_im2col_back;
    pub const ggml_conv_1d = __root.ggml_conv_1d;
    pub const ggml_conv_1d_ph = __root.ggml_conv_1d_ph;
    pub const ggml_conv_1d_dw = __root.ggml_conv_1d_dw;
    pub const ggml_conv_1d_dw_ph = __root.ggml_conv_1d_dw_ph;
    pub const ggml_conv_transpose_1d = __root.ggml_conv_transpose_1d;
    pub const ggml_conv_2d = __root.ggml_conv_2d;
    pub const ggml_im2col_3d = __root.ggml_im2col_3d;
    pub const ggml_conv_3d = __root.ggml_conv_3d;
    pub const ggml_conv_2d_sk_p0 = __root.ggml_conv_2d_sk_p0;
    pub const ggml_conv_2d_s1_ph = __root.ggml_conv_2d_s1_ph;
    pub const ggml_conv_2d_dw = __root.ggml_conv_2d_dw;
    pub const ggml_conv_2d_dw_direct = __root.ggml_conv_2d_dw_direct;
    pub const ggml_conv_transpose_2d_p0 = __root.ggml_conv_transpose_2d_p0;
    pub const ggml_conv_2d_direct = __root.ggml_conv_2d_direct;
    pub const ggml_conv_3d_direct = __root.ggml_conv_3d_direct;
    pub const ggml_pool_1d = __root.ggml_pool_1d;
    pub const ggml_pool_2d = __root.ggml_pool_2d;
    pub const ggml_pool_2d_back = __root.ggml_pool_2d_back;
    pub const ggml_upscale = __root.ggml_upscale;
    pub const ggml_upscale_ext = __root.ggml_upscale_ext;
    pub const ggml_interpolate = __root.ggml_interpolate;
    pub const ggml_pad = __root.ggml_pad;
    pub const ggml_pad_circular = __root.ggml_pad_circular;
    pub const ggml_pad_ext = __root.ggml_pad_ext;
    pub const ggml_pad_ext_circular = __root.ggml_pad_ext_circular;
    pub const ggml_pad_reflect_1d = __root.ggml_pad_reflect_1d;
    pub const ggml_roll = __root.ggml_roll;
    pub const ggml_tri = __root.ggml_tri;
    pub const ggml_fill = __root.ggml_fill;
    pub const ggml_fill_inplace = __root.ggml_fill_inplace;
    pub const ggml_timestep_embedding = __root.ggml_timestep_embedding;
    pub const ggml_argsort = __root.ggml_argsort;
    pub const ggml_argsort_top_k = __root.ggml_argsort_top_k;
    pub const ggml_top_k = __root.ggml_top_k;
    pub const ggml_arange = __root.ggml_arange;
    pub const ggml_flash_attn_ext = __root.ggml_flash_attn_ext;
    pub const ggml_flash_attn_back = __root.ggml_flash_attn_back;
    pub const ggml_ssm_conv = __root.ggml_ssm_conv;
    pub const ggml_ssm_scan = __root.ggml_ssm_scan;
    pub const ggml_win_part = __root.ggml_win_part;
    pub const ggml_win_unpart = __root.ggml_win_unpart;
    pub const ggml_unary = __root.ggml_unary;
    pub const ggml_unary_inplace = __root.ggml_unary_inplace;
    pub const ggml_get_rel_pos = __root.ggml_get_rel_pos;
    pub const ggml_add_rel_pos = __root.ggml_add_rel_pos;
    pub const ggml_add_rel_pos_inplace = __root.ggml_add_rel_pos_inplace;
    pub const ggml_rwkv_wkv6 = __root.ggml_rwkv_wkv6;
    pub const ggml_gated_linear_attn = __root.ggml_gated_linear_attn;
    pub const ggml_rwkv_wkv7 = __root.ggml_rwkv_wkv7;
    pub const ggml_solve_tri = __root.ggml_solve_tri;
    pub const ggml_gated_delta_net = __root.ggml_gated_delta_net;
    pub const ggml_map_custom1 = __root.ggml_map_custom1;
    pub const ggml_map_custom1_inplace = __root.ggml_map_custom1_inplace;
    pub const ggml_map_custom2 = __root.ggml_map_custom2;
    pub const ggml_map_custom2_inplace = __root.ggml_map_custom2_inplace;
    pub const ggml_map_custom3 = __root.ggml_map_custom3;
    pub const ggml_map_custom3_inplace = __root.ggml_map_custom3_inplace;
    pub const ggml_custom_4d = __root.ggml_custom_4d;
    pub const ggml_custom_inplace = __root.ggml_custom_inplace;
    pub const ggml_cross_entropy_loss = __root.ggml_cross_entropy_loss;
    pub const ggml_cross_entropy_loss_back = __root.ggml_cross_entropy_loss_back;
    pub const ggml_opt_step_adamw = __root.ggml_opt_step_adamw;
    pub const ggml_opt_step_sgd = __root.ggml_opt_step_sgd;
    pub const ggml_build_backward_expand = __root.ggml_build_backward_expand;
    pub const ggml_new_graph = __root.ggml_new_graph;
    pub const ggml_new_graph_custom = __root.ggml_new_graph_custom;
    pub const ggml_graph_dup = __root.ggml_graph_dup;
    pub const ggml_backend_alloc_ctx_tensors_from_buft_size = __root.ggml_backend_alloc_ctx_tensors_from_buft_size;
    pub const ggml_backend_alloc_ctx_tensors_from_buft = __root.ggml_backend_alloc_ctx_tensors_from_buft;
    pub const ggml_backend_alloc_ctx_tensors = __root.ggml_backend_alloc_ctx_tensors;
    pub const ggml_new_i32 = __root.ggml_new_i32;
    pub const ggml_new_f32 = __root.ggml_new_f32;
    pub const ggml_graph_compute_with_ctx = __root.ggml_graph_compute_with_ctx;
    pub const objects = __root.ggml_print_objects;
    pub const reset = __root.ggml_reset;
    pub const free = __root.ggml_free;
    pub const mem = __root.ggml_used_mem;
    pub const alloc = __root.ggml_get_no_alloc;
    pub const buffer = __root.ggml_get_mem_buffer;
    pub const size = __root.ggml_get_mem_size;
    pub const tensor = __root.ggml_new_tensor;
    pub const @"1d" = __root.ggml_new_tensor_1d;
    pub const @"2d" = __root.ggml_new_tensor_2d;
    pub const @"3d" = __root.ggml_new_tensor_3d;
    pub const @"4d" = __root.ggml_new_tensor_4d;
    pub const dup = __root.ggml_dup;
    pub const inplace = __root.ggml_dup_inplace;
    pub const add = __root.ggml_add;
    pub const cast = __root.ggml_add_cast;
    pub const id = __root.ggml_add_id;
    pub const add1 = __root.ggml_add1;
    pub const acc = __root.ggml_acc;
    pub const sub = __root.ggml_sub;
    pub const mul = __root.ggml_mul;
    pub const div = __root.ggml_div;
    pub const sqr = __root.ggml_sqr;
    pub const sqrt = __root.ggml_sqrt;
    pub const log = __root.ggml_log;
    pub const expm1 = __root.ggml_expm1;
    pub const softplus = __root.ggml_softplus;
    pub const sin = __root.ggml_sin;
    pub const cos = __root.ggml_cos;
    pub const sum = __root.ggml_sum;
    pub const rows = __root.ggml_sum_rows;
    pub const cumsum = __root.ggml_cumsum;
    pub const mean = __root.ggml_mean;
    pub const argmax = __root.ggml_argmax;
    pub const equal = __root.ggml_count_equal;
    pub const repeat = __root.ggml_repeat;
    pub const back = __root.ggml_repeat_back;
    pub const concat = __root.ggml_concat;
    pub const abs = __root.ggml_abs;
    pub const sgn = __root.ggml_sgn;
    pub const neg = __root.ggml_neg;
    pub const step = __root.ggml_step;
    pub const tanh = __root.ggml_tanh;
    pub const elu = __root.ggml_elu;
    pub const relu = __root.ggml_relu;
    pub const sigmoid = __root.ggml_sigmoid;
    pub const gelu = __root.ggml_gelu;
    pub const erf = __root.ggml_gelu_erf;
    pub const quick = __root.ggml_gelu_quick;
    pub const silu = __root.ggml_silu;
    pub const hardswish = __root.ggml_hardswish;
    pub const hardsigmoid = __root.ggml_hardsigmoid;
    pub const exp = __root.ggml_exp;
    pub const floor = __root.ggml_floor;
    pub const ceil = __root.ggml_ceil;
    pub const round = __root.ggml_round;
    pub const trunc = __root.ggml_trunc;
    pub const xielu = __root.ggml_xielu;
    pub const glu = __root.ggml_glu;
    pub const reglu = __root.ggml_reglu;
    pub const swapped = __root.ggml_reglu_swapped;
    pub const geglu = __root.ggml_geglu;
    pub const swiglu = __root.ggml_swiglu;
    pub const split = __root.ggml_glu_split;
    pub const oai = __root.ggml_swiglu_oai;
    pub const norm = __root.ggml_norm;
    pub const mat = __root.ggml_mul_mat;
    pub const prod = __root.ggml_out_prod;
    pub const scale = __root.ggml_scale;
    pub const bias = __root.ggml_scale_bias;
    pub const set = __root.ggml_set;
    pub const cpy = __root.ggml_cpy;
    pub const cont = __root.ggml_cont;
    pub const reshape = __root.ggml_reshape;
    pub const permute = __root.ggml_permute;
    pub const transpose = __root.ggml_transpose;
    pub const diag = __root.ggml_diag;
    pub const inf = __root.ggml_diag_mask_inf;
    pub const zero = __root.ggml_diag_mask_zero;
    pub const max = __root.ggml_soft_max;
    pub const ext = __root.ggml_soft_max_ext;
    pub const rope = __root.ggml_rope;
    pub const multi = __root.ggml_rope_multi;
    pub const custom = __root.ggml_rope_custom;
    pub const clamp = __root.ggml_clamp;
    pub const im2col = __root.ggml_im2col;
    pub const ph = __root.ggml_conv_1d_ph;
    pub const dw = __root.ggml_conv_1d_dw;
    pub const p0 = __root.ggml_conv_2d_sk_p0;
    pub const direct = __root.ggml_conv_2d_dw_direct;
    pub const upscale = __root.ggml_upscale;
    pub const interpolate = __root.ggml_interpolate;
    pub const pad = __root.ggml_pad;
    pub const circular = __root.ggml_pad_circular;
    pub const roll = __root.ggml_roll;
    pub const tri = __root.ggml_tri;
    pub const fill = __root.ggml_fill;
    pub const embedding = __root.ggml_timestep_embedding;
    pub const argsort = __root.ggml_argsort;
    pub const k = __root.ggml_argsort_top_k;
    pub const arange = __root.ggml_arange;
    pub const conv = __root.ggml_ssm_conv;
    pub const scan = __root.ggml_ssm_scan;
    pub const part = __root.ggml_win_part;
    pub const unpart = __root.ggml_win_unpart;
    pub const unary = __root.ggml_unary;
    pub const pos = __root.ggml_get_rel_pos;
    pub const wkv6 = __root.ggml_rwkv_wkv6;
    pub const attn = __root.ggml_gated_linear_attn;
    pub const wkv7 = __root.ggml_rwkv_wkv7;
    pub const net = __root.ggml_gated_delta_net;
    pub const custom1 = __root.ggml_map_custom1;
    pub const custom2 = __root.ggml_map_custom2;
    pub const custom3 = __root.ggml_map_custom3;
    pub const loss = __root.ggml_cross_entropy_loss;
    pub const adamw = __root.ggml_opt_step_adamw;
    pub const sgd = __root.ggml_opt_step_sgd;
    pub const expand = __root.ggml_build_backward_expand;
    pub const graph = __root.ggml_new_graph;
    pub const buft = __root.ggml_backend_alloc_ctx_tensors_from_buft;
    pub const tensors = __root.ggml_backend_alloc_ctx_tensors;
    pub const @"i32" = __root.ggml_new_i32;
    pub const @"f32" = __root.ggml_new_f32;
    pub const ctx = __root.ggml_graph_compute_with_ctx;
};
pub const struct_ggml_cgraph = opaque {
    pub const ggml_build_forward_select = __root.ggml_build_forward_select;
    pub const ggml_build_forward_expand = __root.ggml_build_forward_expand;
    pub const ggml_graph_cpy = __root.ggml_graph_cpy;
    pub const ggml_graph_reset = __root.ggml_graph_reset;
    pub const ggml_graph_clear = __root.ggml_graph_clear;
    pub const ggml_graph_size = __root.ggml_graph_size;
    pub const ggml_graph_node = __root.ggml_graph_node;
    pub const ggml_graph_nodes = __root.ggml_graph_nodes;
    pub const ggml_graph_n_nodes = __root.ggml_graph_n_nodes;
    pub const ggml_graph_add_node = __root.ggml_graph_add_node;
    pub const ggml_graph_get_tensor = __root.ggml_graph_get_tensor;
    pub const ggml_graph_get_grad = __root.ggml_graph_get_grad;
    pub const ggml_graph_get_grad_acc = __root.ggml_graph_get_grad_acc;
    pub const ggml_graph_print = __root.ggml_graph_print;
    pub const ggml_graph_dump_dot = __root.ggml_graph_dump_dot;
    pub const ggml_graph_plan = __root.ggml_graph_plan;
    pub const ggml_graph_compute = __root.ggml_graph_compute;
    pub const select = __root.ggml_build_forward_select;
    pub const expand = __root.ggml_build_forward_expand;
    pub const cpy = __root.ggml_graph_cpy;
    pub const reset = __root.ggml_graph_reset;
    pub const clear = __root.ggml_graph_clear;
    pub const size = __root.ggml_graph_size;
    pub const node = __root.ggml_graph_node;
    pub const nodes = __root.ggml_graph_nodes;
    pub const tensor = __root.ggml_graph_get_tensor;
    pub const grad = __root.ggml_graph_get_grad;
    pub const acc = __root.ggml_graph_get_grad_acc;
    pub const print = __root.ggml_graph_print;
    pub const dot = __root.ggml_graph_dump_dot;
    pub const plan = __root.ggml_graph_plan;
    pub const compute = __root.ggml_graph_compute;
};
pub const GGML_TYPE_F32: c_int = 0;
pub const GGML_TYPE_F16: c_int = 1;
pub const GGML_TYPE_Q4_0: c_int = 2;
pub const GGML_TYPE_Q4_1: c_int = 3;
pub const GGML_TYPE_Q5_0: c_int = 6;
pub const GGML_TYPE_Q5_1: c_int = 7;
pub const GGML_TYPE_Q8_0: c_int = 8;
pub const GGML_TYPE_Q8_1: c_int = 9;
pub const GGML_TYPE_Q2_K: c_int = 10;
pub const GGML_TYPE_Q3_K: c_int = 11;
pub const GGML_TYPE_Q4_K: c_int = 12;
pub const GGML_TYPE_Q5_K: c_int = 13;
pub const GGML_TYPE_Q6_K: c_int = 14;
pub const GGML_TYPE_Q8_K: c_int = 15;
pub const GGML_TYPE_IQ2_XXS: c_int = 16;
pub const GGML_TYPE_IQ2_XS: c_int = 17;
pub const GGML_TYPE_IQ3_XXS: c_int = 18;
pub const GGML_TYPE_IQ1_S: c_int = 19;
pub const GGML_TYPE_IQ4_NL: c_int = 20;
pub const GGML_TYPE_IQ3_S: c_int = 21;
pub const GGML_TYPE_IQ2_S: c_int = 22;
pub const GGML_TYPE_IQ4_XS: c_int = 23;
pub const GGML_TYPE_I8: c_int = 24;
pub const GGML_TYPE_I16: c_int = 25;
pub const GGML_TYPE_I32: c_int = 26;
pub const GGML_TYPE_I64: c_int = 27;
pub const GGML_TYPE_F64: c_int = 28;
pub const GGML_TYPE_IQ1_M: c_int = 29;
pub const GGML_TYPE_BF16: c_int = 30;
pub const GGML_TYPE_TQ1_0: c_int = 34;
pub const GGML_TYPE_TQ2_0: c_int = 35;
pub const GGML_TYPE_MXFP4: c_int = 39;
pub const GGML_TYPE_NVFP4: c_int = 40;
pub const GGML_TYPE_Q1_0: c_int = 41;
pub const GGML_TYPE_COUNT: c_int = 42;
pub const enum_ggml_type = c_uint;
pub const GGML_PREC_DEFAULT: c_int = 0;
pub const GGML_PREC_F32: c_int = 10;
pub const enum_ggml_prec = c_uint;
pub const GGML_FTYPE_UNKNOWN: c_int = -1;
pub const GGML_FTYPE_ALL_F32: c_int = 0;
pub const GGML_FTYPE_MOSTLY_F16: c_int = 1;
pub const GGML_FTYPE_MOSTLY_Q4_0: c_int = 2;
pub const GGML_FTYPE_MOSTLY_Q4_1: c_int = 3;
pub const GGML_FTYPE_MOSTLY_Q4_1_SOME_F16: c_int = 4;
pub const GGML_FTYPE_MOSTLY_Q8_0: c_int = 7;
pub const GGML_FTYPE_MOSTLY_Q5_0: c_int = 8;
pub const GGML_FTYPE_MOSTLY_Q5_1: c_int = 9;
pub const GGML_FTYPE_MOSTLY_Q2_K: c_int = 10;
pub const GGML_FTYPE_MOSTLY_Q3_K: c_int = 11;
pub const GGML_FTYPE_MOSTLY_Q4_K: c_int = 12;
pub const GGML_FTYPE_MOSTLY_Q5_K: c_int = 13;
pub const GGML_FTYPE_MOSTLY_Q6_K: c_int = 14;
pub const GGML_FTYPE_MOSTLY_IQ2_XXS: c_int = 15;
pub const GGML_FTYPE_MOSTLY_IQ2_XS: c_int = 16;
pub const GGML_FTYPE_MOSTLY_IQ3_XXS: c_int = 17;
pub const GGML_FTYPE_MOSTLY_IQ1_S: c_int = 18;
pub const GGML_FTYPE_MOSTLY_IQ4_NL: c_int = 19;
pub const GGML_FTYPE_MOSTLY_IQ3_S: c_int = 20;
pub const GGML_FTYPE_MOSTLY_IQ2_S: c_int = 21;
pub const GGML_FTYPE_MOSTLY_IQ4_XS: c_int = 22;
pub const GGML_FTYPE_MOSTLY_IQ1_M: c_int = 23;
pub const GGML_FTYPE_MOSTLY_BF16: c_int = 24;
pub const GGML_FTYPE_MOSTLY_MXFP4: c_int = 25;
pub const GGML_FTYPE_MOSTLY_NVFP4: c_int = 26;
pub const GGML_FTYPE_MOSTLY_Q1_0: c_int = 27;
pub const enum_ggml_ftype = c_int;
pub const GGML_OP_NONE: c_int = 0;
pub const GGML_OP_DUP: c_int = 1;
pub const GGML_OP_ADD: c_int = 2;
pub const GGML_OP_ADD_ID: c_int = 3;
pub const GGML_OP_ADD1: c_int = 4;
pub const GGML_OP_ACC: c_int = 5;
pub const GGML_OP_SUB: c_int = 6;
pub const GGML_OP_MUL: c_int = 7;
pub const GGML_OP_DIV: c_int = 8;
pub const GGML_OP_SQR: c_int = 9;
pub const GGML_OP_SQRT: c_int = 10;
pub const GGML_OP_LOG: c_int = 11;
pub const GGML_OP_SIN: c_int = 12;
pub const GGML_OP_COS: c_int = 13;
pub const GGML_OP_SUM: c_int = 14;
pub const GGML_OP_SUM_ROWS: c_int = 15;
pub const GGML_OP_CUMSUM: c_int = 16;
pub const GGML_OP_MEAN: c_int = 17;
pub const GGML_OP_ARGMAX: c_int = 18;
pub const GGML_OP_COUNT_EQUAL: c_int = 19;
pub const GGML_OP_REPEAT: c_int = 20;
pub const GGML_OP_REPEAT_BACK: c_int = 21;
pub const GGML_OP_CONCAT: c_int = 22;
pub const GGML_OP_SILU_BACK: c_int = 23;
pub const GGML_OP_NORM: c_int = 24;
pub const GGML_OP_RMS_NORM: c_int = 25;
pub const GGML_OP_RMS_NORM_BACK: c_int = 26;
pub const GGML_OP_GROUP_NORM: c_int = 27;
pub const GGML_OP_L2_NORM: c_int = 28;
pub const GGML_OP_MUL_MAT: c_int = 29;
pub const GGML_OP_MUL_MAT_ID: c_int = 30;
pub const GGML_OP_OUT_PROD: c_int = 31;
pub const GGML_OP_SCALE: c_int = 32;
pub const GGML_OP_SET: c_int = 33;
pub const GGML_OP_CPY: c_int = 34;
pub const GGML_OP_CONT: c_int = 35;
pub const GGML_OP_RESHAPE: c_int = 36;
pub const GGML_OP_VIEW: c_int = 37;
pub const GGML_OP_PERMUTE: c_int = 38;
pub const GGML_OP_TRANSPOSE: c_int = 39;
pub const GGML_OP_GET_ROWS: c_int = 40;
pub const GGML_OP_GET_ROWS_BACK: c_int = 41;
pub const GGML_OP_SET_ROWS: c_int = 42;
pub const GGML_OP_DIAG: c_int = 43;
pub const GGML_OP_DIAG_MASK_INF: c_int = 44;
pub const GGML_OP_DIAG_MASK_ZERO: c_int = 45;
pub const GGML_OP_SOFT_MAX: c_int = 46;
pub const GGML_OP_SOFT_MAX_BACK: c_int = 47;
pub const GGML_OP_ROPE: c_int = 48;
pub const GGML_OP_ROPE_BACK: c_int = 49;
pub const GGML_OP_CLAMP: c_int = 50;
pub const GGML_OP_CONV_TRANSPOSE_1D: c_int = 51;
pub const GGML_OP_IM2COL: c_int = 52;
pub const GGML_OP_IM2COL_BACK: c_int = 53;
pub const GGML_OP_IM2COL_3D: c_int = 54;
pub const GGML_OP_CONV_2D: c_int = 55;
pub const GGML_OP_CONV_3D: c_int = 56;
pub const GGML_OP_CONV_2D_DW: c_int = 57;
pub const GGML_OP_CONV_TRANSPOSE_2D: c_int = 58;
pub const GGML_OP_POOL_1D: c_int = 59;
pub const GGML_OP_POOL_2D: c_int = 60;
pub const GGML_OP_POOL_2D_BACK: c_int = 61;
pub const GGML_OP_UPSCALE: c_int = 62;
pub const GGML_OP_PAD: c_int = 63;
pub const GGML_OP_PAD_REFLECT_1D: c_int = 64;
pub const GGML_OP_ROLL: c_int = 65;
pub const GGML_OP_ARANGE: c_int = 66;
pub const GGML_OP_TIMESTEP_EMBEDDING: c_int = 67;
pub const GGML_OP_ARGSORT: c_int = 68;
pub const GGML_OP_TOP_K: c_int = 69;
pub const GGML_OP_LEAKY_RELU: c_int = 70;
pub const GGML_OP_TRI: c_int = 71;
pub const GGML_OP_FILL: c_int = 72;
pub const GGML_OP_FLASH_ATTN_EXT: c_int = 73;
pub const GGML_OP_FLASH_ATTN_BACK: c_int = 74;
pub const GGML_OP_SSM_CONV: c_int = 75;
pub const GGML_OP_SSM_SCAN: c_int = 76;
pub const GGML_OP_WIN_PART: c_int = 77;
pub const GGML_OP_WIN_UNPART: c_int = 78;
pub const GGML_OP_GET_REL_POS: c_int = 79;
pub const GGML_OP_ADD_REL_POS: c_int = 80;
pub const GGML_OP_RWKV_WKV6: c_int = 81;
pub const GGML_OP_GATED_LINEAR_ATTN: c_int = 82;
pub const GGML_OP_RWKV_WKV7: c_int = 83;
pub const GGML_OP_SOLVE_TRI: c_int = 84;
pub const GGML_OP_GATED_DELTA_NET: c_int = 85;
pub const GGML_OP_UNARY: c_int = 86;
pub const GGML_OP_MAP_CUSTOM1: c_int = 87;
pub const GGML_OP_MAP_CUSTOM2: c_int = 88;
pub const GGML_OP_MAP_CUSTOM3: c_int = 89;
pub const GGML_OP_CUSTOM: c_int = 90;
pub const GGML_OP_CROSS_ENTROPY_LOSS: c_int = 91;
pub const GGML_OP_CROSS_ENTROPY_LOSS_BACK: c_int = 92;
pub const GGML_OP_OPT_STEP_ADAMW: c_int = 93;
pub const GGML_OP_OPT_STEP_SGD: c_int = 94;
pub const GGML_OP_GLU: c_int = 95;
pub const GGML_OP_COUNT: c_int = 96;
pub const enum_ggml_op = c_uint;
pub const GGML_UNARY_OP_ABS: c_int = 0;
pub const GGML_UNARY_OP_SGN: c_int = 1;
pub const GGML_UNARY_OP_NEG: c_int = 2;
pub const GGML_UNARY_OP_STEP: c_int = 3;
pub const GGML_UNARY_OP_TANH: c_int = 4;
pub const GGML_UNARY_OP_ELU: c_int = 5;
pub const GGML_UNARY_OP_RELU: c_int = 6;
pub const GGML_UNARY_OP_SIGMOID: c_int = 7;
pub const GGML_UNARY_OP_GELU: c_int = 8;
pub const GGML_UNARY_OP_GELU_QUICK: c_int = 9;
pub const GGML_UNARY_OP_SILU: c_int = 10;
pub const GGML_UNARY_OP_HARDSWISH: c_int = 11;
pub const GGML_UNARY_OP_HARDSIGMOID: c_int = 12;
pub const GGML_UNARY_OP_EXP: c_int = 13;
pub const GGML_UNARY_OP_EXPM1: c_int = 14;
pub const GGML_UNARY_OP_SOFTPLUS: c_int = 15;
pub const GGML_UNARY_OP_GELU_ERF: c_int = 16;
pub const GGML_UNARY_OP_XIELU: c_int = 17;
pub const GGML_UNARY_OP_FLOOR: c_int = 18;
pub const GGML_UNARY_OP_CEIL: c_int = 19;
pub const GGML_UNARY_OP_ROUND: c_int = 20;
pub const GGML_UNARY_OP_TRUNC: c_int = 21;
pub const GGML_UNARY_OP_COUNT: c_int = 22;
pub const enum_ggml_unary_op = c_uint;
pub const GGML_GLU_OP_REGLU: c_int = 0;
pub const GGML_GLU_OP_GEGLU: c_int = 1;
pub const GGML_GLU_OP_SWIGLU: c_int = 2;
pub const GGML_GLU_OP_SWIGLU_OAI: c_int = 3;
pub const GGML_GLU_OP_GEGLU_ERF: c_int = 4;
pub const GGML_GLU_OP_GEGLU_QUICK: c_int = 5;
pub const GGML_GLU_OP_COUNT: c_int = 6;
pub const enum_ggml_glu_op = c_uint;
pub const GGML_OBJECT_TYPE_TENSOR: c_int = 0;
pub const GGML_OBJECT_TYPE_GRAPH: c_int = 1;
pub const GGML_OBJECT_TYPE_WORK_BUFFER: c_int = 2;
pub const enum_ggml_object_type = c_uint;
pub const GGML_LOG_LEVEL_NONE: c_int = 0;
pub const GGML_LOG_LEVEL_DEBUG: c_int = 1;
pub const GGML_LOG_LEVEL_INFO: c_int = 2;
pub const GGML_LOG_LEVEL_WARN: c_int = 3;
pub const GGML_LOG_LEVEL_ERROR: c_int = 4;
pub const GGML_LOG_LEVEL_CONT: c_int = 5;
pub const enum_ggml_log_level = c_uint;
pub const GGML_TENSOR_FLAG_INPUT: c_int = 1;
pub const GGML_TENSOR_FLAG_OUTPUT: c_int = 2;
pub const GGML_TENSOR_FLAG_PARAM: c_int = 4;
pub const GGML_TENSOR_FLAG_LOSS: c_int = 8;
pub const GGML_TENSOR_FLAG_COMPUTE: c_int = 16;
pub const enum_ggml_tensor_flag = c_uint;
pub const GGML_TRI_TYPE_UPPER_DIAG: c_int = 0;
pub const GGML_TRI_TYPE_UPPER: c_int = 1;
pub const GGML_TRI_TYPE_LOWER_DIAG: c_int = 2;
pub const GGML_TRI_TYPE_LOWER: c_int = 3;
pub const enum_ggml_tri_type = c_uint;
pub const struct_ggml_init_params = extern struct {
    mem_size: usize = 0,
    mem_buffer: ?*anyopaque = null,
    no_alloc: bool = false,
    pub const ggml_init = __root.ggml_init;
    pub const init = __root.ggml_init;
};
pub const struct_ggml_backend_buffer_3 = opaque {
    pub const ggml_tallocr_new = __root.ggml_tallocr_new;
    pub const ggml_backend_buffer_name = __root.ggml_backend_buffer_name;
    pub const ggml_backend_buffer_free = __root.ggml_backend_buffer_free;
    pub const ggml_backend_buffer_get_base = __root.ggml_backend_buffer_get_base;
    pub const ggml_backend_buffer_get_size = __root.ggml_backend_buffer_get_size;
    pub const ggml_backend_buffer_init_tensor = __root.ggml_backend_buffer_init_tensor;
    pub const ggml_backend_buffer_get_alignment = __root.ggml_backend_buffer_get_alignment;
    pub const ggml_backend_buffer_get_max_size = __root.ggml_backend_buffer_get_max_size;
    pub const ggml_backend_buffer_get_alloc_size = __root.ggml_backend_buffer_get_alloc_size;
    pub const ggml_backend_buffer_clear = __root.ggml_backend_buffer_clear;
    pub const ggml_backend_buffer_is_host = __root.ggml_backend_buffer_is_host;
    pub const ggml_backend_buffer_set_usage = __root.ggml_backend_buffer_set_usage;
    pub const ggml_backend_buffer_get_usage = __root.ggml_backend_buffer_get_usage;
    pub const ggml_backend_buffer_get_type = __root.ggml_backend_buffer_get_type;
    pub const ggml_backend_buffer_reset = __root.ggml_backend_buffer_reset;
    pub const ggml_backend_tensor_alloc = __root.ggml_backend_tensor_alloc;
    pub const new = __root.ggml_tallocr_new;
    pub const name = __root.ggml_backend_buffer_name;
    pub const free = __root.ggml_backend_buffer_free;
    pub const get_base = __root.ggml_backend_buffer_get_base;
    pub const get_size = __root.ggml_backend_buffer_get_size;
    pub const init_tensor = __root.ggml_backend_buffer_init_tensor;
    pub const get_alignment = __root.ggml_backend_buffer_get_alignment;
    pub const get_max_size = __root.ggml_backend_buffer_get_max_size;
    pub const get_alloc_size = __root.ggml_backend_buffer_get_alloc_size;
    pub const clear = __root.ggml_backend_buffer_clear;
    pub const is_host = __root.ggml_backend_buffer_is_host;
    pub const set_usage = __root.ggml_backend_buffer_set_usage;
    pub const get_usage = __root.ggml_backend_buffer_get_usage;
    pub const get_type = __root.ggml_backend_buffer_get_type;
    pub const reset = __root.ggml_backend_buffer_reset;
    pub const alloc = __root.ggml_backend_tensor_alloc;
};
pub const struct_ggml_tensor = extern struct {
    type: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
    buffer: ?*struct_ggml_backend_buffer_3 = null,
    ne: [4]i64 = @import("std").mem.zeroes([4]i64),
    nb: [4]usize = @import("std").mem.zeroes([4]usize),
    op: enum_ggml_op = @import("std").mem.zeroes(enum_ggml_op),
    op_params: [16]i32 = @import("std").mem.zeroes([16]i32),
    flags: i32 = 0,
    src: [10][*c]struct_ggml_tensor = @import("std").mem.zeroes([10][*c]struct_ggml_tensor),
    view_src: [*c]struct_ggml_tensor = null,
    view_offs: usize = 0,
    data: ?*anyopaque = null,
    name: [64]u8 = @import("std").mem.zeroes([64]u8),
    extra: ?*anyopaque = null,
    padding: [8]u8 = @import("std").mem.zeroes([8]u8),
    pub const ggml_nelements = __root.ggml_nelements;
    pub const ggml_nrows = __root.ggml_nrows;
    pub const ggml_nbytes = __root.ggml_nbytes;
    pub const ggml_nbytes_pad = __root.ggml_nbytes_pad;
    pub const ggml_op_desc = __root.ggml_op_desc;
    pub const ggml_element_size = __root.ggml_element_size;
    pub const ggml_is_transposed = __root.ggml_is_transposed;
    pub const ggml_is_permuted = __root.ggml_is_permuted;
    pub const ggml_is_empty = __root.ggml_is_empty;
    pub const ggml_is_view = __root.ggml_is_view;
    pub const ggml_is_scalar = __root.ggml_is_scalar;
    pub const ggml_is_vector = __root.ggml_is_vector;
    pub const ggml_is_matrix = __root.ggml_is_matrix;
    pub const ggml_is_3d = __root.ggml_is_3d;
    pub const ggml_n_dims = __root.ggml_n_dims;
    pub const ggml_is_contiguous = __root.ggml_is_contiguous;
    pub const ggml_is_contiguous_0 = __root.ggml_is_contiguous_0;
    pub const ggml_is_contiguous_1 = __root.ggml_is_contiguous_1;
    pub const ggml_is_contiguous_2 = __root.ggml_is_contiguous_2;
    pub const ggml_is_contiguously_allocated = __root.ggml_is_contiguously_allocated;
    pub const ggml_is_contiguous_channels = __root.ggml_is_contiguous_channels;
    pub const ggml_is_contiguous_rows = __root.ggml_is_contiguous_rows;
    pub const ggml_are_same_shape = __root.ggml_are_same_shape;
    pub const ggml_are_same_stride = __root.ggml_are_same_stride;
    pub const ggml_can_repeat = __root.ggml_can_repeat;
    pub const ggml_unravel_index = __root.ggml_unravel_index;
    pub const ggml_get_unary_op = __root.ggml_get_unary_op;
    pub const ggml_get_glu_op = __root.ggml_get_glu_op;
    pub const ggml_get_data = __root.ggml_get_data;
    pub const ggml_get_data_f32 = __root.ggml_get_data_f32;
    pub const ggml_get_name = __root.ggml_get_name;
    pub const ggml_set_name = __root.ggml_set_name;
    pub const ggml_format_name = __root.ggml_format_name;
    pub const ggml_set_input = __root.ggml_set_input;
    pub const ggml_set_output = __root.ggml_set_output;
    pub const ggml_set_param = __root.ggml_set_param;
    pub const ggml_set_loss = __root.ggml_set_loss;
    pub const ggml_mul_mat_set_prec = __root.ggml_mul_mat_set_prec;
    pub const ggml_soft_max_add_sinks = __root.ggml_soft_max_add_sinks;
    pub const ggml_flash_attn_ext_set_prec = __root.ggml_flash_attn_ext_set_prec;
    pub const ggml_flash_attn_ext_get_prec = __root.ggml_flash_attn_ext_get_prec;
    pub const ggml_flash_attn_ext_add_sinks = __root.ggml_flash_attn_ext_add_sinks;
    pub const ggml_set_zero = __root.ggml_set_zero;
    pub const ggml_backend_tensor_copy = __root.ggml_backend_tensor_copy;
    pub const ggml_backend_tensor_set = __root.ggml_backend_tensor_set;
    pub const ggml_backend_tensor_get = __root.ggml_backend_tensor_get;
    pub const ggml_backend_tensor_set_2d = __root.ggml_backend_tensor_set_2d;
    pub const ggml_backend_tensor_get_2d = __root.ggml_backend_tensor_get_2d;
    pub const ggml_backend_tensor_memset = __root.ggml_backend_tensor_memset;
    pub const ggml_backend_view_init = __root.ggml_backend_view_init;
    pub const ggml_set_i32 = __root.ggml_set_i32;
    pub const ggml_set_f32 = __root.ggml_set_f32;
    pub const ggml_get_i32_1d = __root.ggml_get_i32_1d;
    pub const ggml_set_i32_1d = __root.ggml_set_i32_1d;
    pub const ggml_get_i32_nd = __root.ggml_get_i32_nd;
    pub const ggml_set_i32_nd = __root.ggml_set_i32_nd;
    pub const ggml_get_f32_1d = __root.ggml_get_f32_1d;
    pub const ggml_set_f32_1d = __root.ggml_set_f32_1d;
    pub const ggml_get_f32_nd = __root.ggml_get_f32_nd;
    pub const ggml_set_f32_nd = __root.ggml_set_f32_nd;
    pub const llama_opt_param_filter_all = __root.llama_opt_param_filter_all;
    pub const nelements = __root.ggml_nelements;
    pub const nrows = __root.ggml_nrows;
    pub const nbytes = __root.ggml_nbytes;
    pub const pad = __root.ggml_nbytes_pad;
    pub const desc = __root.ggml_op_desc;
    pub const size = __root.ggml_element_size;
    pub const transposed = __root.ggml_is_transposed;
    pub const permuted = __root.ggml_is_permuted;
    pub const empty = __root.ggml_is_empty;
    pub const view = __root.ggml_is_view;
    pub const scalar = __root.ggml_is_scalar;
    pub const vector = __root.ggml_is_vector;
    pub const matrix = __root.ggml_is_matrix;
    pub const @"3d" = __root.ggml_is_3d;
    pub const dims = __root.ggml_n_dims;
    pub const contiguous = __root.ggml_is_contiguous;
    pub const @"0" = __root.ggml_is_contiguous_0;
    pub const @"1" = __root.ggml_is_contiguous_1;
    pub const @"2" = __root.ggml_is_contiguous_2;
    pub const allocated = __root.ggml_is_contiguously_allocated;
    pub const channels = __root.ggml_is_contiguous_channels;
    pub const rows = __root.ggml_is_contiguous_rows;
    pub const shape = __root.ggml_are_same_shape;
    pub const stride = __root.ggml_are_same_stride;
    pub const repeat = __root.ggml_can_repeat;
    pub const index = __root.ggml_unravel_index;
    pub const @"f32" = __root.ggml_get_data_f32;
    pub const input = __root.ggml_set_input;
    pub const output = __root.ggml_set_output;
    pub const param = __root.ggml_set_param;
    pub const loss = __root.ggml_set_loss;
    pub const prec = __root.ggml_mul_mat_set_prec;
    pub const sinks = __root.ggml_soft_max_add_sinks;
    pub const zero = __root.ggml_set_zero;
    pub const copy = __root.ggml_backend_tensor_copy;
    pub const set = __root.ggml_backend_tensor_set;
    pub const get = __root.ggml_backend_tensor_get;
    pub const @"2d" = __root.ggml_backend_tensor_set_2d;
    pub const memset = __root.ggml_backend_tensor_memset;
    pub const init = __root.ggml_backend_view_init;
    pub const @"i32" = __root.ggml_set_i32;
    pub const @"1d" = __root.ggml_get_i32_1d;
    pub const nd = __root.ggml_get_i32_nd;
    pub const all = __root.llama_opt_param_filter_all;
};
pub const GGML_TENSOR_SIZE: usize = @sizeOf(struct_ggml_tensor);
pub const ggml_abort_callback = ?*const fn (data: ?*anyopaque) callconv(.c) bool;
pub const ggml_guid = [16]u8;
pub const ggml_guid_t = [*c]ggml_guid;
pub extern fn ggml_guid_matches(guid_a: ggml_guid_t, guid_b: ggml_guid_t) bool;
pub extern fn ggml_version() [*c]const u8;
pub extern fn ggml_commit() [*c]const u8;
pub extern fn ggml_time_init() void;
pub extern fn ggml_time_ms() i64;
pub extern fn ggml_time_us() i64;
pub extern fn ggml_cycles() i64;
pub extern fn ggml_cycles_per_ms() i64;
pub extern fn ggml_fopen(fname: [*c]const u8, mode: [*c]const u8) ?*FILE;
pub extern fn ggml_print_object(obj: ?*const struct_ggml_object) void;
pub extern fn ggml_print_objects(ctx: ?*const struct_ggml_context) void;
pub extern fn ggml_nelements(tensor: [*c]const struct_ggml_tensor) i64;
pub extern fn ggml_nrows(tensor: [*c]const struct_ggml_tensor) i64;
pub extern fn ggml_nbytes(tensor: [*c]const struct_ggml_tensor) usize;
pub extern fn ggml_nbytes_pad(tensor: [*c]const struct_ggml_tensor) usize;
pub extern fn ggml_blck_size(@"type": enum_ggml_type) i64;
pub extern fn ggml_type_size(@"type": enum_ggml_type) usize;
pub extern fn ggml_row_size(@"type": enum_ggml_type, ne: i64) usize;
pub extern fn ggml_type_sizef(@"type": enum_ggml_type) f64;
pub extern fn ggml_type_name(@"type": enum_ggml_type) [*c]const u8;
pub extern fn ggml_op_name(op: enum_ggml_op) [*c]const u8;
pub extern fn ggml_op_symbol(op: enum_ggml_op) [*c]const u8;
pub extern fn ggml_unary_op_name(op: enum_ggml_unary_op) [*c]const u8;
pub extern fn ggml_glu_op_name(op: enum_ggml_glu_op) [*c]const u8;
pub extern fn ggml_op_desc(t: [*c]const struct_ggml_tensor) [*c]const u8;
pub extern fn ggml_element_size(tensor: [*c]const struct_ggml_tensor) usize;
pub extern fn ggml_is_quantized(@"type": enum_ggml_type) bool;
pub extern fn ggml_ftype_to_ggml_type(ftype: enum_ggml_ftype) enum_ggml_type;
pub extern fn ggml_is_transposed(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_permuted(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_empty(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_view(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_scalar(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_vector(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_matrix(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_3d(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_n_dims(tensor: [*c]const struct_ggml_tensor) c_int;
pub extern fn ggml_is_contiguous(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_contiguous_0(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_contiguous_1(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_contiguous_2(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_contiguously_allocated(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_contiguous_channels(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_is_contiguous_rows(tensor: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_are_same_shape(t0: [*c]const struct_ggml_tensor, t1: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_are_same_stride(t0: [*c]const struct_ggml_tensor, t1: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_can_repeat(t0: [*c]const struct_ggml_tensor, t1: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_tensor_overhead() usize;
pub extern fn ggml_validate_row_data(@"type": enum_ggml_type, data: ?*const anyopaque, nbytes: usize) bool;
pub extern fn ggml_init(params: struct_ggml_init_params) ?*struct_ggml_context;
pub extern fn ggml_reset(ctx: ?*struct_ggml_context) void;
pub extern fn ggml_free(ctx: ?*struct_ggml_context) void;
pub extern fn ggml_used_mem(ctx: ?*const struct_ggml_context) usize;
pub extern fn ggml_get_no_alloc(ctx: ?*struct_ggml_context) bool;
pub extern fn ggml_set_no_alloc(ctx: ?*struct_ggml_context, no_alloc: bool) void;
pub extern fn ggml_get_mem_buffer(ctx: ?*const struct_ggml_context) ?*anyopaque;
pub extern fn ggml_get_mem_size(ctx: ?*const struct_ggml_context) usize;
pub extern fn ggml_get_max_tensor_size(ctx: ?*const struct_ggml_context) usize;
pub extern fn ggml_new_tensor(ctx: ?*struct_ggml_context, @"type": enum_ggml_type, n_dims: c_int, ne: [*c]const i64) [*c]struct_ggml_tensor;
pub extern fn ggml_new_tensor_1d(ctx: ?*struct_ggml_context, @"type": enum_ggml_type, ne0: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_new_tensor_2d(ctx: ?*struct_ggml_context, @"type": enum_ggml_type, ne0: i64, ne1: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_new_tensor_3d(ctx: ?*struct_ggml_context, @"type": enum_ggml_type, ne0: i64, ne1: i64, ne2: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_new_tensor_4d(ctx: ?*struct_ggml_context, @"type": enum_ggml_type, ne0: i64, ne1: i64, ne2: i64, ne3: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_new_buffer(ctx: ?*struct_ggml_context, nbytes: usize) ?*anyopaque;
pub extern fn ggml_dup_tensor(ctx: ?*struct_ggml_context, src: [*c]const struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_view_tensor(ctx: ?*struct_ggml_context, src: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_get_first_tensor(ctx: ?*const struct_ggml_context) [*c]struct_ggml_tensor;
pub extern fn ggml_get_next_tensor(ctx: ?*const struct_ggml_context, tensor: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_get_tensor(ctx: ?*struct_ggml_context, name: [*c]const u8) [*c]struct_ggml_tensor;
pub extern fn ggml_unravel_index(tensor: [*c]const struct_ggml_tensor, i: i64, @"i0": [*c]i64, @"i1": [*c]i64, @"i2": [*c]i64, @"i3": [*c]i64) void;
pub extern fn ggml_get_unary_op(tensor: [*c]const struct_ggml_tensor) enum_ggml_unary_op;
pub extern fn ggml_get_glu_op(tensor: [*c]const struct_ggml_tensor) enum_ggml_glu_op;
pub extern fn ggml_get_data(tensor: [*c]const struct_ggml_tensor) ?*anyopaque;
pub extern fn ggml_get_data_f32(tensor: [*c]const struct_ggml_tensor) [*c]f32;
pub extern fn ggml_get_name(tensor: [*c]const struct_ggml_tensor) [*c]const u8;
pub extern fn ggml_set_name(tensor: [*c]struct_ggml_tensor, name: [*c]const u8) [*c]struct_ggml_tensor;
pub extern fn ggml_format_name(tensor: [*c]struct_ggml_tensor, fmt: [*c]const u8, ...) [*c]struct_ggml_tensor;
pub extern fn ggml_set_input(tensor: [*c]struct_ggml_tensor) void;
pub extern fn ggml_set_output(tensor: [*c]struct_ggml_tensor) void;
pub extern fn ggml_set_param(tensor: [*c]struct_ggml_tensor) void;
pub extern fn ggml_set_loss(tensor: [*c]struct_ggml_tensor) void;
pub extern fn ggml_dup(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_dup_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_add(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_add_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_add_cast(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, @"type": enum_ggml_type) [*c]struct_ggml_tensor;
pub extern fn ggml_add_id(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, ids: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_add1(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_add1_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_acc(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, nb1: usize, nb2: usize, nb3: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_acc_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, nb1: usize, nb2: usize, nb3: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_sub(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sub_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_mul(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_mul_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_div(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_div_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sqr(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sqr_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sqrt(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sqrt_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_log(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_log_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_expm1(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_expm1_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_softplus(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_softplus_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sin(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sin_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_cos(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_cos_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sum(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sum_rows(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_cumsum(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_mean(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_argmax(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_count_equal(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_repeat(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_repeat_4d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64, ne3: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_repeat_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_concat(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, dim: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_abs(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_abs_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sgn(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sgn_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_neg(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_neg_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_step(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_step_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_tanh(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_tanh_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_elu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_elu_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_relu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_leaky_relu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, negative_slope: f32, inplace: bool) [*c]struct_ggml_tensor;
pub extern fn ggml_relu_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sigmoid(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_sigmoid_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gelu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gelu_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gelu_erf(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gelu_erf_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gelu_quick(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gelu_quick_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_silu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_silu_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_silu_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_hardswish(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_hardsigmoid(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_exp(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_exp_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_floor(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_floor_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_ceil(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_ceil_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_round(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_round_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_trunc(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_trunc_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_xielu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, alpha_n: f32, alpha_p: f32, beta: f32, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_glu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, op: enum_ggml_glu_op, swapped: bool) [*c]struct_ggml_tensor;
pub extern fn ggml_reglu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_reglu_swapped(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_swapped(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_swiglu(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_swiglu_swapped(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_erf(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_erf_swapped(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_quick(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_quick_swapped(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_glu_split(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, op: enum_ggml_glu_op) [*c]struct_ggml_tensor;
pub extern fn ggml_reglu_split(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_split(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_swiglu_split(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_erf_split(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_geglu_quick_split(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_swiglu_oai(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, alpha: f32, limit: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_norm(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_norm_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rms_norm(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rms_norm_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_group_norm(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, n_groups: c_int, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_group_norm_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, n_groups: c_int, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_l2_norm(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_l2_norm_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rms_norm_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, eps: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_mul_mat(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_mul_mat_set_prec(a: [*c]struct_ggml_tensor, prec: enum_ggml_prec) void;
pub extern fn ggml_mul_mat_id(ctx: ?*struct_ggml_context, as: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, ids: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_out_prod(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_scale(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, s: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_scale_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, s: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_scale_bias(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, s: f32, b: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_scale_bias_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, s: f32, b: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_set(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, nb1: usize, nb2: usize, nb3: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_set_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, nb1: usize, nb2: usize, nb3: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_set_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_set_1d_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_set_2d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, nb1: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_set_2d_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, nb1: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_cpy(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_cast(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, @"type": enum_ggml_type) [*c]struct_ggml_tensor;
pub extern fn ggml_cont(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_cont_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_cont_2d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_cont_3d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_cont_4d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64, ne3: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_reshape(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_reshape_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_reshape_2d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_reshape_3d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_reshape_4d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64, ne3: i64) [*c]struct_ggml_tensor;
pub extern fn ggml_view_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_view_2d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, nb1: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_view_3d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64, nb1: usize, nb2: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_view_4d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64, ne3: i64, nb1: usize, nb2: usize, nb3: usize, offset: usize) [*c]struct_ggml_tensor;
pub extern fn ggml_permute(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, axis0: c_int, axis1: c_int, axis2: c_int, axis3: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_transpose(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_get_rows(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_get_rows_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_set_rows(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_diag(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_diag_mask_inf(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, n_past: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_diag_mask_inf_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, n_past: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_diag_mask_zero(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, n_past: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_diag_mask_zero_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, n_past: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_soft_max(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_soft_max_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_soft_max_ext(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, mask: [*c]struct_ggml_tensor, scale: f32, max_bias: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_soft_max_ext_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, mask: [*c]struct_ggml_tensor, scale: f32, max_bias: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_soft_max_add_sinks(a: [*c]struct_ggml_tensor, sinks: [*c]struct_ggml_tensor) void;
pub extern fn ggml_soft_max_ext_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, scale: f32, max_bias: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_soft_max_ext_back_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, scale: f32, max_bias: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_ext(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_multi(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, n_dims: c_int, sections: [*c]c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_ext_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_multi_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, n_dims: c_int, sections: [*c]c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_custom(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_custom_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_yarn_corr_dims(n_dims: c_int, n_ctx_orig: c_int, freq_base: f32, beta_fast: f32, beta_slow: f32, dims: [*c]f32) void;
pub extern fn ggml_rope_ext_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, n_dims: c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rope_multi_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, n_dims: c_int, sections: [*c]c_int, mode: c_int, n_ctx_orig: c_int, freq_base: f32, freq_scale: f32, ext_factor: f32, attn_factor: f32, beta_fast: f32, beta_slow: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_clamp(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, min: f32, max: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_im2col(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, s1: c_int, p0: c_int, p1: c_int, d0: c_int, d1: c_int, is_2D: bool, dst_type: enum_ggml_type) [*c]struct_ggml_tensor;
pub extern fn ggml_im2col_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, ne: [*c]i64, s0: c_int, s1: c_int, p0: c_int, p1: c_int, d0: c_int, d1: c_int, is_2D: bool) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, p0: c_int, d0: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_1d_ph(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s: c_int, d: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_1d_dw(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, p0: c_int, d0: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_1d_dw_ph(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, d0: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_transpose_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, p0: c_int, d0: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_2d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, s1: c_int, p0: c_int, p1: c_int, d0: c_int, d1: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_im2col_3d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, IC: i64, s0: c_int, s1: c_int, s2: c_int, p0: c_int, p1: c_int, p2: c_int, d0: c_int, d1: c_int, d2: c_int, dst_type: enum_ggml_type) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_3d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, IC: i64, s0: c_int, s1: c_int, s2: c_int, p0: c_int, p1: c_int, p2: c_int, d0: c_int, d1: c_int, d2: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_2d_sk_p0(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_2d_s1_ph(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_2d_dw(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, s1: c_int, p0: c_int, p1: c_int, d0: c_int, d1: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_2d_dw_direct(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, stride0: c_int, stride1: c_int, pad0: c_int, pad1: c_int, dilation0: c_int, dilation1: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_transpose_2d_p0(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, stride: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_2d_direct(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, s1: c_int, p0: c_int, p1: c_int, d0: c_int, d1: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_conv_3d_direct(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, s0: c_int, s1: c_int, s2: c_int, p0: c_int, p1: c_int, p2: c_int, d0: c_int, d1: c_int, d2: c_int, n_channels: c_int, n_batch: c_int, n_channels_out: c_int) [*c]struct_ggml_tensor;
pub const GGML_OP_POOL_MAX: c_int = 0;
pub const GGML_OP_POOL_AVG: c_int = 1;
pub const GGML_OP_POOL_COUNT: c_int = 2;
pub const enum_ggml_op_pool = c_uint;
pub extern fn ggml_pool_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, op: enum_ggml_op_pool, k0: c_int, s0: c_int, p0: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_pool_2d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, op: enum_ggml_op_pool, k0: c_int, k1: c_int, s0: c_int, s1: c_int, p0: f32, p1: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_pool_2d_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, af: [*c]struct_ggml_tensor, op: enum_ggml_op_pool, k0: c_int, k1: c_int, s0: c_int, s1: c_int, p0: f32, p1: f32) [*c]struct_ggml_tensor;
pub const GGML_SCALE_MODE_NEAREST: c_int = 0;
pub const GGML_SCALE_MODE_BILINEAR: c_int = 1;
pub const GGML_SCALE_MODE_BICUBIC: c_int = 2;
pub const GGML_SCALE_MODE_COUNT: c_int = 3;
pub const enum_ggml_scale_mode = c_uint;
pub const GGML_SCALE_FLAG_ALIGN_CORNERS: c_int = 256;
pub const GGML_SCALE_FLAG_ANTIALIAS: c_int = 512;
pub const enum_ggml_scale_flag = c_uint;
pub extern fn ggml_upscale(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, scale_factor: c_int, mode: enum_ggml_scale_mode) [*c]struct_ggml_tensor;
pub extern fn ggml_upscale_ext(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: c_int, ne1: c_int, ne2: c_int, ne3: c_int, mode: enum_ggml_scale_mode) [*c]struct_ggml_tensor;
pub extern fn ggml_interpolate(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, ne0: i64, ne1: i64, ne2: i64, ne3: i64, mode: u32) [*c]struct_ggml_tensor;
pub extern fn ggml_pad(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, p0: c_int, p1: c_int, p2: c_int, p3: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_pad_circular(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, p0: c_int, p1: c_int, p2: c_int, p3: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_pad_ext(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, lp0: c_int, rp0: c_int, lp1: c_int, rp1: c_int, lp2: c_int, rp2: c_int, lp3: c_int, rp3: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_pad_ext_circular(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, lp0: c_int, rp0: c_int, lp1: c_int, rp1: c_int, lp2: c_int, rp2: c_int, lp3: c_int, rp3: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_pad_reflect_1d(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, p0: c_int, p1: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_roll(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, shift0: c_int, shift1: c_int, shift2: c_int, shift3: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_tri(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, @"type": enum_ggml_tri_type) [*c]struct_ggml_tensor;
pub extern fn ggml_fill(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, c: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_fill_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, c: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_timestep_embedding(ctx: ?*struct_ggml_context, timesteps: [*c]struct_ggml_tensor, dim: c_int, max_period: c_int) [*c]struct_ggml_tensor;
pub const GGML_SORT_ORDER_ASC: c_int = 0;
pub const GGML_SORT_ORDER_DESC: c_int = 1;
pub const enum_ggml_sort_order = c_uint;
pub extern fn ggml_argsort(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, order: enum_ggml_sort_order) [*c]struct_ggml_tensor;
pub extern fn ggml_argsort_top_k(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, k: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_top_k(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, k: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_arange(ctx: ?*struct_ggml_context, start: f32, stop: f32, step: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_flash_attn_ext(ctx: ?*struct_ggml_context, q: [*c]struct_ggml_tensor, k: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, mask: [*c]struct_ggml_tensor, scale: f32, max_bias: f32, logit_softcap: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_flash_attn_ext_set_prec(a: [*c]struct_ggml_tensor, prec: enum_ggml_prec) void;
pub extern fn ggml_flash_attn_ext_get_prec(a: [*c]const struct_ggml_tensor) enum_ggml_prec;
pub extern fn ggml_flash_attn_ext_add_sinks(a: [*c]struct_ggml_tensor, sinks: [*c]struct_ggml_tensor) void;
pub extern fn ggml_flash_attn_back(ctx: ?*struct_ggml_context, q: [*c]struct_ggml_tensor, k: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, d: [*c]struct_ggml_tensor, masked: bool) [*c]struct_ggml_tensor;
pub extern fn ggml_ssm_conv(ctx: ?*struct_ggml_context, sx: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_ssm_scan(ctx: ?*struct_ggml_context, s: [*c]struct_ggml_tensor, x: [*c]struct_ggml_tensor, dt: [*c]struct_ggml_tensor, A: [*c]struct_ggml_tensor, B: [*c]struct_ggml_tensor, C: [*c]struct_ggml_tensor, ids: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_win_part(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, w: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_win_unpart(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, w0: c_int, h0: c_int, w: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_unary(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, op: enum_ggml_unary_op) [*c]struct_ggml_tensor;
pub extern fn ggml_unary_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, op: enum_ggml_unary_op) [*c]struct_ggml_tensor;
pub extern fn ggml_get_rel_pos(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, qh: c_int, kh: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_add_rel_pos(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, pw: [*c]struct_ggml_tensor, ph: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_add_rel_pos_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, pw: [*c]struct_ggml_tensor, ph: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_rwkv_wkv6(ctx: ?*struct_ggml_context, k: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, r: [*c]struct_ggml_tensor, tf: [*c]struct_ggml_tensor, td: [*c]struct_ggml_tensor, state: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_gated_linear_attn(ctx: ?*struct_ggml_context, k: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, q: [*c]struct_ggml_tensor, g: [*c]struct_ggml_tensor, state: [*c]struct_ggml_tensor, scale: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_rwkv_wkv7(ctx: ?*struct_ggml_context, r: [*c]struct_ggml_tensor, w: [*c]struct_ggml_tensor, k: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, state: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_solve_tri(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, left: bool, lower: bool, uni: bool) [*c]struct_ggml_tensor;
pub extern fn ggml_gated_delta_net(ctx: ?*struct_ggml_context, q: [*c]struct_ggml_tensor, k: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, g: [*c]struct_ggml_tensor, beta: [*c]struct_ggml_tensor, state: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub const ggml_custom1_op_t = ?*const fn (dst: [*c]struct_ggml_tensor, a: [*c]const struct_ggml_tensor, ith: c_int, nth: c_int, userdata: ?*anyopaque) callconv(.c) void;
pub const ggml_custom2_op_t = ?*const fn (dst: [*c]struct_ggml_tensor, a: [*c]const struct_ggml_tensor, b: [*c]const struct_ggml_tensor, ith: c_int, nth: c_int, userdata: ?*anyopaque) callconv(.c) void;
pub const ggml_custom3_op_t = ?*const fn (dst: [*c]struct_ggml_tensor, a: [*c]const struct_ggml_tensor, b: [*c]const struct_ggml_tensor, c: [*c]const struct_ggml_tensor, ith: c_int, nth: c_int, userdata: ?*anyopaque) callconv(.c) void;
pub extern fn ggml_map_custom1(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, fun: ggml_custom1_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_map_custom1_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, fun: ggml_custom1_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_map_custom2(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, fun: ggml_custom2_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_map_custom2_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, fun: ggml_custom2_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_map_custom3(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, fun: ggml_custom3_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_map_custom3_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor, fun: ggml_custom3_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub const ggml_custom_op_t = ?*const fn (dst: [*c]struct_ggml_tensor, ith: c_int, nth: c_int, userdata: ?*anyopaque) callconv(.c) void;
pub extern fn ggml_custom_4d(ctx: ?*struct_ggml_context, @"type": enum_ggml_type, ne0: i64, ne1: i64, ne2: i64, ne3: i64, args: [*c][*c]struct_ggml_tensor, n_args: c_int, fun: ggml_custom_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_custom_inplace(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, args: [*c][*c]struct_ggml_tensor, n_args: c_int, fun: ggml_custom_op_t, n_tasks: c_int, userdata: ?*anyopaque) [*c]struct_ggml_tensor;
pub extern fn ggml_cross_entropy_loss(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_cross_entropy_loss_back(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, b: [*c]struct_ggml_tensor, c: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_step_adamw(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, grad: [*c]struct_ggml_tensor, m: [*c]struct_ggml_tensor, v: [*c]struct_ggml_tensor, adamw_params: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_step_sgd(ctx: ?*struct_ggml_context, a: [*c]struct_ggml_tensor, grad: [*c]struct_ggml_tensor, sgd_params: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_build_forward_select(cgraph: ?*struct_ggml_cgraph, tensors: [*c][*c]struct_ggml_tensor, n_tensors: c_int, idx: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_build_forward_expand(cgraph: ?*struct_ggml_cgraph, tensor: [*c]struct_ggml_tensor) void;
pub extern fn ggml_build_backward_expand(ctx: ?*struct_ggml_context, cgraph: ?*struct_ggml_cgraph, grad_accs: [*c][*c]struct_ggml_tensor) void;
pub extern fn ggml_new_graph(ctx: ?*struct_ggml_context) ?*struct_ggml_cgraph;
pub extern fn ggml_new_graph_custom(ctx: ?*struct_ggml_context, size: usize, grads: bool) ?*struct_ggml_cgraph;
pub extern fn ggml_graph_dup(ctx: ?*struct_ggml_context, cgraph: ?*struct_ggml_cgraph, force_grads: bool) ?*struct_ggml_cgraph;
pub extern fn ggml_graph_cpy(src: ?*struct_ggml_cgraph, dst: ?*struct_ggml_cgraph) void;
pub extern fn ggml_graph_reset(cgraph: ?*struct_ggml_cgraph) void;
pub extern fn ggml_graph_clear(cgraph: ?*struct_ggml_cgraph) void;
pub extern fn ggml_graph_size(cgraph: ?*struct_ggml_cgraph) c_int;
pub extern fn ggml_graph_node(cgraph: ?*struct_ggml_cgraph, i: c_int) [*c]struct_ggml_tensor;
pub extern fn ggml_graph_nodes(cgraph: ?*struct_ggml_cgraph) [*c][*c]struct_ggml_tensor;
pub extern fn ggml_graph_n_nodes(cgraph: ?*struct_ggml_cgraph) c_int;
pub extern fn ggml_graph_add_node(cgraph: ?*struct_ggml_cgraph, tensor: [*c]struct_ggml_tensor) void;
pub extern fn ggml_graph_overhead() usize;
pub extern fn ggml_graph_overhead_custom(size: usize, grads: bool) usize;
pub extern fn ggml_graph_get_tensor(cgraph: ?*const struct_ggml_cgraph, name: [*c]const u8) [*c]struct_ggml_tensor;
pub extern fn ggml_graph_get_grad(cgraph: ?*const struct_ggml_cgraph, node: [*c]const struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_graph_get_grad_acc(cgraph: ?*const struct_ggml_cgraph, node: [*c]const struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_graph_print(cgraph: ?*const struct_ggml_cgraph) void;
pub extern fn ggml_graph_dump_dot(gb: ?*const struct_ggml_cgraph, cgraph: ?*const struct_ggml_cgraph, filename: [*c]const u8) void;
pub const ggml_log_callback = ?*const fn (level: enum_ggml_log_level, text: [*c]const u8, user_data: ?*anyopaque) callconv(.c) void;
pub extern fn ggml_log_get(log_callback: [*c]ggml_log_callback, user_data: [*c]?*anyopaque) void;
pub extern fn ggml_log_set(log_callback: ggml_log_callback, user_data: ?*anyopaque) void;
pub extern fn ggml_set_zero(tensor: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_quantize_init(@"type": enum_ggml_type) void;
pub extern fn ggml_quantize_free() void;
pub extern fn ggml_quantize_requires_imatrix(@"type": enum_ggml_type) bool;
pub extern fn ggml_quantize_chunk(@"type": enum_ggml_type, src: [*c]const f32, dst: ?*anyopaque, start: i64, nrows: i64, n_per_row: i64, imatrix: [*c]const f32) usize;
pub const ggml_to_float_t = ?*const fn (noalias x: ?*const anyopaque, noalias y: [*c]f32, k: i64) callconv(.c) void;
pub const ggml_from_float_t = ?*const fn (noalias x: [*c]const f32, noalias y: ?*anyopaque, k: i64) callconv(.c) void;
pub const struct_ggml_type_traits = extern struct {
    type_name: [*c]const u8 = null,
    blck_size: i64 = 0,
    blck_size_interleave: i64 = 0,
    type_size: usize = 0,
    is_quantized: bool = false,
    to_float: ggml_to_float_t = null,
    from_float_ref: ggml_from_float_t = null,
};
pub extern fn ggml_get_type_traits(@"type": enum_ggml_type) [*c]const struct_ggml_type_traits;
pub const GGML_SCHED_PRIO_LOW: c_int = -1;
pub const GGML_SCHED_PRIO_NORMAL: c_int = 0;
pub const GGML_SCHED_PRIO_MEDIUM: c_int = 1;
pub const GGML_SCHED_PRIO_HIGH: c_int = 2;
pub const GGML_SCHED_PRIO_REALTIME: c_int = 3;
pub const enum_ggml_sched_priority = c_int;
pub const struct_ggml_threadpool_params = extern struct {
    cpumask: [512]bool = @import("std").mem.zeroes([512]bool),
    n_threads: c_int = 0,
    prio: enum_ggml_sched_priority = @import("std").mem.zeroes(enum_ggml_sched_priority),
    poll: u32 = 0,
    strict_cpu: bool = false,
    paused: bool = false,
    pub const ggml_threadpool_params_init = __root.ggml_threadpool_params_init;
    pub const ggml_threadpool_params_match = __root.ggml_threadpool_params_match;
    pub const ggml_threadpool_new = __root.ggml_threadpool_new;
    pub const init = __root.ggml_threadpool_params_init;
    pub const match = __root.ggml_threadpool_params_match;
    pub const new = __root.ggml_threadpool_new;
};
pub const struct_ggml_threadpool = opaque {
    pub const ggml_threadpool_free = __root.ggml_threadpool_free;
    pub const ggml_threadpool_get_n_threads = __root.ggml_threadpool_get_n_threads;
    pub const ggml_threadpool_pause = __root.ggml_threadpool_pause;
    pub const ggml_threadpool_resume = __root.ggml_threadpool_resume;
    pub const free = __root.ggml_threadpool_free;
    pub const get_n_threads = __root.ggml_threadpool_get_n_threads;
    pub const pause = __root.ggml_threadpool_pause;
    pub const @"resume" = __root.ggml_threadpool_resume;
};
pub const ggml_threadpool_t = ?*struct_ggml_threadpool;
pub extern fn ggml_threadpool_params_default(n_threads: c_int) struct_ggml_threadpool_params;
pub extern fn ggml_threadpool_params_init(p: [*c]struct_ggml_threadpool_params, n_threads: c_int) void;
pub extern fn ggml_threadpool_params_match(p0: [*c]const struct_ggml_threadpool_params, p1: [*c]const struct_ggml_threadpool_params) bool;
pub const struct_ggml_backend_buffer_type = opaque {
    pub const ggml_gallocr_new = __root.ggml_gallocr_new;
    pub const ggml_backend_buft_name = __root.ggml_backend_buft_name;
    pub const ggml_backend_buft_alloc_buffer = __root.ggml_backend_buft_alloc_buffer;
    pub const ggml_backend_buft_get_alignment = __root.ggml_backend_buft_get_alignment;
    pub const ggml_backend_buft_get_max_size = __root.ggml_backend_buft_get_max_size;
    pub const ggml_backend_buft_get_alloc_size = __root.ggml_backend_buft_get_alloc_size;
    pub const ggml_backend_buft_is_host = __root.ggml_backend_buft_is_host;
    pub const ggml_backend_buft_get_device = __root.ggml_backend_buft_get_device;
    pub const new = __root.ggml_gallocr_new;
    pub const name = __root.ggml_backend_buft_name;
    pub const buffer = __root.ggml_backend_buft_alloc_buffer;
    pub const alignment = __root.ggml_backend_buft_get_alignment;
    pub const size = __root.ggml_backend_buft_get_max_size;
    pub const host = __root.ggml_backend_buft_is_host;
    pub const device = __root.ggml_backend_buft_get_device;
};
pub const ggml_backend_buffer_type_t = ?*struct_ggml_backend_buffer_type;
pub const ggml_backend_buffer_t = ?*struct_ggml_backend_buffer_3;
pub const struct_ggml_backend = opaque {
    pub const ggml_backend_guid = __root.ggml_backend_guid;
    pub const ggml_backend_name = __root.ggml_backend_name;
    pub const ggml_backend_free = __root.ggml_backend_free;
    pub const ggml_backend_get_default_buffer_type = __root.ggml_backend_get_default_buffer_type;
    pub const ggml_backend_alloc_buffer = __root.ggml_backend_alloc_buffer;
    pub const ggml_backend_get_alignment = __root.ggml_backend_get_alignment;
    pub const ggml_backend_get_max_size = __root.ggml_backend_get_max_size;
    pub const ggml_backend_tensor_set_async = __root.ggml_backend_tensor_set_async;
    pub const ggml_backend_tensor_get_async = __root.ggml_backend_tensor_get_async;
    pub const ggml_backend_tensor_set_2d_async = __root.ggml_backend_tensor_set_2d_async;
    pub const ggml_backend_tensor_get_2d_async = __root.ggml_backend_tensor_get_2d_async;
    pub const ggml_backend_synchronize = __root.ggml_backend_synchronize;
    pub const ggml_backend_graph_plan_create = __root.ggml_backend_graph_plan_create;
    pub const ggml_backend_graph_plan_free = __root.ggml_backend_graph_plan_free;
    pub const ggml_backend_graph_plan_compute = __root.ggml_backend_graph_plan_compute;
    pub const ggml_backend_graph_compute = __root.ggml_backend_graph_compute;
    pub const ggml_backend_graph_compute_async = __root.ggml_backend_graph_compute_async;
    pub const ggml_backend_supports_op = __root.ggml_backend_supports_op;
    pub const ggml_backend_supports_buft = __root.ggml_backend_supports_buft;
    pub const ggml_backend_offload_op = __root.ggml_backend_offload_op;
    pub const ggml_backend_tensor_copy_async = __root.ggml_backend_tensor_copy_async;
    pub const ggml_backend_get_device = __root.ggml_backend_get_device;
    pub const ggml_backend_event_wait = __root.ggml_backend_event_wait;
    pub const ggml_backend_graph_copy = __root.ggml_backend_graph_copy;
    pub const ggml_backend_compare_graph_backend = __root.ggml_backend_compare_graph_backend;
    pub const ggml_backend_is_cpu = __root.ggml_backend_is_cpu;
    pub const ggml_backend_cpu_set_n_threads = __root.ggml_backend_cpu_set_n_threads;
    pub const ggml_backend_cpu_set_threadpool = __root.ggml_backend_cpu_set_threadpool;
    pub const ggml_backend_cpu_set_abort_callback = __root.ggml_backend_cpu_set_abort_callback;
    pub const ggml_backend_cpu_set_use_ref = __root.ggml_backend_cpu_set_use_ref;
    pub const guid = __root.ggml_backend_guid;
    pub const name = __root.ggml_backend_name;
    pub const free = __root.ggml_backend_free;
    pub const get_default_buffer_type = __root.ggml_backend_get_default_buffer_type;
    pub const alloc_buffer = __root.ggml_backend_alloc_buffer;
    pub const get_alignment = __root.ggml_backend_get_alignment;
    pub const get_max_size = __root.ggml_backend_get_max_size;
    pub const tensor_set_async = __root.ggml_backend_tensor_set_async;
    pub const tensor_get_async = __root.ggml_backend_tensor_get_async;
    pub const tensor_set_2d_async = __root.ggml_backend_tensor_set_2d_async;
    pub const tensor_get_2d_async = __root.ggml_backend_tensor_get_2d_async;
    pub const synchronize = __root.ggml_backend_synchronize;
    pub const graph_plan_create = __root.ggml_backend_graph_plan_create;
    pub const graph_plan_free = __root.ggml_backend_graph_plan_free;
    pub const graph_plan_compute = __root.ggml_backend_graph_plan_compute;
    pub const graph_compute = __root.ggml_backend_graph_compute;
    pub const graph_compute_async = __root.ggml_backend_graph_compute_async;
    pub const supports_op = __root.ggml_backend_supports_op;
    pub const supports_buft = __root.ggml_backend_supports_buft;
    pub const offload_op = __root.ggml_backend_offload_op;
    pub const tensor_copy_async = __root.ggml_backend_tensor_copy_async;
    pub const get_device = __root.ggml_backend_get_device;
    pub const event_wait = __root.ggml_backend_event_wait;
    pub const graph_copy = __root.ggml_backend_graph_copy;
    pub const compare_graph_backend = __root.ggml_backend_compare_graph_backend;
    pub const is_cpu = __root.ggml_backend_is_cpu;
    pub const cpu_set_n_threads = __root.ggml_backend_cpu_set_n_threads;
    pub const cpu_set_threadpool = __root.ggml_backend_cpu_set_threadpool;
    pub const cpu_set_abort_callback = __root.ggml_backend_cpu_set_abort_callback;
    pub const cpu_set_use_ref = __root.ggml_backend_cpu_set_use_ref;
};
pub const ggml_backend_t = ?*struct_ggml_backend;
pub const struct_ggml_tallocr = extern struct {
    buffer: ggml_backend_buffer_t = null,
    base: ?*anyopaque = null,
    alignment: usize = 0,
    offset: usize = 0,
    pub const ggml_tallocr_alloc = __root.ggml_tallocr_alloc;
    pub const alloc = __root.ggml_tallocr_alloc;
};
pub extern fn ggml_tallocr_new(buffer: ggml_backend_buffer_t) struct_ggml_tallocr;
pub extern fn ggml_tallocr_alloc(talloc: [*c]struct_ggml_tallocr, tensor: [*c]struct_ggml_tensor) enum_ggml_status;
pub const struct_ggml_gallocr = opaque {
    pub const ggml_gallocr_free = __root.ggml_gallocr_free;
    pub const ggml_gallocr_reserve = __root.ggml_gallocr_reserve;
    pub const ggml_gallocr_reserve_n_size = __root.ggml_gallocr_reserve_n_size;
    pub const ggml_gallocr_reserve_n = __root.ggml_gallocr_reserve_n;
    pub const ggml_gallocr_alloc_graph = __root.ggml_gallocr_alloc_graph;
    pub const ggml_gallocr_get_buffer_size = __root.ggml_gallocr_get_buffer_size;
    pub const free = __root.ggml_gallocr_free;
    pub const reserve = __root.ggml_gallocr_reserve;
    pub const reserve_n_size = __root.ggml_gallocr_reserve_n_size;
    pub const reserve_n = __root.ggml_gallocr_reserve_n;
    pub const alloc_graph = __root.ggml_gallocr_alloc_graph;
    pub const get_buffer_size = __root.ggml_gallocr_get_buffer_size;
};
pub const ggml_gallocr_t = ?*struct_ggml_gallocr;
pub extern fn ggml_gallocr_new(buft: ggml_backend_buffer_type_t) ggml_gallocr_t;
pub extern fn ggml_gallocr_new_n(bufts: [*c]ggml_backend_buffer_type_t, n_bufs: c_int) ggml_gallocr_t;
pub extern fn ggml_gallocr_free(galloc: ggml_gallocr_t) void;
pub extern fn ggml_gallocr_reserve(galloc: ggml_gallocr_t, graph: ?*struct_ggml_cgraph) bool;
pub extern fn ggml_gallocr_reserve_n_size(galloc: ggml_gallocr_t, graph: ?*struct_ggml_cgraph, node_buffer_ids: [*c]const c_int, leaf_buffer_ids: [*c]const c_int, sizes: [*c]usize) void;
pub extern fn ggml_gallocr_reserve_n(galloc: ggml_gallocr_t, graph: ?*struct_ggml_cgraph, node_buffer_ids: [*c]const c_int, leaf_buffer_ids: [*c]const c_int) bool;
pub extern fn ggml_gallocr_alloc_graph(galloc: ggml_gallocr_t, graph: ?*struct_ggml_cgraph) bool;
pub extern fn ggml_gallocr_get_buffer_size(galloc: ggml_gallocr_t, buffer_id: c_int) usize;
pub extern fn ggml_backend_alloc_ctx_tensors_from_buft_size(ctx: ?*struct_ggml_context, buft: ggml_backend_buffer_type_t) usize;
pub extern fn ggml_backend_alloc_ctx_tensors_from_buft(ctx: ?*struct_ggml_context, buft: ggml_backend_buffer_type_t) ?*struct_ggml_backend_buffer_3;
pub extern fn ggml_backend_alloc_ctx_tensors(ctx: ?*struct_ggml_context, backend: ggml_backend_t) ?*struct_ggml_backend_buffer_3;
pub const struct_ggml_backend_event = opaque {
    pub const ggml_backend_event_free = __root.ggml_backend_event_free;
    pub const ggml_backend_event_record = __root.ggml_backend_event_record;
    pub const ggml_backend_event_synchronize = __root.ggml_backend_event_synchronize;
    pub const free = __root.ggml_backend_event_free;
    pub const record = __root.ggml_backend_event_record;
    pub const synchronize = __root.ggml_backend_event_synchronize;
};
pub const ggml_backend_event_t = ?*struct_ggml_backend_event;
pub const ggml_backend_graph_plan_t = ?*anyopaque;
pub const struct_ggml_backend_reg = opaque {
    pub const ggml_backend_reg_name = __root.ggml_backend_reg_name;
    pub const ggml_backend_reg_dev_count = __root.ggml_backend_reg_dev_count;
    pub const ggml_backend_reg_dev_get = __root.ggml_backend_reg_dev_get;
    pub const ggml_backend_reg_get_proc_address = __root.ggml_backend_reg_get_proc_address;
    pub const ggml_backend_register = __root.ggml_backend_register;
    pub const ggml_backend_unload = __root.ggml_backend_unload;
    pub const name = __root.ggml_backend_reg_name;
    pub const dev_count = __root.ggml_backend_reg_dev_count;
    pub const dev_get = __root.ggml_backend_reg_dev_get;
    pub const get_proc_address = __root.ggml_backend_reg_get_proc_address;
    pub const register = __root.ggml_backend_register;
    pub const unload = __root.ggml_backend_unload;
};
pub const ggml_backend_reg_t = ?*struct_ggml_backend_reg;
pub const struct_ggml_backend_device = opaque {
    pub const ggml_backend_event_new = __root.ggml_backend_event_new;
    pub const ggml_backend_dev_name = __root.ggml_backend_dev_name;
    pub const ggml_backend_dev_description = __root.ggml_backend_dev_description;
    pub const ggml_backend_dev_memory = __root.ggml_backend_dev_memory;
    pub const ggml_backend_dev_type = __root.ggml_backend_dev_type;
    pub const ggml_backend_dev_get_props = __root.ggml_backend_dev_get_props;
    pub const ggml_backend_dev_backend_reg = __root.ggml_backend_dev_backend_reg;
    pub const ggml_backend_dev_init = __root.ggml_backend_dev_init;
    pub const ggml_backend_dev_buffer_type = __root.ggml_backend_dev_buffer_type;
    pub const ggml_backend_dev_host_buffer_type = __root.ggml_backend_dev_host_buffer_type;
    pub const ggml_backend_dev_buffer_from_host_ptr = __root.ggml_backend_dev_buffer_from_host_ptr;
    pub const ggml_backend_dev_supports_op = __root.ggml_backend_dev_supports_op;
    pub const ggml_backend_dev_supports_buft = __root.ggml_backend_dev_supports_buft;
    pub const ggml_backend_dev_offload_op = __root.ggml_backend_dev_offload_op;
    pub const ggml_backend_device_register = __root.ggml_backend_device_register;
    pub const new = __root.ggml_backend_event_new;
    pub const name = __root.ggml_backend_dev_name;
    pub const description = __root.ggml_backend_dev_description;
    pub const memory = __root.ggml_backend_dev_memory;
    pub const @"type" = __root.ggml_backend_dev_type;
    pub const props = __root.ggml_backend_dev_get_props;
    pub const reg = __root.ggml_backend_dev_backend_reg;
    pub const init = __root.ggml_backend_dev_init;
    pub const ptr = __root.ggml_backend_dev_buffer_from_host_ptr;
    pub const op = __root.ggml_backend_dev_supports_op;
    pub const buft = __root.ggml_backend_dev_supports_buft;
    pub const register = __root.ggml_backend_device_register;
};
pub const ggml_backend_dev_t = ?*struct_ggml_backend_device;
pub extern fn ggml_backend_buft_name(buft: ggml_backend_buffer_type_t) [*c]const u8;
pub extern fn ggml_backend_buft_alloc_buffer(buft: ggml_backend_buffer_type_t, size: usize) ggml_backend_buffer_t;
pub extern fn ggml_backend_buft_get_alignment(buft: ggml_backend_buffer_type_t) usize;
pub extern fn ggml_backend_buft_get_max_size(buft: ggml_backend_buffer_type_t) usize;
pub extern fn ggml_backend_buft_get_alloc_size(buft: ggml_backend_buffer_type_t, tensor: [*c]const struct_ggml_tensor) usize;
pub extern fn ggml_backend_buft_is_host(buft: ggml_backend_buffer_type_t) bool;
pub extern fn ggml_backend_buft_get_device(buft: ggml_backend_buffer_type_t) ggml_backend_dev_t;
pub const GGML_BACKEND_BUFFER_USAGE_ANY: c_int = 0;
pub const GGML_BACKEND_BUFFER_USAGE_WEIGHTS: c_int = 1;
pub const GGML_BACKEND_BUFFER_USAGE_COMPUTE: c_int = 2;
pub const enum_ggml_backend_buffer_usage = c_uint;
pub extern fn ggml_backend_buffer_name(buffer: ggml_backend_buffer_t) [*c]const u8;
pub extern fn ggml_backend_buffer_free(buffer: ggml_backend_buffer_t) void;
pub extern fn ggml_backend_buffer_get_base(buffer: ggml_backend_buffer_t) ?*anyopaque;
pub extern fn ggml_backend_buffer_get_size(buffer: ggml_backend_buffer_t) usize;
pub extern fn ggml_backend_buffer_init_tensor(buffer: ggml_backend_buffer_t, tensor: [*c]struct_ggml_tensor) enum_ggml_status;
pub extern fn ggml_backend_buffer_get_alignment(buffer: ggml_backend_buffer_t) usize;
pub extern fn ggml_backend_buffer_get_max_size(buffer: ggml_backend_buffer_t) usize;
pub extern fn ggml_backend_buffer_get_alloc_size(buffer: ggml_backend_buffer_t, tensor: [*c]const struct_ggml_tensor) usize;
pub extern fn ggml_backend_buffer_clear(buffer: ggml_backend_buffer_t, value: u8) void;
pub extern fn ggml_backend_buffer_is_host(buffer: ggml_backend_buffer_t) bool;
pub extern fn ggml_backend_buffer_set_usage(buffer: ggml_backend_buffer_t, usage: enum_ggml_backend_buffer_usage) void;
pub extern fn ggml_backend_buffer_get_usage(buffer: ggml_backend_buffer_t) enum_ggml_backend_buffer_usage;
pub extern fn ggml_backend_buffer_get_type(buffer: ggml_backend_buffer_t) ggml_backend_buffer_type_t;
pub extern fn ggml_backend_buffer_reset(buffer: ggml_backend_buffer_t) void;
pub extern fn ggml_backend_tensor_copy(src: [*c]const struct_ggml_tensor, dst: [*c]struct_ggml_tensor) void;
pub extern fn ggml_backend_guid(backend: ggml_backend_t) ggml_guid_t;
pub extern fn ggml_backend_name(backend: ggml_backend_t) [*c]const u8;
pub extern fn ggml_backend_free(backend: ggml_backend_t) void;
pub extern fn ggml_backend_get_default_buffer_type(backend: ggml_backend_t) ggml_backend_buffer_type_t;
pub extern fn ggml_backend_alloc_buffer(backend: ggml_backend_t, size: usize) ggml_backend_buffer_t;
pub extern fn ggml_backend_get_alignment(backend: ggml_backend_t) usize;
pub extern fn ggml_backend_get_max_size(backend: ggml_backend_t) usize;
pub extern fn ggml_backend_tensor_set_async(backend: ggml_backend_t, tensor: [*c]struct_ggml_tensor, data: ?*const anyopaque, offset: usize, size: usize) void;
pub extern fn ggml_backend_tensor_get_async(backend: ggml_backend_t, tensor: [*c]const struct_ggml_tensor, data: ?*anyopaque, offset: usize, size: usize) void;
pub extern fn ggml_backend_tensor_set_2d_async(backend: ggml_backend_t, tensor: [*c]struct_ggml_tensor, data: ?*const anyopaque, offset: usize, size: usize, n_copies: usize, stride_tensor: usize, stride_data: usize) void;
pub extern fn ggml_backend_tensor_get_2d_async(backend: ggml_backend_t, tensor: [*c]const struct_ggml_tensor, data: ?*anyopaque, offset: usize, size: usize, n_copies: usize, stride_tensor: usize, stride_data: usize) void;
pub extern fn ggml_backend_tensor_set(tensor: [*c]struct_ggml_tensor, data: ?*const anyopaque, offset: usize, size: usize) void;
pub extern fn ggml_backend_tensor_get(tensor: [*c]const struct_ggml_tensor, data: ?*anyopaque, offset: usize, size: usize) void;
pub extern fn ggml_backend_tensor_set_2d(tensor: [*c]struct_ggml_tensor, data: ?*const anyopaque, offset: usize, size: usize, n_copies: usize, stride_tensor: usize, stride_data: usize) void;
pub extern fn ggml_backend_tensor_get_2d(tensor: [*c]const struct_ggml_tensor, data: ?*anyopaque, offset: usize, size: usize, n_copies: usize, stride_tensor: usize, stride_data: usize) void;
pub extern fn ggml_backend_tensor_memset(tensor: [*c]struct_ggml_tensor, value: u8, offset: usize, size: usize) void;
pub extern fn ggml_backend_synchronize(backend: ggml_backend_t) void;
pub extern fn ggml_backend_graph_plan_create(backend: ggml_backend_t, cgraph: ?*struct_ggml_cgraph) ggml_backend_graph_plan_t;
pub extern fn ggml_backend_graph_plan_free(backend: ggml_backend_t, plan: ggml_backend_graph_plan_t) void;
pub extern fn ggml_backend_graph_plan_compute(backend: ggml_backend_t, plan: ggml_backend_graph_plan_t) enum_ggml_status;
pub extern fn ggml_backend_graph_compute(backend: ggml_backend_t, cgraph: ?*struct_ggml_cgraph) enum_ggml_status;
pub extern fn ggml_backend_graph_compute_async(backend: ggml_backend_t, cgraph: ?*struct_ggml_cgraph) enum_ggml_status;
pub extern fn ggml_backend_supports_op(backend: ggml_backend_t, op: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_backend_supports_buft(backend: ggml_backend_t, buft: ggml_backend_buffer_type_t) bool;
pub extern fn ggml_backend_offload_op(backend: ggml_backend_t, op: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_backend_tensor_copy_async(backend_src: ggml_backend_t, backend_dst: ggml_backend_t, src: [*c]const struct_ggml_tensor, dst: [*c]struct_ggml_tensor) void;
pub extern fn ggml_backend_get_device(backend: ggml_backend_t) ggml_backend_dev_t;
pub extern fn ggml_backend_event_new(device: ggml_backend_dev_t) ggml_backend_event_t;
pub extern fn ggml_backend_event_free(event: ggml_backend_event_t) void;
pub extern fn ggml_backend_event_record(event: ggml_backend_event_t, backend: ggml_backend_t) void;
pub extern fn ggml_backend_event_synchronize(event: ggml_backend_event_t) void;
pub extern fn ggml_backend_event_wait(backend: ggml_backend_t, event: ggml_backend_event_t) void;
pub const GGML_BACKEND_DEVICE_TYPE_CPU: c_int = 0;
pub const GGML_BACKEND_DEVICE_TYPE_GPU: c_int = 1;
pub const GGML_BACKEND_DEVICE_TYPE_IGPU: c_int = 2;
pub const GGML_BACKEND_DEVICE_TYPE_ACCEL: c_int = 3;
pub const GGML_BACKEND_DEVICE_TYPE_META: c_int = 4;
pub const enum_ggml_backend_dev_type = c_uint;
pub const struct_ggml_backend_dev_caps = extern struct {
    async: bool = false,
    host_buffer: bool = false,
    buffer_from_host_ptr: bool = false,
    events: bool = false,
};
pub const struct_ggml_backend_dev_props = extern struct {
    name: [*c]const u8 = null,
    description: [*c]const u8 = null,
    memory_free: usize = 0,
    memory_total: usize = 0,
    type: enum_ggml_backend_dev_type = @import("std").mem.zeroes(enum_ggml_backend_dev_type),
    device_id: [*c]const u8 = null,
    caps: struct_ggml_backend_dev_caps = @import("std").mem.zeroes(struct_ggml_backend_dev_caps),
};
pub extern fn ggml_backend_dev_name(device: ggml_backend_dev_t) [*c]const u8;
pub extern fn ggml_backend_dev_description(device: ggml_backend_dev_t) [*c]const u8;
pub extern fn ggml_backend_dev_memory(device: ggml_backend_dev_t, free: [*c]usize, total: [*c]usize) void;
pub extern fn ggml_backend_dev_type(device: ggml_backend_dev_t) enum_ggml_backend_dev_type;
pub extern fn ggml_backend_dev_get_props(device: ggml_backend_dev_t, props: [*c]struct_ggml_backend_dev_props) void;
pub extern fn ggml_backend_dev_backend_reg(device: ggml_backend_dev_t) ggml_backend_reg_t;
pub extern fn ggml_backend_dev_init(device: ggml_backend_dev_t, params: [*c]const u8) ggml_backend_t;
pub extern fn ggml_backend_dev_buffer_type(device: ggml_backend_dev_t) ggml_backend_buffer_type_t;
pub extern fn ggml_backend_dev_host_buffer_type(device: ggml_backend_dev_t) ggml_backend_buffer_type_t;
pub extern fn ggml_backend_dev_buffer_from_host_ptr(device: ggml_backend_dev_t, ptr: ?*anyopaque, size: usize, max_tensor_size: usize) ggml_backend_buffer_t;
pub extern fn ggml_backend_dev_supports_op(device: ggml_backend_dev_t, op: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_backend_dev_supports_buft(device: ggml_backend_dev_t, buft: ggml_backend_buffer_type_t) bool;
pub extern fn ggml_backend_dev_offload_op(device: ggml_backend_dev_t, op: [*c]const struct_ggml_tensor) bool;
pub extern fn ggml_backend_reg_name(reg: ggml_backend_reg_t) [*c]const u8;
pub extern fn ggml_backend_reg_dev_count(reg: ggml_backend_reg_t) usize;
pub extern fn ggml_backend_reg_dev_get(reg: ggml_backend_reg_t, index: usize) ggml_backend_dev_t;
pub extern fn ggml_backend_reg_get_proc_address(reg: ggml_backend_reg_t, name: [*c]const u8) ?*anyopaque;
pub const ggml_backend_comm_init_t = ?*const fn (backends: [*c]ggml_backend_t, n_backends: usize) callconv(.c) ?*anyopaque;
pub const ggml_backend_comm_free_t = ?*const fn (comm_ctx: ?*anyopaque) callconv(.c) void;
pub const ggml_backend_comm_allreduce_tensor_t = ?*const fn (comm_ctx: ?*anyopaque, tensors: [*c][*c]struct_ggml_tensor) callconv(.c) bool;
pub const ggml_backend_split_buffer_type_t = ?*const fn (main_device: c_int, tensor_split: [*c]const f32) callconv(.c) ggml_backend_buffer_type_t;
pub const ggml_backend_set_n_threads_t = ?*const fn (backend: ggml_backend_t, n_threads: c_int) callconv(.c) void;
pub const ggml_backend_dev_get_extra_bufts_t = ?*const fn (device: ggml_backend_dev_t) callconv(.c) [*c]ggml_backend_buffer_type_t;
pub const ggml_backend_set_abort_callback_t = ?*const fn (backend: ggml_backend_t, abort_callback: ggml_abort_callback, abort_callback_data: ?*anyopaque) callconv(.c) void;
pub const struct_ggml_backend_feature = extern struct {
    name: [*c]const u8 = null,
    value: [*c]const u8 = null,
};
pub const ggml_backend_get_features_t = ?*const fn (reg: ggml_backend_reg_t) callconv(.c) [*c]struct_ggml_backend_feature;
pub extern fn ggml_backend_register(reg: ggml_backend_reg_t) void;
pub extern fn ggml_backend_device_register(device: ggml_backend_dev_t) void;
pub extern fn ggml_backend_reg_count() usize;
pub extern fn ggml_backend_reg_get(index: usize) ggml_backend_reg_t;
pub extern fn ggml_backend_reg_by_name(name: [*c]const u8) ggml_backend_reg_t;
pub extern fn ggml_backend_dev_count() usize;
pub extern fn ggml_backend_dev_get(index: usize) ggml_backend_dev_t;
pub extern fn ggml_backend_dev_by_name(name: [*c]const u8) ggml_backend_dev_t;
pub extern fn ggml_backend_dev_by_type(@"type": enum_ggml_backend_dev_type) ggml_backend_dev_t;
pub extern fn ggml_backend_init_by_name(name: [*c]const u8, params: [*c]const u8) ggml_backend_t;
pub extern fn ggml_backend_init_by_type(@"type": enum_ggml_backend_dev_type, params: [*c]const u8) ggml_backend_t;
pub extern fn ggml_backend_init_best() ggml_backend_t;
pub extern fn ggml_backend_load(path: [*c]const u8) ggml_backend_reg_t;
pub extern fn ggml_backend_unload(reg: ggml_backend_reg_t) void;
pub extern fn ggml_backend_load_all() void;
pub extern fn ggml_backend_load_all_from_path(dir_path: [*c]const u8) void;
pub const struct_ggml_backend_sched = opaque {
    pub const ggml_backend_sched_free = __root.ggml_backend_sched_free;
    pub const ggml_backend_sched_reserve_size = __root.ggml_backend_sched_reserve_size;
    pub const ggml_backend_sched_reserve = __root.ggml_backend_sched_reserve;
    pub const ggml_backend_sched_get_n_backends = __root.ggml_backend_sched_get_n_backends;
    pub const ggml_backend_sched_get_backend = __root.ggml_backend_sched_get_backend;
    pub const ggml_backend_sched_get_n_splits = __root.ggml_backend_sched_get_n_splits;
    pub const ggml_backend_sched_get_n_copies = __root.ggml_backend_sched_get_n_copies;
    pub const ggml_backend_sched_get_buffer_type = __root.ggml_backend_sched_get_buffer_type;
    pub const ggml_backend_sched_get_buffer_size = __root.ggml_backend_sched_get_buffer_size;
    pub const ggml_backend_sched_set_tensor_backend = __root.ggml_backend_sched_set_tensor_backend;
    pub const ggml_backend_sched_get_tensor_backend = __root.ggml_backend_sched_get_tensor_backend;
    pub const ggml_backend_sched_split_graph = __root.ggml_backend_sched_split_graph;
    pub const ggml_backend_sched_alloc_graph = __root.ggml_backend_sched_alloc_graph;
    pub const ggml_backend_sched_graph_compute = __root.ggml_backend_sched_graph_compute;
    pub const ggml_backend_sched_graph_compute_async = __root.ggml_backend_sched_graph_compute_async;
    pub const ggml_backend_sched_synchronize = __root.ggml_backend_sched_synchronize;
    pub const ggml_backend_sched_reset = __root.ggml_backend_sched_reset;
    pub const ggml_backend_sched_set_eval_callback = __root.ggml_backend_sched_set_eval_callback;
    pub const ggml_opt_default_params = __root.ggml_opt_default_params;
    pub const ggml_opt_fit = __root.ggml_opt_fit;
    pub const free = __root.ggml_backend_sched_free;
    pub const reserve_size = __root.ggml_backend_sched_reserve_size;
    pub const reserve = __root.ggml_backend_sched_reserve;
    pub const get_n_backends = __root.ggml_backend_sched_get_n_backends;
    pub const get_backend = __root.ggml_backend_sched_get_backend;
    pub const get_n_splits = __root.ggml_backend_sched_get_n_splits;
    pub const get_n_copies = __root.ggml_backend_sched_get_n_copies;
    pub const get_buffer_type = __root.ggml_backend_sched_get_buffer_type;
    pub const get_buffer_size = __root.ggml_backend_sched_get_buffer_size;
    pub const set_tensor_backend = __root.ggml_backend_sched_set_tensor_backend;
    pub const get_tensor_backend = __root.ggml_backend_sched_get_tensor_backend;
    pub const split_graph = __root.ggml_backend_sched_split_graph;
    pub const alloc_graph = __root.ggml_backend_sched_alloc_graph;
    pub const graph_compute = __root.ggml_backend_sched_graph_compute;
    pub const graph_compute_async = __root.ggml_backend_sched_graph_compute_async;
    pub const synchronize = __root.ggml_backend_sched_synchronize;
    pub const reset = __root.ggml_backend_sched_reset;
    pub const set_eval_callback = __root.ggml_backend_sched_set_eval_callback;
    pub const params = __root.ggml_opt_default_params;
    pub const fit = __root.ggml_opt_fit;
};
pub const ggml_backend_sched_t = ?*struct_ggml_backend_sched;
pub const ggml_backend_sched_eval_callback = ?*const fn (t: [*c]struct_ggml_tensor, ask: bool, user_data: ?*anyopaque) callconv(.c) bool;
pub extern fn ggml_backend_sched_new(backends: [*c]ggml_backend_t, bufts: [*c]ggml_backend_buffer_type_t, n_backends: c_int, graph_size: usize, parallel: bool, op_offload: bool) ggml_backend_sched_t;
pub extern fn ggml_backend_sched_free(sched: ggml_backend_sched_t) void;
pub extern fn ggml_backend_sched_reserve_size(sched: ggml_backend_sched_t, measure_graph: ?*struct_ggml_cgraph, sizes: [*c]usize) void;
pub extern fn ggml_backend_sched_reserve(sched: ggml_backend_sched_t, measure_graph: ?*struct_ggml_cgraph) bool;
pub extern fn ggml_backend_sched_get_n_backends(sched: ggml_backend_sched_t) c_int;
pub extern fn ggml_backend_sched_get_backend(sched: ggml_backend_sched_t, i: c_int) ggml_backend_t;
pub extern fn ggml_backend_sched_get_n_splits(sched: ggml_backend_sched_t) c_int;
pub extern fn ggml_backend_sched_get_n_copies(sched: ggml_backend_sched_t) c_int;
pub extern fn ggml_backend_sched_get_buffer_type(sched: ggml_backend_sched_t, backend: ggml_backend_t) ggml_backend_buffer_type_t;
pub extern fn ggml_backend_sched_get_buffer_size(sched: ggml_backend_sched_t, backend: ggml_backend_t) usize;
pub extern fn ggml_backend_sched_set_tensor_backend(sched: ggml_backend_sched_t, node: [*c]struct_ggml_tensor, backend: ggml_backend_t) void;
pub extern fn ggml_backend_sched_get_tensor_backend(sched: ggml_backend_sched_t, node: [*c]struct_ggml_tensor) ggml_backend_t;
pub extern fn ggml_backend_sched_split_graph(sched: ggml_backend_sched_t, graph: ?*struct_ggml_cgraph) void;
pub extern fn ggml_backend_sched_alloc_graph(sched: ggml_backend_sched_t, graph: ?*struct_ggml_cgraph) bool;
pub extern fn ggml_backend_sched_graph_compute(sched: ggml_backend_sched_t, graph: ?*struct_ggml_cgraph) enum_ggml_status;
pub extern fn ggml_backend_sched_graph_compute_async(sched: ggml_backend_sched_t, graph: ?*struct_ggml_cgraph) enum_ggml_status;
pub extern fn ggml_backend_sched_synchronize(sched: ggml_backend_sched_t) void;
pub extern fn ggml_backend_sched_reset(sched: ggml_backend_sched_t) void;
pub extern fn ggml_backend_sched_set_eval_callback(sched: ggml_backend_sched_t, callback: ggml_backend_sched_eval_callback, user_data: ?*anyopaque) void;
pub const GGML_BACKEND_SPLIT_AXIS_0: c_int = 0;
pub const GGML_BACKEND_SPLIT_AXIS_1: c_int = 1;
pub const GGML_BACKEND_SPLIT_AXIS_2: c_int = 2;
pub const GGML_BACKEND_SPLIT_AXIS_3: c_int = 3;
pub const GGML_BACKEND_SPLIT_AXIS_MIRRORED: c_int = 10;
pub const GGML_BACKEND_SPLIT_AXIS_PARTIAL: c_int = 11;
pub const GGML_BACKEND_SPLIT_AXIS_NONE: c_int = 98;
pub const GGML_BACKEND_SPLIT_AXIS_UNKNOWN: c_int = 99;
pub const enum_ggml_backend_meta_split_axis = c_uint;
pub extern fn ggml_backend_meta_split_axis_name(split_axis: enum_ggml_backend_meta_split_axis) [*c]const u8;
pub const struct_ggml_backend_meta_split_state = extern struct {
    axis: enum_ggml_backend_meta_split_axis = @import("std").mem.zeroes(enum_ggml_backend_meta_split_axis),
    ne: [256]i64 = @import("std").mem.zeroes([256]i64),
    n_segments: u32 = 0,
};
pub const ggml_backend_meta_get_split_state_t = ?*const fn (tensor: [*c]const struct_ggml_tensor, userdata: ?*anyopaque) callconv(.c) struct_ggml_backend_meta_split_state;
pub extern fn ggml_backend_meta_device(devs: [*c]ggml_backend_dev_t, n_devs: usize, get_split_state: ggml_backend_meta_get_split_state_t, get_split_state_ud: ?*anyopaque) ggml_backend_dev_t;
pub const struct_ggml_backend_graph_copy = extern struct {
    buffer: ggml_backend_buffer_t = null,
    ctx_allocated: ?*struct_ggml_context = null,
    ctx_unallocated: ?*struct_ggml_context = null,
    graph: ?*struct_ggml_cgraph = null,
    pub const ggml_backend_graph_copy_free = __root.ggml_backend_graph_copy_free;
    pub const free = __root.ggml_backend_graph_copy_free;
};
pub extern fn ggml_backend_graph_copy(backend: ggml_backend_t, graph: ?*struct_ggml_cgraph) struct_ggml_backend_graph_copy;
pub extern fn ggml_backend_graph_copy_free(copy: struct_ggml_backend_graph_copy) void;
pub const ggml_backend_eval_callback = ?*const fn (node_index: c_int, t1: [*c]struct_ggml_tensor, t2: [*c]struct_ggml_tensor, user_data: ?*anyopaque) callconv(.c) bool;
pub extern fn ggml_backend_compare_graph_backend(backend1: ggml_backend_t, backend2: ggml_backend_t, graph: ?*struct_ggml_cgraph, callback: ggml_backend_eval_callback, user_data: ?*anyopaque, test_nodes: [*c]const [*c]const struct_ggml_tensor, num_test_nodes: usize) bool;
pub extern fn ggml_backend_tensor_alloc(buffer: ggml_backend_buffer_t, tensor: [*c]struct_ggml_tensor, addr: ?*anyopaque) enum_ggml_status;
pub extern fn ggml_backend_view_init(tensor: [*c]struct_ggml_tensor) enum_ggml_status;
pub extern fn ggml_backend_cpu_buffer_from_ptr(ptr: ?*anyopaque, size: usize) ggml_backend_buffer_t;
pub extern fn ggml_backend_cpu_buffer_type() ggml_backend_buffer_type_t;
pub const struct_ggml_cplan = extern struct {
    work_size: usize = 0,
    work_data: [*c]u8 = null,
    n_threads: c_int = 0,
    threadpool: ?*struct_ggml_threadpool = null,
    abort_callback: ggml_abort_callback = null,
    abort_callback_data: ?*anyopaque = null,
    use_ref: bool = false,
};
pub const GGML_NUMA_STRATEGY_DISABLED: c_int = 0;
pub const GGML_NUMA_STRATEGY_DISTRIBUTE: c_int = 1;
pub const GGML_NUMA_STRATEGY_ISOLATE: c_int = 2;
pub const GGML_NUMA_STRATEGY_NUMACTL: c_int = 3;
pub const GGML_NUMA_STRATEGY_MIRROR: c_int = 4;
pub const GGML_NUMA_STRATEGY_COUNT: c_int = 5;
pub const enum_ggml_numa_strategy = c_uint;
pub extern fn ggml_numa_init(numa: enum_ggml_numa_strategy) void;
pub extern fn ggml_is_numa() bool;
pub extern fn ggml_new_i32(ctx: ?*struct_ggml_context, value: i32) [*c]struct_ggml_tensor;
pub extern fn ggml_new_f32(ctx: ?*struct_ggml_context, value: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_set_i32(tensor: [*c]struct_ggml_tensor, value: i32) [*c]struct_ggml_tensor;
pub extern fn ggml_set_f32(tensor: [*c]struct_ggml_tensor, value: f32) [*c]struct_ggml_tensor;
pub extern fn ggml_get_i32_1d(tensor: [*c]const struct_ggml_tensor, i: c_int) i32;
pub extern fn ggml_set_i32_1d(tensor: [*c]const struct_ggml_tensor, i: c_int, value: i32) void;
pub extern fn ggml_get_i32_nd(tensor: [*c]const struct_ggml_tensor, @"i0": c_int, @"i1": c_int, @"i2": c_int, @"i3": c_int) i32;
pub extern fn ggml_set_i32_nd(tensor: [*c]const struct_ggml_tensor, @"i0": c_int, @"i1": c_int, @"i2": c_int, @"i3": c_int, value: i32) void;
pub extern fn ggml_get_f32_1d(tensor: [*c]const struct_ggml_tensor, i: c_int) f32;
pub extern fn ggml_set_f32_1d(tensor: [*c]const struct_ggml_tensor, i: c_int, value: f32) void;
pub extern fn ggml_get_f32_nd(tensor: [*c]const struct_ggml_tensor, @"i0": c_int, @"i1": c_int, @"i2": c_int, @"i3": c_int) f32;
pub extern fn ggml_set_f32_nd(tensor: [*c]const struct_ggml_tensor, @"i0": c_int, @"i1": c_int, @"i2": c_int, @"i3": c_int, value: f32) void;
pub extern fn ggml_threadpool_new(params: [*c]struct_ggml_threadpool_params) ?*struct_ggml_threadpool;
pub extern fn ggml_threadpool_free(threadpool: ?*struct_ggml_threadpool) void;
pub extern fn ggml_threadpool_get_n_threads(threadpool: ?*struct_ggml_threadpool) c_int;
pub extern fn ggml_threadpool_pause(threadpool: ?*struct_ggml_threadpool) void;
pub extern fn ggml_threadpool_resume(threadpool: ?*struct_ggml_threadpool) void;
pub extern fn ggml_graph_plan(cgraph: ?*const struct_ggml_cgraph, n_threads: c_int, threadpool: ?*struct_ggml_threadpool) struct_ggml_cplan;
pub extern fn ggml_graph_compute(cgraph: ?*struct_ggml_cgraph, cplan: [*c]struct_ggml_cplan) enum_ggml_status;
pub extern fn ggml_graph_compute_with_ctx(ctx: ?*struct_ggml_context, cgraph: ?*struct_ggml_cgraph, n_threads: c_int) enum_ggml_status;
pub extern fn ggml_cpu_has_sse3() c_int;
pub extern fn ggml_cpu_has_ssse3() c_int;
pub extern fn ggml_cpu_has_avx() c_int;
pub extern fn ggml_cpu_has_avx_vnni() c_int;
pub extern fn ggml_cpu_has_avx2() c_int;
pub extern fn ggml_cpu_has_bmi2() c_int;
pub extern fn ggml_cpu_has_f16c() c_int;
pub extern fn ggml_cpu_has_fma() c_int;
pub extern fn ggml_cpu_has_avx512() c_int;
pub extern fn ggml_cpu_has_avx512_vbmi() c_int;
pub extern fn ggml_cpu_has_avx512_vnni() c_int;
pub extern fn ggml_cpu_has_avx512_bf16() c_int;
pub extern fn ggml_cpu_has_amx_int8() c_int;
pub extern fn ggml_cpu_has_neon() c_int;
pub extern fn ggml_cpu_has_arm_fma() c_int;
pub extern fn ggml_cpu_has_fp16_va() c_int;
pub extern fn ggml_cpu_has_dotprod() c_int;
pub extern fn ggml_cpu_has_matmul_int8() c_int;
pub extern fn ggml_cpu_has_sve() c_int;
pub extern fn ggml_cpu_get_sve_cnt() c_int;
pub extern fn ggml_cpu_has_sme() c_int;
pub extern fn ggml_cpu_has_riscv_v() c_int;
pub extern fn ggml_cpu_get_rvv_vlen() c_int;
pub extern fn ggml_cpu_has_vsx() c_int;
pub extern fn ggml_cpu_has_vxe() c_int;
pub extern fn ggml_cpu_has_wasm_simd() c_int;
pub extern fn ggml_cpu_has_llamafile() c_int;
pub const ggml_vec_dot_t = ?*const fn (n: c_int, noalias s: [*c]f32, bs: usize, noalias x: ?*const anyopaque, bx: usize, noalias y: ?*const anyopaque, by: usize, nrc: c_int) callconv(.c) void;
pub const struct_ggml_type_traits_cpu = extern struct {
    from_float: ggml_from_float_t = null,
    vec_dot: ggml_vec_dot_t = null,
    vec_dot_type: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
    nrows: i64 = 0,
};
pub extern fn ggml_get_type_traits_cpu(@"type": enum_ggml_type) [*c]const struct_ggml_type_traits_cpu;
pub extern fn ggml_cpu_init() void;
pub extern fn ggml_backend_cpu_init() ggml_backend_t;
pub extern fn ggml_backend_is_cpu(backend: ggml_backend_t) bool;
pub extern fn ggml_backend_cpu_set_n_threads(backend_cpu: ggml_backend_t, n_threads: c_int) void;
pub extern fn ggml_backend_cpu_set_threadpool(backend_cpu: ggml_backend_t, threadpool: ggml_threadpool_t) void;
pub extern fn ggml_backend_cpu_set_abort_callback(backend_cpu: ggml_backend_t, abort_callback: ggml_abort_callback, abort_callback_data: ?*anyopaque) void;
pub extern fn ggml_backend_cpu_set_use_ref(backend_cpu: ggml_backend_t, use_ref: bool) void;
pub extern fn ggml_backend_cpu_reg() ggml_backend_reg_t;
pub extern fn ggml_cpu_fp32_to_fp32([*c]const f32, [*c]f32, i64) void;
pub extern fn ggml_cpu_fp32_to_i32([*c]const f32, [*c]i32, i64) void;
pub extern fn ggml_cpu_fp32_to_fp16([*c]const f32, [*c]ggml_fp16_t, i64) void;
pub extern fn ggml_cpu_fp16_to_fp32([*c]const ggml_fp16_t, [*c]f32, i64) void;
pub extern fn ggml_cpu_fp32_to_bf16([*c]const f32, [*c]ggml_bf16_t, i64) void;
pub extern fn ggml_cpu_bf16_to_fp32([*c]const ggml_bf16_t, [*c]f32, i64) void;
pub const struct_ggml_opt_dataset = opaque {
    pub const ggml_opt_dataset_free = __root.ggml_opt_dataset_free;
    pub const ggml_opt_dataset_ndata = __root.ggml_opt_dataset_ndata;
    pub const ggml_opt_dataset_data = __root.ggml_opt_dataset_data;
    pub const ggml_opt_dataset_labels = __root.ggml_opt_dataset_labels;
    pub const ggml_opt_dataset_get_batch = __root.ggml_opt_dataset_get_batch;
    pub const ggml_opt_dataset_get_batch_host = __root.ggml_opt_dataset_get_batch_host;
    pub const free = __root.ggml_opt_dataset_free;
    pub const ndata = __root.ggml_opt_dataset_ndata;
    pub const data = __root.ggml_opt_dataset_data;
    pub const labels = __root.ggml_opt_dataset_labels;
    pub const get_batch = __root.ggml_opt_dataset_get_batch;
    pub const get_batch_host = __root.ggml_opt_dataset_get_batch_host;
};
pub const struct_ggml_opt_context = opaque {
    pub const ggml_opt_dataset_shuffle = __root.ggml_opt_dataset_shuffle;
    pub const ggml_opt_free = __root.ggml_opt_free;
    pub const ggml_opt_reset = __root.ggml_opt_reset;
    pub const ggml_opt_static_graphs = __root.ggml_opt_static_graphs;
    pub const ggml_opt_inputs = __root.ggml_opt_inputs;
    pub const ggml_opt_outputs = __root.ggml_opt_outputs;
    pub const ggml_opt_labels = __root.ggml_opt_labels;
    pub const ggml_opt_loss = __root.ggml_opt_loss;
    pub const ggml_opt_pred = __root.ggml_opt_pred;
    pub const ggml_opt_ncorrect = __root.ggml_opt_ncorrect;
    pub const ggml_opt_grad_acc = __root.ggml_opt_grad_acc;
    pub const ggml_opt_context_optimizer_type = __root.ggml_opt_context_optimizer_type;
    pub const ggml_opt_prepare_alloc = __root.ggml_opt_prepare_alloc;
    pub const ggml_opt_alloc = __root.ggml_opt_alloc;
    pub const ggml_opt_eval = __root.ggml_opt_eval;
    pub const ggml_opt_epoch = __root.ggml_opt_epoch;
    pub const shuffle = __root.ggml_opt_dataset_shuffle;
    pub const free = __root.ggml_opt_free;
    pub const reset = __root.ggml_opt_reset;
    pub const graphs = __root.ggml_opt_static_graphs;
    pub const inputs = __root.ggml_opt_inputs;
    pub const outputs = __root.ggml_opt_outputs;
    pub const labels = __root.ggml_opt_labels;
    pub const loss = __root.ggml_opt_loss;
    pub const pred = __root.ggml_opt_pred;
    pub const ncorrect = __root.ggml_opt_ncorrect;
    pub const acc = __root.ggml_opt_grad_acc;
    pub const optimizer_type = __root.ggml_opt_context_optimizer_type;
    pub const alloc = __root.ggml_opt_prepare_alloc;
    pub const eval = __root.ggml_opt_eval;
    pub const epoch = __root.ggml_opt_epoch;
};
pub const struct_ggml_opt_result = opaque {
    pub const ggml_opt_result_free = __root.ggml_opt_result_free;
    pub const ggml_opt_result_reset = __root.ggml_opt_result_reset;
    pub const ggml_opt_result_ndata = __root.ggml_opt_result_ndata;
    pub const ggml_opt_result_loss = __root.ggml_opt_result_loss;
    pub const ggml_opt_result_pred = __root.ggml_opt_result_pred;
    pub const ggml_opt_result_accuracy = __root.ggml_opt_result_accuracy;
    pub const free = __root.ggml_opt_result_free;
    pub const reset = __root.ggml_opt_result_reset;
    pub const ndata = __root.ggml_opt_result_ndata;
    pub const loss = __root.ggml_opt_result_loss;
    pub const pred = __root.ggml_opt_result_pred;
    pub const accuracy = __root.ggml_opt_result_accuracy;
};
pub const ggml_opt_dataset_t = ?*struct_ggml_opt_dataset;
pub const ggml_opt_context_t = ?*struct_ggml_opt_context;
pub const ggml_opt_result_t = ?*struct_ggml_opt_result;
pub const GGML_OPT_LOSS_TYPE_MEAN: c_int = 0;
pub const GGML_OPT_LOSS_TYPE_SUM: c_int = 1;
pub const GGML_OPT_LOSS_TYPE_CROSS_ENTROPY: c_int = 2;
pub const GGML_OPT_LOSS_TYPE_MEAN_SQUARED_ERROR: c_int = 3;
pub const enum_ggml_opt_loss_type = c_uint;
pub extern fn ggml_opt_dataset_init(type_data: enum_ggml_type, type_label: enum_ggml_type, ne_datapoint: i64, ne_label: i64, ndata: i64, ndata_shard: i64) ggml_opt_dataset_t;
pub extern fn ggml_opt_dataset_free(dataset: ggml_opt_dataset_t) void;
pub extern fn ggml_opt_dataset_ndata(dataset: ggml_opt_dataset_t) i64;
pub extern fn ggml_opt_dataset_data(dataset: ggml_opt_dataset_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_dataset_labels(dataset: ggml_opt_dataset_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_dataset_shuffle(opt_ctx: ggml_opt_context_t, dataset: ggml_opt_dataset_t, idata: i64) void;
pub extern fn ggml_opt_dataset_get_batch(dataset: ggml_opt_dataset_t, data_batch: [*c]struct_ggml_tensor, labels_batch: [*c]struct_ggml_tensor, ibatch: i64) void;
pub extern fn ggml_opt_dataset_get_batch_host(dataset: ggml_opt_dataset_t, data_batch: ?*anyopaque, nb_data_batch: usize, labels_batch: ?*anyopaque, ibatch: i64) void;
pub const GGML_OPT_BUILD_TYPE_FORWARD: c_int = 10;
pub const GGML_OPT_BUILD_TYPE_GRAD: c_int = 20;
pub const GGML_OPT_BUILD_TYPE_OPT: c_int = 30;
pub const enum_ggml_opt_build_type = c_uint;
pub const GGML_OPT_OPTIMIZER_TYPE_ADAMW: c_int = 0;
pub const GGML_OPT_OPTIMIZER_TYPE_SGD: c_int = 1;
pub const GGML_OPT_OPTIMIZER_TYPE_COUNT: c_int = 2;
pub const enum_ggml_opt_optimizer_type = c_uint;
const struct_unnamed_4 = extern struct {
    alpha: f32 = 0,
    beta1: f32 = 0,
    beta2: f32 = 0,
    eps: f32 = 0,
    wd: f32 = 0,
};
const struct_unnamed_5 = extern struct {
    alpha: f32 = 0,
    wd: f32 = 0,
};
pub const struct_ggml_opt_optimizer_params = extern struct {
    adamw: struct_unnamed_4 = @import("std").mem.zeroes(struct_unnamed_4),
    sgd: struct_unnamed_5 = @import("std").mem.zeroes(struct_unnamed_5),
};
pub const ggml_opt_get_optimizer_params = ?*const fn (userdata: ?*anyopaque) callconv(.c) struct_ggml_opt_optimizer_params;
pub extern fn ggml_opt_get_default_optimizer_params(userdata: ?*anyopaque) struct_ggml_opt_optimizer_params;
pub extern fn ggml_opt_get_constant_optimizer_params(userdata: ?*anyopaque) struct_ggml_opt_optimizer_params;
pub const struct_ggml_opt_params = extern struct {
    backend_sched: ggml_backend_sched_t = null,
    ctx_compute: ?*struct_ggml_context = null,
    inputs: [*c]struct_ggml_tensor = null,
    outputs: [*c]struct_ggml_tensor = null,
    loss_type: enum_ggml_opt_loss_type = @import("std").mem.zeroes(enum_ggml_opt_loss_type),
    build_type: enum_ggml_opt_build_type = @import("std").mem.zeroes(enum_ggml_opt_build_type),
    opt_period: i32 = 0,
    get_opt_pars: ggml_opt_get_optimizer_params = null,
    get_opt_pars_ud: ?*anyopaque = null,
    optimizer: enum_ggml_opt_optimizer_type = @import("std").mem.zeroes(enum_ggml_opt_optimizer_type),
    pub const ggml_opt_init = __root.ggml_opt_init;
    pub const init = __root.ggml_opt_init;
};
pub extern fn ggml_opt_default_params(backend_sched: ggml_backend_sched_t, loss_type: enum_ggml_opt_loss_type) struct_ggml_opt_params;
pub extern fn ggml_opt_init(params: struct_ggml_opt_params) ggml_opt_context_t;
pub extern fn ggml_opt_free(opt_ctx: ggml_opt_context_t) void;
pub extern fn ggml_opt_reset(opt_ctx: ggml_opt_context_t, optimizer: bool) void;
pub extern fn ggml_opt_static_graphs(opt_ctx: ggml_opt_context_t) bool;
pub extern fn ggml_opt_inputs(opt_ctx: ggml_opt_context_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_outputs(opt_ctx: ggml_opt_context_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_labels(opt_ctx: ggml_opt_context_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_loss(opt_ctx: ggml_opt_context_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_pred(opt_ctx: ggml_opt_context_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_ncorrect(opt_ctx: ggml_opt_context_t) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_grad_acc(opt_ctx: ggml_opt_context_t, node: [*c]struct_ggml_tensor) [*c]struct_ggml_tensor;
pub extern fn ggml_opt_context_optimizer_type(ggml_opt_context_t) enum_ggml_opt_optimizer_type;
pub extern fn ggml_opt_optimizer_name(enum_ggml_opt_optimizer_type) [*c]const u8;
pub extern fn ggml_opt_result_init() ggml_opt_result_t;
pub extern fn ggml_opt_result_free(result: ggml_opt_result_t) void;
pub extern fn ggml_opt_result_reset(result: ggml_opt_result_t) void;
pub extern fn ggml_opt_result_ndata(result: ggml_opt_result_t, ndata: [*c]i64) void;
pub extern fn ggml_opt_result_loss(result: ggml_opt_result_t, loss: [*c]f64, unc: [*c]f64) void;
pub extern fn ggml_opt_result_pred(result: ggml_opt_result_t, pred: [*c]i32) void;
pub extern fn ggml_opt_result_accuracy(result: ggml_opt_result_t, accuracy: [*c]f64, unc: [*c]f64) void;
pub extern fn ggml_opt_prepare_alloc(opt_ctx: ggml_opt_context_t, ctx_compute: ?*struct_ggml_context, gf: ?*struct_ggml_cgraph, inputs: [*c]struct_ggml_tensor, outputs: [*c]struct_ggml_tensor) void;
pub extern fn ggml_opt_alloc(opt_ctx: ggml_opt_context_t, backward: bool) void;
pub extern fn ggml_opt_eval(opt_ctx: ggml_opt_context_t, result: ggml_opt_result_t) void;
pub const ggml_opt_epoch_callback = ?*const fn (train: bool, opt_ctx: ggml_opt_context_t, dataset: ggml_opt_dataset_t, result: ggml_opt_result_t, ibatch: i64, ibatch_max: i64, t_start_us: i64) callconv(.c) void;
pub extern fn ggml_opt_epoch(opt_ctx: ggml_opt_context_t, dataset: ggml_opt_dataset_t, result_train: ggml_opt_result_t, result_eval: ggml_opt_result_t, idata_split: i64, callback_train: ggml_opt_epoch_callback, callback_eval: ggml_opt_epoch_callback) void;
pub extern fn ggml_opt_epoch_callback_progress_bar(train: bool, opt_ctx: ggml_opt_context_t, dataset: ggml_opt_dataset_t, result: ggml_opt_result_t, ibatch: i64, ibatch_max: i64, t_start_us: i64) void;
pub extern fn ggml_opt_fit(backend_sched: ggml_backend_sched_t, ctx_compute: ?*struct_ggml_context, inputs: [*c]struct_ggml_tensor, outputs: [*c]struct_ggml_tensor, dataset: ggml_opt_dataset_t, loss_type: enum_ggml_opt_loss_type, optimizer: enum_ggml_opt_optimizer_type, get_opt_pars: ggml_opt_get_optimizer_params, nepoch: i64, nbatch_logical: i64, val_split: f32, silent: bool) void;
pub const GGUF_TYPE_UINT8: c_int = 0;
pub const GGUF_TYPE_INT8: c_int = 1;
pub const GGUF_TYPE_UINT16: c_int = 2;
pub const GGUF_TYPE_INT16: c_int = 3;
pub const GGUF_TYPE_UINT32: c_int = 4;
pub const GGUF_TYPE_INT32: c_int = 5;
pub const GGUF_TYPE_FLOAT32: c_int = 6;
pub const GGUF_TYPE_BOOL: c_int = 7;
pub const GGUF_TYPE_STRING: c_int = 8;
pub const GGUF_TYPE_ARRAY: c_int = 9;
pub const GGUF_TYPE_UINT64: c_int = 10;
pub const GGUF_TYPE_INT64: c_int = 11;
pub const GGUF_TYPE_FLOAT64: c_int = 12;
pub const GGUF_TYPE_COUNT: c_int = 13;
pub const enum_gguf_type = c_uint;
pub const struct_gguf_context = opaque {
    pub const gguf_free = __root.gguf_free;
    pub const gguf_get_version = __root.gguf_get_version;
    pub const gguf_get_alignment = __root.gguf_get_alignment;
    pub const gguf_get_data_offset = __root.gguf_get_data_offset;
    pub const gguf_get_n_kv = __root.gguf_get_n_kv;
    pub const gguf_find_key = __root.gguf_find_key;
    pub const gguf_get_key = __root.gguf_get_key;
    pub const gguf_get_kv_type = __root.gguf_get_kv_type;
    pub const gguf_get_arr_type = __root.gguf_get_arr_type;
    pub const gguf_get_val_u8 = __root.gguf_get_val_u8;
    pub const gguf_get_val_i8 = __root.gguf_get_val_i8;
    pub const gguf_get_val_u16 = __root.gguf_get_val_u16;
    pub const gguf_get_val_i16 = __root.gguf_get_val_i16;
    pub const gguf_get_val_u32 = __root.gguf_get_val_u32;
    pub const gguf_get_val_i32 = __root.gguf_get_val_i32;
    pub const gguf_get_val_f32 = __root.gguf_get_val_f32;
    pub const gguf_get_val_u64 = __root.gguf_get_val_u64;
    pub const gguf_get_val_i64 = __root.gguf_get_val_i64;
    pub const gguf_get_val_f64 = __root.gguf_get_val_f64;
    pub const gguf_get_val_bool = __root.gguf_get_val_bool;
    pub const gguf_get_val_str = __root.gguf_get_val_str;
    pub const gguf_get_val_data = __root.gguf_get_val_data;
    pub const gguf_get_arr_n = __root.gguf_get_arr_n;
    pub const gguf_get_arr_data = __root.gguf_get_arr_data;
    pub const gguf_get_arr_str = __root.gguf_get_arr_str;
    pub const gguf_get_n_tensors = __root.gguf_get_n_tensors;
    pub const gguf_find_tensor = __root.gguf_find_tensor;
    pub const gguf_get_tensor_offset = __root.gguf_get_tensor_offset;
    pub const gguf_get_tensor_name = __root.gguf_get_tensor_name;
    pub const gguf_get_tensor_type = __root.gguf_get_tensor_type;
    pub const gguf_get_tensor_size = __root.gguf_get_tensor_size;
    pub const gguf_remove_key = __root.gguf_remove_key;
    pub const gguf_set_val_u8 = __root.gguf_set_val_u8;
    pub const gguf_set_val_i8 = __root.gguf_set_val_i8;
    pub const gguf_set_val_u16 = __root.gguf_set_val_u16;
    pub const gguf_set_val_i16 = __root.gguf_set_val_i16;
    pub const gguf_set_val_u32 = __root.gguf_set_val_u32;
    pub const gguf_set_val_i32 = __root.gguf_set_val_i32;
    pub const gguf_set_val_f32 = __root.gguf_set_val_f32;
    pub const gguf_set_val_u64 = __root.gguf_set_val_u64;
    pub const gguf_set_val_i64 = __root.gguf_set_val_i64;
    pub const gguf_set_val_f64 = __root.gguf_set_val_f64;
    pub const gguf_set_val_bool = __root.gguf_set_val_bool;
    pub const gguf_set_val_str = __root.gguf_set_val_str;
    pub const gguf_set_arr_data = __root.gguf_set_arr_data;
    pub const gguf_set_arr_str = __root.gguf_set_arr_str;
    pub const gguf_set_kv = __root.gguf_set_kv;
    pub const gguf_add_tensor = __root.gguf_add_tensor;
    pub const gguf_set_tensor_type = __root.gguf_set_tensor_type;
    pub const gguf_set_tensor_data = __root.gguf_set_tensor_data;
    pub const gguf_write_to_file_ptr = __root.gguf_write_to_file_ptr;
    pub const gguf_write_to_file = __root.gguf_write_to_file;
    pub const gguf_get_meta_size = __root.gguf_get_meta_size;
    pub const gguf_get_meta_data = __root.gguf_get_meta_data;
    pub const llama_model_init_from_user = __root.llama_model_init_from_user;
    pub const free = __root.gguf_free;
    pub const version = __root.gguf_get_version;
    pub const alignment = __root.gguf_get_alignment;
    pub const offset = __root.gguf_get_data_offset;
    pub const kv = __root.gguf_get_n_kv;
    pub const key = __root.gguf_find_key;
    pub const @"type" = __root.gguf_get_kv_type;
    pub const @"u8" = __root.gguf_get_val_u8;
    pub const @"i8" = __root.gguf_get_val_i8;
    pub const @"u16" = __root.gguf_get_val_u16;
    pub const @"i16" = __root.gguf_get_val_i16;
    pub const @"u32" = __root.gguf_get_val_u32;
    pub const @"i32" = __root.gguf_get_val_i32;
    pub const @"f32" = __root.gguf_get_val_f32;
    pub const @"u64" = __root.gguf_get_val_u64;
    pub const @"i64" = __root.gguf_get_val_i64;
    pub const @"f64" = __root.gguf_get_val_f64;
    pub const str = __root.gguf_get_val_str;
    pub const data = __root.gguf_get_val_data;
    pub const n = __root.gguf_get_arr_n;
    pub const tensors = __root.gguf_get_n_tensors;
    pub const tensor = __root.gguf_find_tensor;
    pub const name = __root.gguf_get_tensor_name;
    pub const size = __root.gguf_get_tensor_size;
    pub const ptr = __root.gguf_write_to_file_ptr;
    pub const file = __root.gguf_write_to_file;
    pub const user = __root.llama_model_init_from_user;
};
pub const struct_gguf_init_params = extern struct {
    no_alloc: bool = false,
    ctx: [*c]?*struct_ggml_context = null,
};
pub extern fn gguf_init_empty() ?*struct_gguf_context;
pub extern fn gguf_init_from_file_ptr(file: ?*FILE, params: struct_gguf_init_params) ?*struct_gguf_context;
pub extern fn gguf_init_from_file(fname: [*c]const u8, params: struct_gguf_init_params) ?*struct_gguf_context;
pub extern fn gguf_free(ctx: ?*struct_gguf_context) void;
pub extern fn gguf_type_name(@"type": enum_gguf_type) [*c]const u8;
pub extern fn gguf_get_version(ctx: ?*const struct_gguf_context) u32;
pub extern fn gguf_get_alignment(ctx: ?*const struct_gguf_context) usize;
pub extern fn gguf_get_data_offset(ctx: ?*const struct_gguf_context) usize;
pub extern fn gguf_get_n_kv(ctx: ?*const struct_gguf_context) i64;
pub extern fn gguf_find_key(ctx: ?*const struct_gguf_context, key: [*c]const u8) i64;
pub extern fn gguf_get_key(ctx: ?*const struct_gguf_context, key_id: i64) [*c]const u8;
pub extern fn gguf_get_kv_type(ctx: ?*const struct_gguf_context, key_id: i64) enum_gguf_type;
pub extern fn gguf_get_arr_type(ctx: ?*const struct_gguf_context, key_id: i64) enum_gguf_type;
pub extern fn gguf_get_val_u8(ctx: ?*const struct_gguf_context, key_id: i64) u8;
pub extern fn gguf_get_val_i8(ctx: ?*const struct_gguf_context, key_id: i64) i8;
pub extern fn gguf_get_val_u16(ctx: ?*const struct_gguf_context, key_id: i64) u16;
pub extern fn gguf_get_val_i16(ctx: ?*const struct_gguf_context, key_id: i64) i16;
pub extern fn gguf_get_val_u32(ctx: ?*const struct_gguf_context, key_id: i64) u32;
pub extern fn gguf_get_val_i32(ctx: ?*const struct_gguf_context, key_id: i64) i32;
pub extern fn gguf_get_val_f32(ctx: ?*const struct_gguf_context, key_id: i64) f32;
pub extern fn gguf_get_val_u64(ctx: ?*const struct_gguf_context, key_id: i64) u64;
pub extern fn gguf_get_val_i64(ctx: ?*const struct_gguf_context, key_id: i64) i64;
pub extern fn gguf_get_val_f64(ctx: ?*const struct_gguf_context, key_id: i64) f64;
pub extern fn gguf_get_val_bool(ctx: ?*const struct_gguf_context, key_id: i64) bool;
pub extern fn gguf_get_val_str(ctx: ?*const struct_gguf_context, key_id: i64) [*c]const u8;
pub extern fn gguf_get_val_data(ctx: ?*const struct_gguf_context, key_id: i64) ?*const anyopaque;
pub extern fn gguf_get_arr_n(ctx: ?*const struct_gguf_context, key_id: i64) usize;
pub extern fn gguf_get_arr_data(ctx: ?*const struct_gguf_context, key_id: i64) ?*const anyopaque;
pub extern fn gguf_get_arr_str(ctx: ?*const struct_gguf_context, key_id: i64, i: usize) [*c]const u8;
pub extern fn gguf_get_n_tensors(ctx: ?*const struct_gguf_context) i64;
pub extern fn gguf_find_tensor(ctx: ?*const struct_gguf_context, name: [*c]const u8) i64;
pub extern fn gguf_get_tensor_offset(ctx: ?*const struct_gguf_context, tensor_id: i64) usize;
pub extern fn gguf_get_tensor_name(ctx: ?*const struct_gguf_context, tensor_id: i64) [*c]const u8;
pub extern fn gguf_get_tensor_type(ctx: ?*const struct_gguf_context, tensor_id: i64) enum_ggml_type;
pub extern fn gguf_get_tensor_size(ctx: ?*const struct_gguf_context, tensor_id: i64) usize;
pub extern fn gguf_remove_key(ctx: ?*struct_gguf_context, key: [*c]const u8) i64;
pub extern fn gguf_set_val_u8(ctx: ?*struct_gguf_context, key: [*c]const u8, val: u8) void;
pub extern fn gguf_set_val_i8(ctx: ?*struct_gguf_context, key: [*c]const u8, val: i8) void;
pub extern fn gguf_set_val_u16(ctx: ?*struct_gguf_context, key: [*c]const u8, val: u16) void;
pub extern fn gguf_set_val_i16(ctx: ?*struct_gguf_context, key: [*c]const u8, val: i16) void;
pub extern fn gguf_set_val_u32(ctx: ?*struct_gguf_context, key: [*c]const u8, val: u32) void;
pub extern fn gguf_set_val_i32(ctx: ?*struct_gguf_context, key: [*c]const u8, val: i32) void;
pub extern fn gguf_set_val_f32(ctx: ?*struct_gguf_context, key: [*c]const u8, val: f32) void;
pub extern fn gguf_set_val_u64(ctx: ?*struct_gguf_context, key: [*c]const u8, val: u64) void;
pub extern fn gguf_set_val_i64(ctx: ?*struct_gguf_context, key: [*c]const u8, val: i64) void;
pub extern fn gguf_set_val_f64(ctx: ?*struct_gguf_context, key: [*c]const u8, val: f64) void;
pub extern fn gguf_set_val_bool(ctx: ?*struct_gguf_context, key: [*c]const u8, val: bool) void;
pub extern fn gguf_set_val_str(ctx: ?*struct_gguf_context, key: [*c]const u8, val: [*c]const u8) void;
pub extern fn gguf_set_arr_data(ctx: ?*struct_gguf_context, key: [*c]const u8, @"type": enum_gguf_type, data: ?*const anyopaque, n: usize) void;
pub extern fn gguf_set_arr_str(ctx: ?*struct_gguf_context, key: [*c]const u8, data: [*c][*c]const u8, n: usize) void;
pub extern fn gguf_set_kv(ctx: ?*struct_gguf_context, src: ?*const struct_gguf_context) void;
pub extern fn gguf_add_tensor(ctx: ?*struct_gguf_context, tensor: [*c]const struct_ggml_tensor) void;
pub extern fn gguf_set_tensor_type(ctx: ?*struct_gguf_context, name: [*c]const u8, @"type": enum_ggml_type) void;
pub extern fn gguf_set_tensor_data(ctx: ?*struct_gguf_context, name: [*c]const u8, data: ?*const anyopaque) void;
pub extern fn gguf_write_to_file_ptr(ctx: ?*const struct_gguf_context, file: ?*FILE, only_meta: bool) bool;
pub extern fn gguf_write_to_file(ctx: ?*const struct_gguf_context, fname: [*c]const u8, only_meta: bool) bool;
pub extern fn gguf_get_meta_size(ctx: ?*const struct_gguf_context) usize;
pub extern fn gguf_get_meta_data(ctx: ?*const struct_gguf_context, data: ?*anyopaque) void;
pub const struct_llama_vocab = opaque {
    pub const llama_n_vocab = __root.llama_n_vocab;
    pub const llama_vocab_type = __root.llama_vocab_type;
    pub const llama_vocab_n_tokens = __root.llama_vocab_n_tokens;
    pub const llama_vocab_get_text = __root.llama_vocab_get_text;
    pub const llama_vocab_get_score = __root.llama_vocab_get_score;
    pub const llama_vocab_get_attr = __root.llama_vocab_get_attr;
    pub const llama_vocab_is_eog = __root.llama_vocab_is_eog;
    pub const llama_vocab_is_control = __root.llama_vocab_is_control;
    pub const llama_vocab_bos = __root.llama_vocab_bos;
    pub const llama_vocab_eos = __root.llama_vocab_eos;
    pub const llama_vocab_eot = __root.llama_vocab_eot;
    pub const llama_vocab_sep = __root.llama_vocab_sep;
    pub const llama_vocab_nl = __root.llama_vocab_nl;
    pub const llama_vocab_pad = __root.llama_vocab_pad;
    pub const llama_vocab_mask = __root.llama_vocab_mask;
    pub const llama_vocab_get_add_bos = __root.llama_vocab_get_add_bos;
    pub const llama_vocab_get_add_eos = __root.llama_vocab_get_add_eos;
    pub const llama_vocab_get_add_sep = __root.llama_vocab_get_add_sep;
    pub const llama_vocab_fim_pre = __root.llama_vocab_fim_pre;
    pub const llama_vocab_fim_suf = __root.llama_vocab_fim_suf;
    pub const llama_vocab_fim_mid = __root.llama_vocab_fim_mid;
    pub const llama_vocab_fim_pad = __root.llama_vocab_fim_pad;
    pub const llama_vocab_fim_rep = __root.llama_vocab_fim_rep;
    pub const llama_vocab_fim_sep = __root.llama_vocab_fim_sep;
    pub const llama_token_get_text = __root.llama_token_get_text;
    pub const llama_token_get_score = __root.llama_token_get_score;
    pub const llama_token_get_attr = __root.llama_token_get_attr;
    pub const llama_token_is_eog = __root.llama_token_is_eog;
    pub const llama_token_is_control = __root.llama_token_is_control;
    pub const llama_token_bos = __root.llama_token_bos;
    pub const llama_token_eos = __root.llama_token_eos;
    pub const llama_token_eot = __root.llama_token_eot;
    pub const llama_token_cls = __root.llama_token_cls;
    pub const llama_token_sep = __root.llama_token_sep;
    pub const llama_token_nl = __root.llama_token_nl;
    pub const llama_token_pad = __root.llama_token_pad;
    pub const llama_add_bos_token = __root.llama_add_bos_token;
    pub const llama_add_eos_token = __root.llama_add_eos_token;
    pub const llama_token_fim_pre = __root.llama_token_fim_pre;
    pub const llama_token_fim_suf = __root.llama_token_fim_suf;
    pub const llama_token_fim_mid = __root.llama_token_fim_mid;
    pub const llama_token_fim_pad = __root.llama_token_fim_pad;
    pub const llama_token_fim_rep = __root.llama_token_fim_rep;
    pub const llama_token_fim_sep = __root.llama_token_fim_sep;
    pub const llama_vocab_cls = __root.llama_vocab_cls;
    pub const llama_tokenize = __root.llama_tokenize;
    pub const llama_token_to_piece = __root.llama_token_to_piece;
    pub const llama_detokenize = __root.llama_detokenize;
    pub const llama_sampler_init_grammar = __root.llama_sampler_init_grammar;
    pub const llama_sampler_init_grammar_lazy = __root.llama_sampler_init_grammar_lazy;
    pub const llama_sampler_init_grammar_lazy_patterns = __root.llama_sampler_init_grammar_lazy_patterns;
    pub const llama_sampler_init_dry = __root.llama_sampler_init_dry;
    pub const llama_sampler_init_infill = __root.llama_sampler_init_infill;
    pub const vocab = __root.llama_n_vocab;
    pub const @"type" = __root.llama_vocab_type;
    pub const n_tokens = __root.llama_vocab_n_tokens;
    pub const get_text = __root.llama_vocab_get_text;
    pub const get_score = __root.llama_vocab_get_score;
    pub const get_attr = __root.llama_vocab_get_attr;
    pub const is_eog = __root.llama_vocab_is_eog;
    pub const is_control = __root.llama_vocab_is_control;
    pub const bos = __root.llama_vocab_bos;
    pub const eos = __root.llama_vocab_eos;
    pub const eot = __root.llama_vocab_eot;
    pub const sep = __root.llama_vocab_sep;
    pub const nl = __root.llama_vocab_nl;
    pub const pad = __root.llama_vocab_pad;
    pub const mask = __root.llama_vocab_mask;
    pub const get_add_bos = __root.llama_vocab_get_add_bos;
    pub const get_add_eos = __root.llama_vocab_get_add_eos;
    pub const get_add_sep = __root.llama_vocab_get_add_sep;
    pub const fim_pre = __root.llama_vocab_fim_pre;
    pub const fim_suf = __root.llama_vocab_fim_suf;
    pub const fim_mid = __root.llama_vocab_fim_mid;
    pub const fim_pad = __root.llama_vocab_fim_pad;
    pub const fim_rep = __root.llama_vocab_fim_rep;
    pub const fim_sep = __root.llama_vocab_fim_sep;
    pub const text = __root.llama_token_get_text;
    pub const score = __root.llama_token_get_score;
    pub const attr = __root.llama_token_get_attr;
    pub const eog = __root.llama_token_is_eog;
    pub const control = __root.llama_token_is_control;
    pub const cls = __root.llama_token_cls;
    pub const token = __root.llama_add_bos_token;
    pub const pre = __root.llama_token_fim_pre;
    pub const suf = __root.llama_token_fim_suf;
    pub const mid = __root.llama_token_fim_mid;
    pub const rep = __root.llama_token_fim_rep;
    pub const tokenize = __root.llama_tokenize;
    pub const piece = __root.llama_token_to_piece;
    pub const detokenize = __root.llama_detokenize;
    pub const grammar = __root.llama_sampler_init_grammar;
    pub const lazy = __root.llama_sampler_init_grammar_lazy;
    pub const patterns = __root.llama_sampler_init_grammar_lazy_patterns;
    pub const dry = __root.llama_sampler_init_dry;
    pub const infill = __root.llama_sampler_init_infill;
};
pub const struct_llama_model = opaque {
    pub const llama_model_save_to_file = __root.llama_model_save_to_file;
    pub const llama_free_model = __root.llama_free_model;
    pub const llama_model_free = __root.llama_model_free;
    pub const llama_init_from_model = __root.llama_init_from_model;
    pub const llama_new_context_with_model = __root.llama_new_context_with_model;
    pub const llama_n_ctx_train = __root.llama_n_ctx_train;
    pub const llama_n_embd = __root.llama_n_embd;
    pub const llama_n_layer = __root.llama_n_layer;
    pub const llama_n_head = __root.llama_n_head;
    pub const llama_model_get_vocab = __root.llama_model_get_vocab;
    pub const llama_model_rope_type = __root.llama_model_rope_type;
    pub const llama_model_n_ctx_train = __root.llama_model_n_ctx_train;
    pub const llama_model_n_embd = __root.llama_model_n_embd;
    pub const llama_model_n_embd_inp = __root.llama_model_n_embd_inp;
    pub const llama_model_n_embd_out = __root.llama_model_n_embd_out;
    pub const llama_model_n_layer = __root.llama_model_n_layer;
    pub const llama_model_n_head = __root.llama_model_n_head;
    pub const llama_model_n_head_kv = __root.llama_model_n_head_kv;
    pub const llama_model_n_swa = __root.llama_model_n_swa;
    pub const llama_model_rope_freq_scale_train = __root.llama_model_rope_freq_scale_train;
    pub const llama_model_n_cls_out = __root.llama_model_n_cls_out;
    pub const llama_model_cls_label = __root.llama_model_cls_label;
    pub const llama_model_meta_val_str = __root.llama_model_meta_val_str;
    pub const llama_model_meta_count = __root.llama_model_meta_count;
    pub const llama_model_meta_key_by_index = __root.llama_model_meta_key_by_index;
    pub const llama_model_meta_val_str_by_index = __root.llama_model_meta_val_str_by_index;
    pub const llama_model_desc = __root.llama_model_desc;
    pub const llama_model_size = __root.llama_model_size;
    pub const llama_model_chat_template = __root.llama_model_chat_template;
    pub const llama_model_n_params = __root.llama_model_n_params;
    pub const llama_model_has_encoder = __root.llama_model_has_encoder;
    pub const llama_model_has_decoder = __root.llama_model_has_decoder;
    pub const llama_model_decoder_start_token = __root.llama_model_decoder_start_token;
    pub const llama_model_is_recurrent = __root.llama_model_is_recurrent;
    pub const llama_model_is_hybrid = __root.llama_model_is_hybrid;
    pub const llama_model_is_diffusion = __root.llama_model_is_diffusion;
    pub const llama_adapter_lora_init = __root.llama_adapter_lora_init;
    pub const save_to_file = __root.llama_model_save_to_file;
    pub const model = __root.llama_free_model;
    pub const free = __root.llama_model_free;
    pub const train = __root.llama_n_ctx_train;
    pub const embd = __root.llama_n_embd;
    pub const layer = __root.llama_n_layer;
    pub const head = __root.llama_n_head;
    pub const get_vocab = __root.llama_model_get_vocab;
    pub const rope_type = __root.llama_model_rope_type;
    pub const n_ctx_train = __root.llama_model_n_ctx_train;
    pub const n_embd = __root.llama_model_n_embd;
    pub const n_embd_inp = __root.llama_model_n_embd_inp;
    pub const n_embd_out = __root.llama_model_n_embd_out;
    pub const n_layer = __root.llama_model_n_layer;
    pub const n_head = __root.llama_model_n_head;
    pub const n_head_kv = __root.llama_model_n_head_kv;
    pub const n_swa = __root.llama_model_n_swa;
    pub const rope_freq_scale_train = __root.llama_model_rope_freq_scale_train;
    pub const n_cls_out = __root.llama_model_n_cls_out;
    pub const cls_label = __root.llama_model_cls_label;
    pub const meta_val_str = __root.llama_model_meta_val_str;
    pub const meta_count = __root.llama_model_meta_count;
    pub const meta_key_by_index = __root.llama_model_meta_key_by_index;
    pub const meta_val_str_by_index = __root.llama_model_meta_val_str_by_index;
    pub const desc = __root.llama_model_desc;
    pub const size = __root.llama_model_size;
    pub const chat_template = __root.llama_model_chat_template;
    pub const n_params = __root.llama_model_n_params;
    pub const has_encoder = __root.llama_model_has_encoder;
    pub const has_decoder = __root.llama_model_has_decoder;
    pub const decoder_start_token = __root.llama_model_decoder_start_token;
    pub const is_recurrent = __root.llama_model_is_recurrent;
    pub const is_hybrid = __root.llama_model_is_hybrid;
    pub const is_diffusion = __root.llama_model_is_diffusion;
    pub const init = __root.llama_adapter_lora_init;
};
pub const struct_llama_context = opaque {
    pub const llama_attach_threadpool = __root.llama_attach_threadpool;
    pub const llama_detach_threadpool = __root.llama_detach_threadpool;
    pub const llama_free = __root.llama_free;
    pub const llama_n_ctx = __root.llama_n_ctx;
    pub const llama_n_ctx_seq = __root.llama_n_ctx_seq;
    pub const llama_n_batch = __root.llama_n_batch;
    pub const llama_n_ubatch = __root.llama_n_ubatch;
    pub const llama_n_seq_max = __root.llama_n_seq_max;
    pub const llama_get_model = __root.llama_get_model;
    pub const llama_get_memory = __root.llama_get_memory;
    pub const llama_pooling_type = __root.llama_pooling_type;
    pub const llama_set_adapters_lora = __root.llama_set_adapters_lora;
    pub const llama_set_adapter_cvec = __root.llama_set_adapter_cvec;
    pub const llama_state_get_size = __root.llama_state_get_size;
    pub const llama_get_state_size = __root.llama_get_state_size;
    pub const llama_state_get_data = __root.llama_state_get_data;
    pub const llama_copy_state_data = __root.llama_copy_state_data;
    pub const llama_state_set_data = __root.llama_state_set_data;
    pub const llama_set_state_data = __root.llama_set_state_data;
    pub const llama_state_load_file = __root.llama_state_load_file;
    pub const llama_load_session_file = __root.llama_load_session_file;
    pub const llama_state_save_file = __root.llama_state_save_file;
    pub const llama_save_session_file = __root.llama_save_session_file;
    pub const llama_state_seq_get_size = __root.llama_state_seq_get_size;
    pub const llama_state_seq_get_data = __root.llama_state_seq_get_data;
    pub const llama_state_seq_set_data = __root.llama_state_seq_set_data;
    pub const llama_state_seq_save_file = __root.llama_state_seq_save_file;
    pub const llama_state_seq_load_file = __root.llama_state_seq_load_file;
    pub const llama_state_seq_get_size_ext = __root.llama_state_seq_get_size_ext;
    pub const llama_state_seq_get_data_ext = __root.llama_state_seq_get_data_ext;
    pub const llama_state_seq_set_data_ext = __root.llama_state_seq_set_data_ext;
    pub const llama_encode = __root.llama_encode;
    pub const llama_decode = __root.llama_decode;
    pub const llama_set_n_threads = __root.llama_set_n_threads;
    pub const llama_n_threads = __root.llama_n_threads;
    pub const llama_n_threads_batch = __root.llama_n_threads_batch;
    pub const llama_set_embeddings = __root.llama_set_embeddings;
    pub const llama_set_causal_attn = __root.llama_set_causal_attn;
    pub const llama_set_warmup = __root.llama_set_warmup;
    pub const llama_set_abort_callback = __root.llama_set_abort_callback;
    pub const llama_synchronize = __root.llama_synchronize;
    pub const llama_get_logits = __root.llama_get_logits;
    pub const llama_get_logits_ith = __root.llama_get_logits_ith;
    pub const llama_get_embeddings = __root.llama_get_embeddings;
    pub const llama_get_embeddings_ith = __root.llama_get_embeddings_ith;
    pub const llama_get_embeddings_seq = __root.llama_get_embeddings_seq;
    pub const llama_get_sampled_token_ith = __root.llama_get_sampled_token_ith;
    pub const llama_get_sampled_probs_ith = __root.llama_get_sampled_probs_ith;
    pub const llama_get_sampled_probs_count_ith = __root.llama_get_sampled_probs_count_ith;
    pub const llama_get_sampled_logits_ith = __root.llama_get_sampled_logits_ith;
    pub const llama_get_sampled_logits_count_ith = __root.llama_get_sampled_logits_count_ith;
    pub const llama_get_sampled_candidates_ith = __root.llama_get_sampled_candidates_ith;
    pub const llama_get_sampled_candidates_count_ith = __root.llama_get_sampled_candidates_count_ith;
    pub const llama_set_sampler = __root.llama_set_sampler;
    pub const llama_perf_context = __root.llama_perf_context;
    pub const llama_perf_context_print = __root.llama_perf_context_print;
    pub const llama_perf_context_reset = __root.llama_perf_context_reset;
    pub const llama_memory_breakdown_print = __root.llama_memory_breakdown_print;
    pub const llama_opt_init = __root.llama_opt_init;
    pub const llama_opt_epoch = __root.llama_opt_epoch;
    pub const threadpool = __root.llama_attach_threadpool;
    pub const free = __root.llama_free;
    pub const ctx = __root.llama_n_ctx;
    pub const seq = __root.llama_n_ctx_seq;
    pub const batch = __root.llama_n_batch;
    pub const ubatch = __root.llama_n_ubatch;
    pub const max = __root.llama_n_seq_max;
    pub const model = __root.llama_get_model;
    pub const memory = __root.llama_get_memory;
    pub const @"type" = __root.llama_pooling_type;
    pub const lora = __root.llama_set_adapters_lora;
    pub const cvec = __root.llama_set_adapter_cvec;
    pub const size = __root.llama_state_get_size;
    pub const data = __root.llama_state_get_data;
    pub const file = __root.llama_state_load_file;
    pub const ext = __root.llama_state_seq_get_size_ext;
    pub const encode = __root.llama_encode;
    pub const decode = __root.llama_decode;
    pub const threads = __root.llama_set_n_threads;
    pub const embeddings = __root.llama_set_embeddings;
    pub const attn = __root.llama_set_causal_attn;
    pub const warmup = __root.llama_set_warmup;
    pub const callback = __root.llama_set_abort_callback;
    pub const synchronize = __root.llama_synchronize;
    pub const logits = __root.llama_get_logits;
    pub const ith = __root.llama_get_logits_ith;
    pub const sampler = __root.llama_set_sampler;
    pub const context = __root.llama_perf_context;
    pub const print = __root.llama_perf_context_print;
    pub const reset = __root.llama_perf_context_reset;
    pub const init = __root.llama_opt_init;
    pub const epoch = __root.llama_opt_epoch;
};
pub const llama_token = i32;
pub const struct_llama_token_data = extern struct {
    id: llama_token = 0,
    logit: f32 = 0,
    p: f32 = 0,
};
pub const llama_token_data = struct_llama_token_data;
pub const struct_llama_token_data_array = extern struct {
    data: [*c]llama_token_data = null,
    size: usize = 0,
    selected: i64 = 0,
    sorted: bool = false,
};
pub const llama_token_data_array = struct_llama_token_data_array;
pub const struct_llama_sampler_data = extern struct {
    logits: [*c]struct_ggml_tensor = null,
    probs: [*c]struct_ggml_tensor = null,
    sampled: [*c]struct_ggml_tensor = null,
    candidates: [*c]struct_ggml_tensor = null,
};
pub const struct_llama_sampler_i = extern struct {
    name: ?*const fn (smpl: [*c]const struct_llama_sampler) callconv(.c) [*c]const u8 = null,
    accept: ?*const fn (smpl: [*c]struct_llama_sampler, token: llama_token) callconv(.c) void = null,
    apply: ?*const fn (smpl: [*c]struct_llama_sampler, cur_p: [*c]llama_token_data_array) callconv(.c) void = null,
    reset: ?*const fn (smpl: [*c]struct_llama_sampler) callconv(.c) void = null,
    clone: ?*const fn (smpl: [*c]const struct_llama_sampler) callconv(.c) [*c]struct_llama_sampler = null,
    free: ?*const fn (smpl: [*c]struct_llama_sampler) callconv(.c) void = null,
    backend_init: ?*const fn (smpl: [*c]struct_llama_sampler, buft: ggml_backend_buffer_type_t) callconv(.c) bool = null,
    backend_accept: ?*const fn (smpl: [*c]struct_llama_sampler, ctx: ?*struct_ggml_context, gf: ?*struct_ggml_cgraph, selected_token: [*c]struct_ggml_tensor) callconv(.c) void = null,
    backend_apply: ?*const fn (smpl: [*c]struct_llama_sampler, ctx: ?*struct_ggml_context, gf: ?*struct_ggml_cgraph, data: [*c]struct_llama_sampler_data) callconv(.c) void = null,
    backend_set_input: ?*const fn (smpl: [*c]struct_llama_sampler) callconv(.c) void = null,
    pub const llama_sampler_init = __root.llama_sampler_init;
    pub const init = __root.llama_sampler_init;
};
pub const llama_sampler_context_t = ?*anyopaque;
pub const struct_llama_sampler = extern struct {
    iface: [*c]struct_llama_sampler_i = null,
    ctx: llama_sampler_context_t = null,
    pub const llama_sampler_name = __root.llama_sampler_name;
    pub const llama_sampler_accept = __root.llama_sampler_accept;
    pub const llama_sampler_apply = __root.llama_sampler_apply;
    pub const llama_sampler_reset = __root.llama_sampler_reset;
    pub const llama_sampler_clone = __root.llama_sampler_clone;
    pub const llama_sampler_free = __root.llama_sampler_free;
    pub const llama_sampler_chain_add = __root.llama_sampler_chain_add;
    pub const llama_sampler_chain_get = __root.llama_sampler_chain_get;
    pub const llama_sampler_chain_n = __root.llama_sampler_chain_n;
    pub const llama_sampler_chain_remove = __root.llama_sampler_chain_remove;
    pub const llama_sampler_get_seed = __root.llama_sampler_get_seed;
    pub const llama_sampler_sample = __root.llama_sampler_sample;
    pub const llama_perf_sampler = __root.llama_perf_sampler;
    pub const llama_perf_sampler_print = __root.llama_perf_sampler_print;
    pub const llama_perf_sampler_reset = __root.llama_perf_sampler_reset;
    pub const name = __root.llama_sampler_name;
    pub const accept = __root.llama_sampler_accept;
    pub const apply = __root.llama_sampler_apply;
    pub const reset = __root.llama_sampler_reset;
    pub const clone = __root.llama_sampler_clone;
    pub const free = __root.llama_sampler_free;
    pub const chain_add = __root.llama_sampler_chain_add;
    pub const chain_get = __root.llama_sampler_chain_get;
    pub const chain_n = __root.llama_sampler_chain_n;
    pub const chain_remove = __root.llama_sampler_chain_remove;
    pub const get_seed = __root.llama_sampler_get_seed;
    pub const sample = __root.llama_sampler_sample;
    pub const sampler = __root.llama_perf_sampler;
    pub const print = __root.llama_perf_sampler_print;
};
pub const struct_llama_memory_i = opaque {
    pub const llama_memory_clear = __root.llama_memory_clear;
    pub const llama_memory_seq_rm = __root.llama_memory_seq_rm;
    pub const llama_memory_seq_cp = __root.llama_memory_seq_cp;
    pub const llama_memory_seq_keep = __root.llama_memory_seq_keep;
    pub const llama_memory_seq_add = __root.llama_memory_seq_add;
    pub const llama_memory_seq_div = __root.llama_memory_seq_div;
    pub const llama_memory_seq_pos_min = __root.llama_memory_seq_pos_min;
    pub const llama_memory_seq_pos_max = __root.llama_memory_seq_pos_max;
    pub const llama_memory_can_shift = __root.llama_memory_can_shift;
    pub const clear = __root.llama_memory_clear;
    pub const rm = __root.llama_memory_seq_rm;
    pub const cp = __root.llama_memory_seq_cp;
    pub const keep = __root.llama_memory_seq_keep;
    pub const add = __root.llama_memory_seq_add;
    pub const div = __root.llama_memory_seq_div;
    pub const min = __root.llama_memory_seq_pos_min;
    pub const max = __root.llama_memory_seq_pos_max;
    pub const shift = __root.llama_memory_can_shift;
};
pub const llama_memory_t = ?*struct_llama_memory_i;
pub const llama_pos = i32;
pub const llama_seq_id = i32;
pub const LLAMA_VOCAB_TYPE_NONE: c_int = 0;
pub const LLAMA_VOCAB_TYPE_SPM: c_int = 1;
pub const LLAMA_VOCAB_TYPE_BPE: c_int = 2;
pub const LLAMA_VOCAB_TYPE_WPM: c_int = 3;
pub const LLAMA_VOCAB_TYPE_UGM: c_int = 4;
pub const LLAMA_VOCAB_TYPE_RWKV: c_int = 5;
pub const LLAMA_VOCAB_TYPE_PLAMO2: c_int = 6;
pub const enum_llama_vocab_type = c_uint;
pub const LLAMA_ROPE_TYPE_NONE: c_int = -1;
pub const LLAMA_ROPE_TYPE_NORM: c_int = 0;
pub const LLAMA_ROPE_TYPE_NEOX: c_int = 2;
pub const LLAMA_ROPE_TYPE_MROPE: c_int = 8;
pub const LLAMA_ROPE_TYPE_IMROPE: c_int = 40;
pub const LLAMA_ROPE_TYPE_VISION: c_int = 24;
pub const enum_llama_rope_type = c_int;
pub const LLAMA_TOKEN_TYPE_UNDEFINED: c_int = 0;
pub const LLAMA_TOKEN_TYPE_NORMAL: c_int = 1;
pub const LLAMA_TOKEN_TYPE_UNKNOWN: c_int = 2;
pub const LLAMA_TOKEN_TYPE_CONTROL: c_int = 3;
pub const LLAMA_TOKEN_TYPE_USER_DEFINED: c_int = 4;
pub const LLAMA_TOKEN_TYPE_UNUSED: c_int = 5;
pub const LLAMA_TOKEN_TYPE_BYTE: c_int = 6;
pub const enum_llama_token_type = c_uint;
pub const LLAMA_TOKEN_ATTR_UNDEFINED: c_int = 0;
pub const LLAMA_TOKEN_ATTR_UNKNOWN: c_int = 1;
pub const LLAMA_TOKEN_ATTR_UNUSED: c_int = 2;
pub const LLAMA_TOKEN_ATTR_NORMAL: c_int = 4;
pub const LLAMA_TOKEN_ATTR_CONTROL: c_int = 8;
pub const LLAMA_TOKEN_ATTR_USER_DEFINED: c_int = 16;
pub const LLAMA_TOKEN_ATTR_BYTE: c_int = 32;
pub const LLAMA_TOKEN_ATTR_NORMALIZED: c_int = 64;
pub const LLAMA_TOKEN_ATTR_LSTRIP: c_int = 128;
pub const LLAMA_TOKEN_ATTR_RSTRIP: c_int = 256;
pub const LLAMA_TOKEN_ATTR_SINGLE_WORD: c_int = 512;
pub const enum_llama_token_attr = c_uint;
pub const LLAMA_FTYPE_ALL_F32: c_int = 0;
pub const LLAMA_FTYPE_MOSTLY_F16: c_int = 1;
pub const LLAMA_FTYPE_MOSTLY_Q4_0: c_int = 2;
pub const LLAMA_FTYPE_MOSTLY_Q4_1: c_int = 3;
pub const LLAMA_FTYPE_MOSTLY_Q8_0: c_int = 7;
pub const LLAMA_FTYPE_MOSTLY_Q5_0: c_int = 8;
pub const LLAMA_FTYPE_MOSTLY_Q5_1: c_int = 9;
pub const LLAMA_FTYPE_MOSTLY_Q2_K: c_int = 10;
pub const LLAMA_FTYPE_MOSTLY_Q3_K_S: c_int = 11;
pub const LLAMA_FTYPE_MOSTLY_Q3_K_M: c_int = 12;
pub const LLAMA_FTYPE_MOSTLY_Q3_K_L: c_int = 13;
pub const LLAMA_FTYPE_MOSTLY_Q4_K_S: c_int = 14;
pub const LLAMA_FTYPE_MOSTLY_Q4_K_M: c_int = 15;
pub const LLAMA_FTYPE_MOSTLY_Q5_K_S: c_int = 16;
pub const LLAMA_FTYPE_MOSTLY_Q5_K_M: c_int = 17;
pub const LLAMA_FTYPE_MOSTLY_Q6_K: c_int = 18;
pub const LLAMA_FTYPE_MOSTLY_IQ2_XXS: c_int = 19;
pub const LLAMA_FTYPE_MOSTLY_IQ2_XS: c_int = 20;
pub const LLAMA_FTYPE_MOSTLY_Q2_K_S: c_int = 21;
pub const LLAMA_FTYPE_MOSTLY_IQ3_XS: c_int = 22;
pub const LLAMA_FTYPE_MOSTLY_IQ3_XXS: c_int = 23;
pub const LLAMA_FTYPE_MOSTLY_IQ1_S: c_int = 24;
pub const LLAMA_FTYPE_MOSTLY_IQ4_NL: c_int = 25;
pub const LLAMA_FTYPE_MOSTLY_IQ3_S: c_int = 26;
pub const LLAMA_FTYPE_MOSTLY_IQ3_M: c_int = 27;
pub const LLAMA_FTYPE_MOSTLY_IQ2_S: c_int = 28;
pub const LLAMA_FTYPE_MOSTLY_IQ2_M: c_int = 29;
pub const LLAMA_FTYPE_MOSTLY_IQ4_XS: c_int = 30;
pub const LLAMA_FTYPE_MOSTLY_IQ1_M: c_int = 31;
pub const LLAMA_FTYPE_MOSTLY_BF16: c_int = 32;
pub const LLAMA_FTYPE_MOSTLY_TQ1_0: c_int = 36;
pub const LLAMA_FTYPE_MOSTLY_TQ2_0: c_int = 37;
pub const LLAMA_FTYPE_MOSTLY_MXFP4_MOE: c_int = 38;
pub const LLAMA_FTYPE_MOSTLY_NVFP4: c_int = 39;
pub const LLAMA_FTYPE_MOSTLY_Q1_0: c_int = 40;
pub const LLAMA_FTYPE_GUESSED: c_int = 1024;
pub const enum_llama_ftype = c_uint;
pub const LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED: c_int = -1;
pub const LLAMA_ROPE_SCALING_TYPE_NONE: c_int = 0;
pub const LLAMA_ROPE_SCALING_TYPE_LINEAR: c_int = 1;
pub const LLAMA_ROPE_SCALING_TYPE_YARN: c_int = 2;
pub const LLAMA_ROPE_SCALING_TYPE_LONGROPE: c_int = 3;
pub const LLAMA_ROPE_SCALING_TYPE_MAX_VALUE: c_int = 3;
pub const enum_llama_rope_scaling_type = c_int;
pub const LLAMA_POOLING_TYPE_UNSPECIFIED: c_int = -1;
pub const LLAMA_POOLING_TYPE_NONE: c_int = 0;
pub const LLAMA_POOLING_TYPE_MEAN: c_int = 1;
pub const LLAMA_POOLING_TYPE_CLS: c_int = 2;
pub const LLAMA_POOLING_TYPE_LAST: c_int = 3;
pub const LLAMA_POOLING_TYPE_RANK: c_int = 4;
pub const enum_llama_pooling_type = c_int;
pub const LLAMA_ATTENTION_TYPE_UNSPECIFIED: c_int = -1;
pub const LLAMA_ATTENTION_TYPE_CAUSAL: c_int = 0;
pub const LLAMA_ATTENTION_TYPE_NON_CAUSAL: c_int = 1;
pub const enum_llama_attention_type = c_int;
pub const LLAMA_FLASH_ATTN_TYPE_AUTO: c_int = -1;
pub const LLAMA_FLASH_ATTN_TYPE_DISABLED: c_int = 0;
pub const LLAMA_FLASH_ATTN_TYPE_ENABLED: c_int = 1;
pub const enum_llama_flash_attn_type = c_int;
pub extern fn llama_flash_attn_type_name(flash_attn_type: enum_llama_flash_attn_type) [*c]const u8;
pub const LLAMA_SPLIT_MODE_NONE: c_int = 0;
pub const LLAMA_SPLIT_MODE_LAYER: c_int = 1;
pub const LLAMA_SPLIT_MODE_ROW: c_int = 2;
pub const LLAMA_SPLIT_MODE_TENSOR: c_int = 3;
pub const enum_llama_split_mode = c_uint;
pub const llama_progress_callback = ?*const fn (progress: f32, user_data: ?*anyopaque) callconv(.c) bool;
pub const struct_llama_batch = extern struct {
    n_tokens: i32 = 0,
    token: [*c]llama_token = null,
    embd: [*c]f32 = null,
    pos: [*c]llama_pos = null,
    n_seq_id: [*c]i32 = null,
    seq_id: [*c][*c]llama_seq_id = null,
    logits: [*c]i8 = null,
    pub const llama_batch_free = __root.llama_batch_free;
    pub const free = __root.llama_batch_free;
};
pub const llama_batch = struct_llama_batch;
pub const LLAMA_KV_OVERRIDE_TYPE_INT: c_int = 0;
pub const LLAMA_KV_OVERRIDE_TYPE_FLOAT: c_int = 1;
pub const LLAMA_KV_OVERRIDE_TYPE_BOOL: c_int = 2;
pub const LLAMA_KV_OVERRIDE_TYPE_STR: c_int = 3;
pub const enum_llama_model_kv_override_type = c_uint;
pub const LLAMA_MODEL_META_KEY_SAMPLING_SEQUENCE: c_int = 0;
pub const LLAMA_MODEL_META_KEY_SAMPLING_TOP_K: c_int = 1;
pub const LLAMA_MODEL_META_KEY_SAMPLING_TOP_P: c_int = 2;
pub const LLAMA_MODEL_META_KEY_SAMPLING_MIN_P: c_int = 3;
pub const LLAMA_MODEL_META_KEY_SAMPLING_XTC_PROBABILITY: c_int = 4;
pub const LLAMA_MODEL_META_KEY_SAMPLING_XTC_THRESHOLD: c_int = 5;
pub const LLAMA_MODEL_META_KEY_SAMPLING_TEMP: c_int = 6;
pub const LLAMA_MODEL_META_KEY_SAMPLING_PENALTY_LAST_N: c_int = 7;
pub const LLAMA_MODEL_META_KEY_SAMPLING_PENALTY_REPEAT: c_int = 8;
pub const LLAMA_MODEL_META_KEY_SAMPLING_MIROSTAT: c_int = 9;
pub const LLAMA_MODEL_META_KEY_SAMPLING_MIROSTAT_TAU: c_int = 10;
pub const LLAMA_MODEL_META_KEY_SAMPLING_MIROSTAT_ETA: c_int = 11;
pub const enum_llama_model_meta_key = c_uint;
const union_unnamed_6 = extern union {
    val_i64: i64,
    val_f64: f64,
    val_bool: bool,
    val_str: [128]u8,
};
pub const struct_llama_model_kv_override = extern struct {
    tag: enum_llama_model_kv_override_type = @import("std").mem.zeroes(enum_llama_model_kv_override_type),
    key: [128]u8 = @import("std").mem.zeroes([128]u8),
    unnamed_0: union_unnamed_6 = @import("std").mem.zeroes(union_unnamed_6),
};
pub const struct_llama_model_tensor_buft_override = extern struct {
    pattern: [*c]const u8 = null,
    buft: ggml_backend_buffer_type_t = null,
};
pub const struct_llama_model_params = extern struct {
    devices: [*c]ggml_backend_dev_t = null,
    tensor_buft_overrides: [*c]const struct_llama_model_tensor_buft_override = null,
    n_gpu_layers: i32 = 0,
    split_mode: enum_llama_split_mode = @import("std").mem.zeroes(enum_llama_split_mode),
    main_gpu: i32 = 0,
    tensor_split: [*c]const f32 = null,
    progress_callback: llama_progress_callback = null,
    progress_callback_user_data: ?*anyopaque = null,
    kv_overrides: [*c]const struct_llama_model_kv_override = null,
    vocab_only: bool = false,
    use_mmap: bool = false,
    use_direct_io: bool = false,
    use_mlock: bool = false,
    check_tensors: bool = false,
    use_extra_bufts: bool = false,
    no_host: bool = false,
    no_alloc: bool = false,
};
pub const struct_llama_sampler_seq_config = extern struct {
    seq_id: llama_seq_id = 0,
    sampler: [*c]struct_llama_sampler = null,
};
pub const struct_llama_context_params = extern struct {
    n_ctx: u32 = 0,
    n_batch: u32 = 0,
    n_ubatch: u32 = 0,
    n_seq_max: u32 = 0,
    n_threads: i32 = 0,
    n_threads_batch: i32 = 0,
    rope_scaling_type: enum_llama_rope_scaling_type = @import("std").mem.zeroes(enum_llama_rope_scaling_type),
    pooling_type: enum_llama_pooling_type = @import("std").mem.zeroes(enum_llama_pooling_type),
    attention_type: enum_llama_attention_type = @import("std").mem.zeroes(enum_llama_attention_type),
    flash_attn_type: enum_llama_flash_attn_type = @import("std").mem.zeroes(enum_llama_flash_attn_type),
    rope_freq_base: f32 = 0,
    rope_freq_scale: f32 = 0,
    yarn_ext_factor: f32 = 0,
    yarn_attn_factor: f32 = 0,
    yarn_beta_fast: f32 = 0,
    yarn_beta_slow: f32 = 0,
    yarn_orig_ctx: u32 = 0,
    defrag_thold: f32 = 0,
    cb_eval: ggml_backend_sched_eval_callback = null,
    cb_eval_user_data: ?*anyopaque = null,
    type_k: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
    type_v: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
    abort_callback: ggml_abort_callback = null,
    abort_callback_data: ?*anyopaque = null,
    embeddings: bool = false,
    offload_kqv: bool = false,
    no_perf: bool = false,
    op_offload: bool = false,
    swa_full: bool = false,
    kv_unified: bool = false,
    samplers: [*c]struct_llama_sampler_seq_config = null,
    n_samplers: usize = 0,
};
pub const struct_llama_model_tensor_override = extern struct {
    pattern: [*c]const u8 = null,
    type: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
};
pub const struct_llama_model_imatrix_data = extern struct {
    name: [*c]const u8 = null,
    data: [*c]const f32 = null,
    size: usize = 0,
};
pub const struct_llama_model_quantize_params = extern struct {
    nthread: i32 = 0,
    ftype: enum_llama_ftype = @import("std").mem.zeroes(enum_llama_ftype),
    output_tensor_type: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
    token_embedding_type: enum_ggml_type = @import("std").mem.zeroes(enum_ggml_type),
    allow_requantize: bool = false,
    quantize_output_tensor: bool = false,
    only_copy: bool = false,
    pure: bool = false,
    keep_split: bool = false,
    dry_run: bool = false,
    imatrix: [*c]const struct_llama_model_imatrix_data = null,
    kv_overrides: [*c]const struct_llama_model_kv_override = null,
    tt_overrides: [*c]const struct_llama_model_tensor_override = null,
    prune_layers: [*c]const i32 = null,
};
pub const llama_model_quantize_params = struct_llama_model_quantize_params;
pub const struct_llama_logit_bias = extern struct {
    token: llama_token = 0,
    bias: f32 = 0,
};
pub const llama_logit_bias = struct_llama_logit_bias;
pub const struct_llama_sampler_chain_params = extern struct {
    no_perf: bool = false,
    pub const llama_sampler_chain_init = __root.llama_sampler_chain_init;
    pub const init = __root.llama_sampler_chain_init;
};
pub const llama_sampler_chain_params = struct_llama_sampler_chain_params;
pub const struct_llama_chat_message = extern struct {
    role: [*c]const u8 = null,
    content: [*c]const u8 = null,
};
pub const llama_chat_message = struct_llama_chat_message;
pub const struct_llama_adapter_lora = opaque {
    pub const llama_adapter_meta_val_str = __root.llama_adapter_meta_val_str;
    pub const llama_adapter_meta_count = __root.llama_adapter_meta_count;
    pub const llama_adapter_meta_key_by_index = __root.llama_adapter_meta_key_by_index;
    pub const llama_adapter_meta_val_str_by_index = __root.llama_adapter_meta_val_str_by_index;
    pub const llama_adapter_lora_free = __root.llama_adapter_lora_free;
    pub const llama_adapter_get_alora_n_invocation_tokens = __root.llama_adapter_get_alora_n_invocation_tokens;
    pub const llama_adapter_get_alora_invocation_tokens = __root.llama_adapter_get_alora_invocation_tokens;
    pub const str = __root.llama_adapter_meta_val_str;
    pub const count = __root.llama_adapter_meta_count;
    pub const index = __root.llama_adapter_meta_key_by_index;
    pub const free = __root.llama_adapter_lora_free;
    pub const tokens = __root.llama_adapter_get_alora_n_invocation_tokens;
};
pub extern fn llama_model_default_params() struct_llama_model_params;
pub extern fn llama_context_default_params() struct_llama_context_params;
pub extern fn llama_sampler_chain_default_params() struct_llama_sampler_chain_params;
pub extern fn llama_model_quantize_default_params() struct_llama_model_quantize_params;
pub extern fn llama_backend_init() void;
pub extern fn llama_backend_free() void;
pub extern fn llama_numa_init(numa: enum_ggml_numa_strategy) void;
pub extern fn llama_attach_threadpool(ctx: ?*struct_llama_context, threadpool: ggml_threadpool_t, threadpool_batch: ggml_threadpool_t) void;
pub extern fn llama_detach_threadpool(ctx: ?*struct_llama_context) void;
pub const llama_model_set_tensor_data_t = ?*const fn (tensor: [*c]struct_ggml_tensor, userdata: ?*anyopaque) callconv(.c) void;
pub extern fn llama_model_init_from_user(metadata: ?*struct_gguf_context, set_tensor_data: llama_model_set_tensor_data_t, set_tensor_data_ud: ?*anyopaque, params: struct_llama_model_params) ?*struct_llama_model;
pub extern fn llama_load_model_from_file(path_model: [*c]const u8, params: struct_llama_model_params) ?*struct_llama_model;
pub extern fn llama_model_load_from_file(path_model: [*c]const u8, params: struct_llama_model_params) ?*struct_llama_model;
pub extern fn llama_model_load_from_file_ptr(file: ?*FILE, params: struct_llama_model_params) ?*struct_llama_model;
pub extern fn llama_model_load_from_splits(paths: [*c][*c]const u8, n_paths: usize, params: struct_llama_model_params) ?*struct_llama_model;
pub extern fn llama_model_save_to_file(model: ?*const struct_llama_model, path_model: [*c]const u8) void;
pub extern fn llama_free_model(model: ?*struct_llama_model) void;
pub extern fn llama_model_free(model: ?*struct_llama_model) void;
pub extern fn llama_init_from_model(model: ?*struct_llama_model, params: struct_llama_context_params) ?*struct_llama_context;
pub extern fn llama_new_context_with_model(model: ?*struct_llama_model, params: struct_llama_context_params) ?*struct_llama_context;
pub extern fn llama_free(ctx: ?*struct_llama_context) void;
pub const LLAMA_PARAMS_FIT_STATUS_SUCCESS: c_int = 0;
pub const LLAMA_PARAMS_FIT_STATUS_FAILURE: c_int = 1;
pub const LLAMA_PARAMS_FIT_STATUS_ERROR: c_int = 2;
pub const enum_llama_params_fit_status = c_uint;
pub extern fn llama_params_fit(path_model: [*c]const u8, mparams: [*c]struct_llama_model_params, cparams: [*c]struct_llama_context_params, tensor_split: [*c]f32, tensor_buft_overrides: [*c]struct_llama_model_tensor_buft_override, margins: [*c]usize, n_ctx_min: u32, log_level: enum_ggml_log_level) enum_llama_params_fit_status;
pub extern fn llama_time_us() i64;
pub extern fn llama_max_devices() usize;
pub extern fn llama_max_parallel_sequences() usize;
pub extern fn llama_max_tensor_buft_overrides() usize;
pub extern fn llama_supports_mmap() bool;
pub extern fn llama_supports_mlock() bool;
pub extern fn llama_supports_gpu_offload() bool;
pub extern fn llama_supports_rpc() bool;
pub extern fn llama_n_ctx(ctx: ?*const struct_llama_context) u32;
pub extern fn llama_n_ctx_seq(ctx: ?*const struct_llama_context) u32;
pub extern fn llama_n_batch(ctx: ?*const struct_llama_context) u32;
pub extern fn llama_n_ubatch(ctx: ?*const struct_llama_context) u32;
pub extern fn llama_n_seq_max(ctx: ?*const struct_llama_context) u32;
pub extern fn llama_n_ctx_train(model: ?*const struct_llama_model) i32;
pub extern fn llama_n_embd(model: ?*const struct_llama_model) i32;
pub extern fn llama_n_layer(model: ?*const struct_llama_model) i32;
pub extern fn llama_n_head(model: ?*const struct_llama_model) i32;
pub extern fn llama_n_vocab(vocab: ?*const struct_llama_vocab) i32;
pub extern fn llama_get_model(ctx: ?*const struct_llama_context) ?*const struct_llama_model;
pub extern fn llama_get_memory(ctx: ?*const struct_llama_context) llama_memory_t;
pub extern fn llama_pooling_type(ctx: ?*const struct_llama_context) enum_llama_pooling_type;
pub extern fn llama_model_get_vocab(model: ?*const struct_llama_model) ?*const struct_llama_vocab;
pub extern fn llama_model_rope_type(model: ?*const struct_llama_model) enum_llama_rope_type;
pub extern fn llama_model_n_ctx_train(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_embd(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_embd_inp(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_embd_out(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_layer(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_head(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_head_kv(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_n_swa(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_rope_freq_scale_train(model: ?*const struct_llama_model) f32;
pub extern fn llama_model_n_cls_out(model: ?*const struct_llama_model) u32;
pub extern fn llama_model_cls_label(model: ?*const struct_llama_model, i: u32) [*c]const u8;
pub extern fn llama_vocab_type(vocab: ?*const struct_llama_vocab) enum_llama_vocab_type;
pub extern fn llama_vocab_n_tokens(vocab: ?*const struct_llama_vocab) i32;
pub extern fn llama_model_meta_val_str(model: ?*const struct_llama_model, key: [*c]const u8, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_model_meta_count(model: ?*const struct_llama_model) i32;
pub extern fn llama_model_meta_key_str(key: enum_llama_model_meta_key) [*c]const u8;
pub extern fn llama_model_meta_key_by_index(model: ?*const struct_llama_model, i: i32, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_model_meta_val_str_by_index(model: ?*const struct_llama_model, i: i32, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_model_desc(model: ?*const struct_llama_model, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_model_size(model: ?*const struct_llama_model) u64;
pub extern fn llama_model_chat_template(model: ?*const struct_llama_model, name: [*c]const u8) [*c]const u8;
pub extern fn llama_model_n_params(model: ?*const struct_llama_model) u64;
pub extern fn llama_model_has_encoder(model: ?*const struct_llama_model) bool;
pub extern fn llama_model_has_decoder(model: ?*const struct_llama_model) bool;
pub extern fn llama_model_decoder_start_token(model: ?*const struct_llama_model) llama_token;
pub extern fn llama_model_is_recurrent(model: ?*const struct_llama_model) bool;
pub extern fn llama_model_is_hybrid(model: ?*const struct_llama_model) bool;
pub extern fn llama_model_is_diffusion(model: ?*const struct_llama_model) bool;
pub extern fn llama_model_quantize(fname_inp: [*c]const u8, fname_out: [*c]const u8, params: [*c]const llama_model_quantize_params) u32;
pub extern fn llama_adapter_lora_init(model: ?*struct_llama_model, path_lora: [*c]const u8) ?*struct_llama_adapter_lora;
pub extern fn llama_adapter_meta_val_str(adapter: ?*const struct_llama_adapter_lora, key: [*c]const u8, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_adapter_meta_count(adapter: ?*const struct_llama_adapter_lora) i32;
pub extern fn llama_adapter_meta_key_by_index(adapter: ?*const struct_llama_adapter_lora, i: i32, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_adapter_meta_val_str_by_index(adapter: ?*const struct_llama_adapter_lora, i: i32, buf: [*c]u8, buf_size: usize) i32;
pub extern fn llama_adapter_lora_free(adapter: ?*struct_llama_adapter_lora) void;
pub extern fn llama_adapter_get_alora_n_invocation_tokens(adapter: ?*const struct_llama_adapter_lora) u64;
pub extern fn llama_adapter_get_alora_invocation_tokens(adapter: ?*const struct_llama_adapter_lora) [*c]const llama_token;
pub extern fn llama_set_adapters_lora(ctx: ?*struct_llama_context, adapters: [*c]?*struct_llama_adapter_lora, n_adapters: usize, scales: [*c]f32) i32;
pub extern fn llama_set_adapter_cvec(ctx: ?*struct_llama_context, data: [*c]const f32, len: usize, n_embd: i32, il_start: i32, il_end: i32) i32;
pub extern fn llama_memory_clear(mem: llama_memory_t, data: bool) void;
pub extern fn llama_memory_seq_rm(mem: llama_memory_t, seq_id: llama_seq_id, p0: llama_pos, p1: llama_pos) bool;
pub extern fn llama_memory_seq_cp(mem: llama_memory_t, seq_id_src: llama_seq_id, seq_id_dst: llama_seq_id, p0: llama_pos, p1: llama_pos) void;
pub extern fn llama_memory_seq_keep(mem: llama_memory_t, seq_id: llama_seq_id) void;
pub extern fn llama_memory_seq_add(mem: llama_memory_t, seq_id: llama_seq_id, p0: llama_pos, p1: llama_pos, delta: llama_pos) void;
pub extern fn llama_memory_seq_div(mem: llama_memory_t, seq_id: llama_seq_id, p0: llama_pos, p1: llama_pos, d: c_int) void;
pub extern fn llama_memory_seq_pos_min(mem: llama_memory_t, seq_id: llama_seq_id) llama_pos;
pub extern fn llama_memory_seq_pos_max(mem: llama_memory_t, seq_id: llama_seq_id) llama_pos;
pub extern fn llama_memory_can_shift(mem: llama_memory_t) bool;
pub extern fn llama_state_get_size(ctx: ?*struct_llama_context) usize;
pub extern fn llama_get_state_size(ctx: ?*struct_llama_context) usize;
pub extern fn llama_state_get_data(ctx: ?*struct_llama_context, dst: [*c]u8, size: usize) usize;
pub extern fn llama_copy_state_data(ctx: ?*struct_llama_context, dst: [*c]u8) usize;
pub extern fn llama_state_set_data(ctx: ?*struct_llama_context, src: [*c]const u8, size: usize) usize;
pub extern fn llama_set_state_data(ctx: ?*struct_llama_context, src: [*c]const u8) usize;
pub extern fn llama_state_load_file(ctx: ?*struct_llama_context, path_session: [*c]const u8, tokens_out: [*c]llama_token, n_token_capacity: usize, n_token_count_out: [*c]usize) bool;
pub extern fn llama_load_session_file(ctx: ?*struct_llama_context, path_session: [*c]const u8, tokens_out: [*c]llama_token, n_token_capacity: usize, n_token_count_out: [*c]usize) bool;
pub extern fn llama_state_save_file(ctx: ?*struct_llama_context, path_session: [*c]const u8, tokens: [*c]const llama_token, n_token_count: usize) bool;
pub extern fn llama_save_session_file(ctx: ?*struct_llama_context, path_session: [*c]const u8, tokens: [*c]const llama_token, n_token_count: usize) bool;
pub extern fn llama_state_seq_get_size(ctx: ?*struct_llama_context, seq_id: llama_seq_id) usize;
pub extern fn llama_state_seq_get_data(ctx: ?*struct_llama_context, dst: [*c]u8, size: usize, seq_id: llama_seq_id) usize;
pub extern fn llama_state_seq_set_data(ctx: ?*struct_llama_context, src: [*c]const u8, size: usize, dest_seq_id: llama_seq_id) usize;
pub extern fn llama_state_seq_save_file(ctx: ?*struct_llama_context, filepath: [*c]const u8, seq_id: llama_seq_id, tokens: [*c]const llama_token, n_token_count: usize) usize;
pub extern fn llama_state_seq_load_file(ctx: ?*struct_llama_context, filepath: [*c]const u8, dest_seq_id: llama_seq_id, tokens_out: [*c]llama_token, n_token_capacity: usize, n_token_count_out: [*c]usize) usize;
pub const llama_state_seq_flags = u32;
pub extern fn llama_state_seq_get_size_ext(ctx: ?*struct_llama_context, seq_id: llama_seq_id, flags: llama_state_seq_flags) usize;
pub extern fn llama_state_seq_get_data_ext(ctx: ?*struct_llama_context, dst: [*c]u8, size: usize, seq_id: llama_seq_id, flags: llama_state_seq_flags) usize;
pub extern fn llama_state_seq_set_data_ext(ctx: ?*struct_llama_context, src: [*c]const u8, size: usize, dest_seq_id: llama_seq_id, flags: llama_state_seq_flags) usize;
pub extern fn llama_batch_get_one(tokens: [*c]llama_token, n_tokens: i32) struct_llama_batch;
pub extern fn llama_batch_init(n_tokens: i32, embd: i32, n_seq_max: i32) struct_llama_batch;
pub extern fn llama_batch_free(batch: struct_llama_batch) void;
pub extern fn llama_encode(ctx: ?*struct_llama_context, batch: struct_llama_batch) i32;
pub extern fn llama_decode(ctx: ?*struct_llama_context, batch: struct_llama_batch) i32;
pub extern fn llama_set_n_threads(ctx: ?*struct_llama_context, n_threads: i32, n_threads_batch: i32) void;
pub extern fn llama_n_threads(ctx: ?*struct_llama_context) i32;
pub extern fn llama_n_threads_batch(ctx: ?*struct_llama_context) i32;
pub extern fn llama_set_embeddings(ctx: ?*struct_llama_context, embeddings: bool) void;
pub extern fn llama_set_causal_attn(ctx: ?*struct_llama_context, causal_attn: bool) void;
pub extern fn llama_set_warmup(ctx: ?*struct_llama_context, warmup: bool) void;
pub extern fn llama_set_abort_callback(ctx: ?*struct_llama_context, abort_callback: ggml_abort_callback, abort_callback_data: ?*anyopaque) void;
pub extern fn llama_synchronize(ctx: ?*struct_llama_context) void;
pub extern fn llama_get_logits(ctx: ?*struct_llama_context) [*c]f32;
pub extern fn llama_get_logits_ith(ctx: ?*struct_llama_context, i: i32) [*c]f32;
pub extern fn llama_get_embeddings(ctx: ?*struct_llama_context) [*c]f32;
pub extern fn llama_get_embeddings_ith(ctx: ?*struct_llama_context, i: i32) [*c]f32;
pub extern fn llama_get_embeddings_seq(ctx: ?*struct_llama_context, seq_id: llama_seq_id) [*c]f32;
pub extern fn llama_get_sampled_token_ith(ctx: ?*struct_llama_context, i: i32) llama_token;
pub extern fn llama_get_sampled_probs_ith(ctx: ?*struct_llama_context, i: i32) [*c]f32;
pub extern fn llama_get_sampled_probs_count_ith(ctx: ?*struct_llama_context, i: i32) u32;
pub extern fn llama_get_sampled_logits_ith(ctx: ?*struct_llama_context, i: i32) [*c]f32;
pub extern fn llama_get_sampled_logits_count_ith(ctx: ?*struct_llama_context, i: i32) u32;
pub extern fn llama_get_sampled_candidates_ith(ctx: ?*struct_llama_context, i: i32) [*c]llama_token;
pub extern fn llama_get_sampled_candidates_count_ith(ctx: ?*struct_llama_context, i: i32) u32;
pub extern fn llama_vocab_get_text(vocab: ?*const struct_llama_vocab, token: llama_token) [*c]const u8;
pub extern fn llama_vocab_get_score(vocab: ?*const struct_llama_vocab, token: llama_token) f32;
pub extern fn llama_vocab_get_attr(vocab: ?*const struct_llama_vocab, token: llama_token) enum_llama_token_attr;
pub extern fn llama_vocab_is_eog(vocab: ?*const struct_llama_vocab, token: llama_token) bool;
pub extern fn llama_vocab_is_control(vocab: ?*const struct_llama_vocab, token: llama_token) bool;
pub extern fn llama_vocab_bos(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_eos(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_eot(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_sep(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_nl(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_pad(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_mask(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_get_add_bos(vocab: ?*const struct_llama_vocab) bool;
pub extern fn llama_vocab_get_add_eos(vocab: ?*const struct_llama_vocab) bool;
pub extern fn llama_vocab_get_add_sep(vocab: ?*const struct_llama_vocab) bool;
pub extern fn llama_vocab_fim_pre(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_fim_suf(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_fim_mid(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_fim_pad(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_fim_rep(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_fim_sep(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_get_text(vocab: ?*const struct_llama_vocab, token: llama_token) [*c]const u8;
pub extern fn llama_token_get_score(vocab: ?*const struct_llama_vocab, token: llama_token) f32;
pub extern fn llama_token_get_attr(vocab: ?*const struct_llama_vocab, token: llama_token) enum_llama_token_attr;
pub extern fn llama_token_is_eog(vocab: ?*const struct_llama_vocab, token: llama_token) bool;
pub extern fn llama_token_is_control(vocab: ?*const struct_llama_vocab, token: llama_token) bool;
pub extern fn llama_token_bos(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_eos(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_eot(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_cls(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_sep(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_nl(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_pad(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_add_bos_token(vocab: ?*const struct_llama_vocab) bool;
pub extern fn llama_add_eos_token(vocab: ?*const struct_llama_vocab) bool;
pub extern fn llama_token_fim_pre(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_fim_suf(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_fim_mid(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_fim_pad(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_fim_rep(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_token_fim_sep(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_vocab_cls(vocab: ?*const struct_llama_vocab) llama_token;
pub extern fn llama_tokenize(vocab: ?*const struct_llama_vocab, text: [*c]const u8, text_len: i32, tokens: [*c]llama_token, n_tokens_max: i32, add_special: bool, parse_special: bool) i32;
pub extern fn llama_token_to_piece(vocab: ?*const struct_llama_vocab, token: llama_token, buf: [*c]u8, length: i32, lstrip: i32, special: bool) i32;
pub extern fn llama_detokenize(vocab: ?*const struct_llama_vocab, tokens: [*c]const llama_token, n_tokens: i32, text: [*c]u8, text_len_max: i32, remove_special: bool, unparse_special: bool) i32;
pub extern fn llama_chat_apply_template(tmpl: [*c]const u8, chat: [*c]const struct_llama_chat_message, n_msg: usize, add_ass: bool, buf: [*c]u8, length: i32) i32;
pub extern fn llama_chat_builtin_templates(output: [*c][*c]const u8, len: usize) i32;
pub extern fn llama_set_sampler(ctx: ?*struct_llama_context, seq_id: llama_seq_id, smpl: [*c]struct_llama_sampler) bool;
pub extern fn llama_sampler_init(iface: [*c]struct_llama_sampler_i, ctx: llama_sampler_context_t) [*c]struct_llama_sampler;
pub extern fn llama_sampler_name(smpl: [*c]const struct_llama_sampler) [*c]const u8;
pub extern fn llama_sampler_accept(smpl: [*c]struct_llama_sampler, token: llama_token) void;
pub extern fn llama_sampler_apply(smpl: [*c]struct_llama_sampler, cur_p: [*c]llama_token_data_array) void;
pub extern fn llama_sampler_reset(smpl: [*c]struct_llama_sampler) void;
pub extern fn llama_sampler_clone(smpl: [*c]const struct_llama_sampler) [*c]struct_llama_sampler;
pub extern fn llama_sampler_free(smpl: [*c]struct_llama_sampler) void;
pub extern fn llama_sampler_chain_init(params: struct_llama_sampler_chain_params) [*c]struct_llama_sampler;
pub extern fn llama_sampler_chain_add(chain: [*c]struct_llama_sampler, smpl: [*c]struct_llama_sampler) void;
pub extern fn llama_sampler_chain_get(chain: [*c]struct_llama_sampler, i: i32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_chain_n(chain: [*c]const struct_llama_sampler) c_int;
pub extern fn llama_sampler_chain_remove(chain: [*c]struct_llama_sampler, i: i32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_greedy() [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_dist(seed: u32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_top_k(k: i32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_top_p(p: f32, min_keep: usize) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_min_p(p: f32, min_keep: usize) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_typical(p: f32, min_keep: usize) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_temp(t: f32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_temp_ext(t: f32, delta: f32, exponent: f32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_xtc(p: f32, t: f32, min_keep: usize, seed: u32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_top_n_sigma(n: f32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_mirostat(n_vocab: i32, seed: u32, tau: f32, eta: f32, m: i32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_mirostat_v2(seed: u32, tau: f32, eta: f32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_grammar(vocab: ?*const struct_llama_vocab, grammar_str: [*c]const u8, grammar_root: [*c]const u8) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_grammar_lazy(vocab: ?*const struct_llama_vocab, grammar_str: [*c]const u8, grammar_root: [*c]const u8, trigger_words: [*c][*c]const u8, num_trigger_words: usize, trigger_tokens: [*c]const llama_token, num_trigger_tokens: usize) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_grammar_lazy_patterns(vocab: ?*const struct_llama_vocab, grammar_str: [*c]const u8, grammar_root: [*c]const u8, trigger_patterns: [*c][*c]const u8, num_trigger_patterns: usize, trigger_tokens: [*c]const llama_token, num_trigger_tokens: usize) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_penalties(penalty_last_n: i32, penalty_repeat: f32, penalty_freq: f32, penalty_present: f32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_dry(vocab: ?*const struct_llama_vocab, n_ctx_train: i32, dry_multiplier: f32, dry_base: f32, dry_allowed_length: i32, dry_penalty_last_n: i32, seq_breakers: [*c][*c]const u8, num_breakers: usize) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_adaptive_p(target: f32, decay: f32, seed: u32) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_logit_bias(n_vocab: i32, n_logit_bias: i32, logit_bias: [*c]const llama_logit_bias) [*c]struct_llama_sampler;
pub extern fn llama_sampler_init_infill(vocab: ?*const struct_llama_vocab) [*c]struct_llama_sampler;
pub extern fn llama_sampler_get_seed(smpl: [*c]const struct_llama_sampler) u32;
pub extern fn llama_sampler_sample(smpl: [*c]struct_llama_sampler, ctx: ?*struct_llama_context, idx: i32) llama_token;
pub extern fn llama_split_path(split_path: [*c]u8, maxlen: usize, path_prefix: [*c]const u8, split_no: i32, split_count: i32) i32;
pub extern fn llama_split_prefix(split_prefix: [*c]u8, maxlen: usize, split_path: [*c]const u8, split_no: i32, split_count: i32) i32;
pub extern fn llama_print_system_info() [*c]const u8;
pub extern fn llama_log_get(log_callback: [*c]ggml_log_callback, user_data: [*c]?*anyopaque) void;
pub extern fn llama_log_set(log_callback: ggml_log_callback, user_data: ?*anyopaque) void;
pub const struct_llama_perf_context_data = extern struct {
    t_start_ms: f64 = 0,
    t_load_ms: f64 = 0,
    t_p_eval_ms: f64 = 0,
    t_eval_ms: f64 = 0,
    n_p_eval: i32 = 0,
    n_eval: i32 = 0,
    n_reused: i32 = 0,
};
pub const struct_llama_perf_sampler_data = extern struct {
    t_sample_ms: f64 = 0,
    n_sample: i32 = 0,
};
pub extern fn llama_perf_context(ctx: ?*const struct_llama_context) struct_llama_perf_context_data;
pub extern fn llama_perf_context_print(ctx: ?*const struct_llama_context) void;
pub extern fn llama_perf_context_reset(ctx: ?*struct_llama_context) void;
pub extern fn llama_perf_sampler(chain: [*c]const struct_llama_sampler) struct_llama_perf_sampler_data;
pub extern fn llama_perf_sampler_print(chain: [*c]const struct_llama_sampler) void;
pub extern fn llama_perf_sampler_reset(chain: [*c]struct_llama_sampler) void;
pub extern fn llama_memory_breakdown_print(ctx: ?*const struct_llama_context) void;
pub const llama_opt_param_filter = ?*const fn (tensor: [*c]const struct_ggml_tensor, userdata: ?*anyopaque) callconv(.c) bool;
pub extern fn llama_opt_param_filter_all(tensor: [*c]const struct_ggml_tensor, userdata: ?*anyopaque) bool;
pub const struct_llama_opt_params = extern struct {
    n_ctx_train: u32 = 0,
    param_filter: llama_opt_param_filter = null,
    param_filter_ud: ?*anyopaque = null,
    get_opt_pars: ggml_opt_get_optimizer_params = null,
    get_opt_pars_ud: ?*anyopaque = null,
    optimizer_type: enum_ggml_opt_optimizer_type = @import("std").mem.zeroes(enum_ggml_opt_optimizer_type),
};
pub extern fn llama_opt_init(lctx: ?*struct_llama_context, model: ?*struct_llama_model, lopt_params: struct_llama_opt_params) void;
pub extern fn llama_opt_epoch(lctx: ?*struct_llama_context, dataset: ggml_opt_dataset_t, result_train: ggml_opt_result_t, result_eval: ggml_opt_result_t, idata_split: i64, callback_train: ggml_opt_epoch_callback, callback_eval: ggml_opt_epoch_callback) void;

pub const __VERSION__ = "Aro aro-zig";
pub const __Aro__ = "";
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __GNUC__ = @as(c_int, 7);
pub const __GNUC_MINOR__ = @as(c_int, 1);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 0);
pub const __ARO_EMULATE_NO__ = @as(c_int, 0);
pub const __ARO_EMULATE_CLANG__ = @as(c_int, 1);
pub const __ARO_EMULATE_GCC__ = @as(c_int, 2);
pub const __ARO_EMULATE_MSVC__ = @as(c_int, 3);
pub const __ARO_EMULATE__ = __ARO_EMULATE_GCC__;
pub inline fn __building_module(x: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &x;
    return @as(c_int, 0);
}
pub const linux = @as(c_int, 1);
pub const __linux = @as(c_int, 1);
pub const __linux__ = @as(c_int, 1);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:33:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:34:9
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __VAES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __VPCLMULQDQ__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MWAITX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __SSE4A__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __GFNI__ = @as(c_int, 1);
pub const __EVEX512__ = @as(c_int, 1);
pub const __AVX512CD__ = @as(c_int, 1);
pub const __AVX512VPOPCNTDQ__ = @as(c_int, 1);
pub const __AVX512VNNI__ = @as(c_int, 1);
pub const __AVX512BF16__ = @as(c_int, 1);
pub const __AVX512DQ__ = @as(c_int, 1);
pub const __AVX512BITALG__ = @as(c_int, 1);
pub const __AVX512BW__ = @as(c_int, 1);
pub const __AVX512VL__ = @as(c_int, 1);
pub const __EVEX256__ = @as(c_int, 1);
pub const __AVX512VBMI__ = @as(c_int, 1);
pub const __AVX512VBMI2__ = @as(c_int, 1);
pub const __AVX512IFMA__ = @as(c_int, 1);
pub const __SHA__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __PKU__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __CLWB__ = @as(c_int, 1);
pub const __WBNOINVD__ = @as(c_int, 1);
pub const __SHSTK__ = @as(c_int, 1);
pub const __CLZERO__ = @as(c_int, 1);
pub const __RDPID__ = @as(c_int, 1);
pub const __RDPRU__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __CRC32__ = @as(c_int, 1);
pub const __AVX512F__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __ELF__ = @as(c_int, 1);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __ATOMIC_BOOL_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WINT_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_SHORT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_INT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LLONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_POINTER_LOCK_FREE = @as(c_int, 1);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SCHAR_WIDTH__ = @as(c_int, 8);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __LONG_LONG_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIG_ATOMIC_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __BITINT_MAXWIDTH__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 10);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTPTR_TYPE__ = c_long;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // <builtin>:172:9
pub const __INTMAX_C = __helpers.L_SUFFIX;
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // <builtin>:175:9
pub const __UINTMAX_C = __helpers.UL_SUFFIX;
pub const __PTRDIFF_TYPE__ = c_long;
pub const __SIZE_TYPE__ = c_ulong;
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_uint;
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // <builtin>:201:9
pub const __INT64_C = __helpers.L_SUFFIX;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub inline fn __UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // <builtin>:226:9
pub const __UINT32_C = __helpers.U_SUFFIX;
pub const __UINT32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // <builtin>:235:9
pub const __UINT64_C = __helpers.UL_SUFFIX;
pub const __UINT64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const INT_LEAST8_FMTd__ = "hhd";
pub const INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const UINT_LEAST8_FMTo__ = "hho";
pub const UINT_LEAST8_FMTu__ = "hhu";
pub const UINT_LEAST8_FMTx__ = "hhx";
pub const UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const INT_FAST8_FMTd__ = "hhd";
pub const INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const UINT_FAST8_FMTo__ = "hho";
pub const UINT_FAST8_FMTu__ = "hhu";
pub const UINT_FAST8_FMTx__ = "hhx";
pub const UINT_FAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const INT_LEAST16_FMTd__ = "hd";
pub const INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST16_FMTo__ = "ho";
pub const UINT_LEAST16_FMTu__ = "hu";
pub const UINT_LEAST16_FMTx__ = "hx";
pub const UINT_LEAST16_FMTX__ = "hX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const INT_FAST16_FMTd__ = "hd";
pub const INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_FAST16_FMTo__ = "ho";
pub const UINT_FAST16_FMTu__ = "hu";
pub const UINT_FAST16_FMTx__ = "hx";
pub const UINT_FAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const INT_LEAST32_FMTd__ = "d";
pub const INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST32_FMTo__ = "o";
pub const UINT_LEAST32_FMTu__ = "u";
pub const UINT_LEAST32_FMTx__ = "x";
pub const UINT_LEAST32_FMTX__ = "X";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const INT_FAST32_FMTd__ = "d";
pub const INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_FAST32_FMTo__ = "o";
pub const UINT_FAST32_FMTu__ = "u";
pub const UINT_FAST32_FMTx__ = "x";
pub const UINT_FAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const INT_LEAST64_FMTd__ = "ld";
pub const INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_LEAST64_FMTo__ = "lo";
pub const UINT_LEAST64_FMTu__ = "lu";
pub const UINT_LEAST64_FMTx__ = "lx";
pub const UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const INT_FAST64_FMTd__ = "ld";
pub const INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_FMTo__ = "lo";
pub const UINT_FAST64_FMTu__ = "lu";
pub const UINT_FAST64_FMTx__ = "lx";
pub const UINT_FAST64_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_HAS_DENORM__ = "";
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = "";
pub const __FLT16_HAS_QUIET_NAN__ = "";
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = "";
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = "";
pub const __FLT_HAS_QUIET_NAN__ = "";
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = "";
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = "";
pub const __DBL_HAS_QUIET_NAN__ = "";
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = "";
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = "";
pub const __LDBL_HAS_QUIET_NAN__ = "";
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __pic__ = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __GLIBC_MINOR__ = @as(c_int, 42);
pub const LLAMA_H = "";
pub const GGML_API = @compileError("unable to translate C expr: unexpected token 'extern'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:187:13
pub const GGML_DEPRECATED = @compileError("unable to translate macro: undefined identifier `deprecated`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:192:13
pub const GGML_ATTRIBUTE_FORMAT = @compileError("unable to translate macro: undefined identifier `format`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:204:13
pub const @"bool" = bool;
pub const @"true" = @as(c_int, 1);
pub const @"false" = @as(c_int, 0);
pub const __bool_true_false_are_defined = @as(c_int, 1);
pub const __STDC_VERSION_STDDEF_H__ = @as(c_long, 202311);
pub const NULL = __helpers.cast(?*anyopaque, @as(c_int, 0));
pub const offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // /home/emo/Downloads/zig-x86_64-linux-0.16.0/lib/compiler/aro/include/stddef.h:18:9
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H = @as(c_int, 1);
pub const _FEATURES_H = @as(c_int, 1);
pub const __KERNEL_STRICT_NAMES = "";
pub inline fn __GNUC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub inline fn __glibc_clang_prereq(maj: anytype, min: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &maj;
    _ = &min;
    return @as(c_int, 0);
}
pub const __GLIBC_USE = @compileError("unable to translate macro: undefined identifier `__GLIBC_USE_`"); // /usr/include/features.h:191:9
pub const _DEFAULT_SOURCE = @as(c_int, 1);
pub const __GLIBC_USE_ISOC2Y = @as(c_int, 0);
pub const __GLIBC_USE_ISOC23 = @as(c_int, 0);
pub const __USE_ISOC11 = @as(c_int, 1);
pub const __USE_POSIX_IMPLICITLY = @as(c_int, 1);
pub const _POSIX_SOURCE = @as(c_int, 1);
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __USE_POSIX = @as(c_int, 1);
pub const __USE_POSIX2 = @as(c_int, 1);
pub const __USE_POSIX199309 = @as(c_int, 1);
pub const __USE_POSIX199506 = @as(c_int, 1);
pub const __USE_XOPEN2K = @as(c_int, 1);
pub const __USE_ISOC95 = @as(c_int, 1);
pub const __USE_ISOC99 = @as(c_int, 1);
pub const __USE_XOPEN2K8 = @as(c_int, 1);
pub const _ATFILE_SOURCE = @as(c_int, 1);
pub const __WORDSIZE = @as(c_int, 64);
pub const __WORDSIZE_TIME64_COMPAT32 = @as(c_int, 1);
pub const __SYSCALL_WORDSIZE = @as(c_int, 64);
pub const __TIMESIZE = __WORDSIZE;
pub const __USE_TIME_BITS64 = @as(c_int, 1);
pub const __USE_MISC = @as(c_int, 1);
pub const __USE_ATFILE = @as(c_int, 1);
pub const __USE_FORTIFY_LEVEL = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_GETS = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_SCANF = @as(c_int, 0);
pub const __GLIBC_USE_C23_STRTOL = @as(c_int, 0);
pub const _STDC_PREDEF_H = @as(c_int, 1);
pub const __STDC_IEC_559__ = @as(c_int, 1);
pub const __STDC_IEC_60559_BFP__ = @as(c_long, 201404);
pub const __STDC_IEC_559_COMPLEX__ = @as(c_int, 1);
pub const __STDC_IEC_60559_COMPLEX__ = @as(c_long, 201404);
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const __GNU_LIBRARY__ = @as(c_int, 6);
pub const __GLIBC__ = @as(c_int, 2);
pub inline fn __GLIBC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub const _SYS_CDEFS_H = @as(c_int, 1);
pub const __glibc_has_attribute = @compileError("unable to translate macro: undefined identifier `__has_attribute`"); // /usr/include/sys/cdefs.h:45:10
pub inline fn __glibc_has_builtin(name: anytype) @TypeOf(__builtin.has_builtin(name)) {
    _ = &name;
    return __builtin.has_builtin(name);
}
pub const __glibc_has_extension = @compileError("unable to translate macro: undefined identifier `__has_extension`"); // /usr/include/sys/cdefs.h:55:10
pub const __LEAF = @compileError("unable to translate macro: undefined identifier `__leaf__`"); // /usr/include/sys/cdefs.h:65:11
pub const __LEAF_ATTR = @compileError("unable to translate macro: undefined identifier `__leaf__`"); // /usr/include/sys/cdefs.h:66:11
pub const __THROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:79:11
pub const __THROWNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:80:11
pub const __NTH = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:81:11
pub const __NTHNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:82:11
pub const __COLD = @compileError("unable to translate macro: undefined identifier `__cold__`"); // /usr/include/sys/cdefs.h:102:11
pub inline fn __P(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub inline fn __PMT(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token '##'"); // /usr/include/sys/cdefs.h:131:9
pub const __STRING = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:132:9
pub const __ptr_t = ?*anyopaque;
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub const __attribute_overloadable__ = "";
pub inline fn __bos(ptr: anytype) @TypeOf(__builtin.object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1))) {
    _ = &ptr;
    return __builtin.object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1));
}
pub inline fn __bos0(ptr: anytype) @TypeOf(__builtin.object_size(ptr, @as(c_int, 0))) {
    _ = &ptr;
    return __builtin.object_size(ptr, @as(c_int, 0));
}
pub inline fn __glibc_objsize0(__o: anytype) @TypeOf(__bos0(__o)) {
    _ = &__o;
    return __bos0(__o);
}
pub inline fn __glibc_objsize(__o: anytype) @TypeOf(__bos(__o)) {
    _ = &__o;
    return __bos(__o);
}
pub const __warnattr = @compileError("unable to translate macro: undefined identifier `__warning__`"); // /usr/include/sys/cdefs.h:366:10
pub const __errordecl = @compileError("unable to translate macro: undefined identifier `__error__`"); // /usr/include/sys/cdefs.h:367:10
pub const __flexarr = @compileError("unable to translate C expr: unexpected token '['"); // /usr/include/sys/cdefs.h:379:10
pub const __glibc_c99_flexarr_available = @as(c_int, 1);
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:410:10
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:417:11
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:419:11
pub const __ASMNAME = @compileError("unable to translate macro: undefined identifier `__USER_LABEL_PREFIX__`"); // /usr/include/sys/cdefs.h:422:10
pub inline fn __ASMNAME2(prefix: anytype, cname: anytype) @TypeOf(__STRING(prefix) ++ cname) {
    _ = &prefix;
    _ = &cname;
    return __STRING(prefix) ++ cname;
}
pub const __REDIRECT_FORTIFY = __REDIRECT;
pub const __REDIRECT_FORTIFY_NTH = __REDIRECT_NTH;
pub const __attribute_malloc__ = @compileError("unable to translate macro: undefined identifier `__malloc__`"); // /usr/include/sys/cdefs.h:452:10
pub const __attribute_alloc_size__ = @compileError("unable to translate macro: undefined identifier `__alloc_size__`"); // /usr/include/sys/cdefs.h:460:10
pub const __attribute_alloc_align__ = @compileError("unable to translate macro: undefined identifier `__alloc_align__`"); // /usr/include/sys/cdefs.h:469:10
pub const __attribute_pure__ = @compileError("unable to translate macro: undefined identifier `__pure__`"); // /usr/include/sys/cdefs.h:479:10
pub const __attribute_const__ = @compileError("unable to translate C expr: unexpected token '__attribute__'"); // /usr/include/sys/cdefs.h:486:10
pub const __attribute_maybe_unused__ = @compileError("unable to translate macro: undefined identifier `__unused__`"); // /usr/include/sys/cdefs.h:492:10
pub const __attribute_used__ = @compileError("unable to translate macro: undefined identifier `__used__`"); // /usr/include/sys/cdefs.h:501:10
pub const __attribute_noinline__ = @compileError("unable to translate macro: undefined identifier `__noinline__`"); // /usr/include/sys/cdefs.h:502:10
pub const __attribute_deprecated__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // /usr/include/sys/cdefs.h:510:10
pub const __attribute_deprecated_msg__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // /usr/include/sys/cdefs.h:520:10
pub const __attribute_format_arg__ = @compileError("unable to translate macro: undefined identifier `__format_arg__`"); // /usr/include/sys/cdefs.h:533:10
pub const __attribute_format_strfmon__ = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:543:10
pub const __attribute_nonnull__ = @compileError("unable to translate macro: undefined identifier `__nonnull__`"); // /usr/include/sys/cdefs.h:555:11
pub inline fn __nonnull(params: anytype) @TypeOf(__attribute_nonnull__(params)) {
    _ = &params;
    return __attribute_nonnull__(params);
}
pub const __returns_nonnull = @compileError("unable to translate macro: undefined identifier `__returns_nonnull__`"); // /usr/include/sys/cdefs.h:568:10
pub const __attribute_warn_unused_result__ = @compileError("unable to translate macro: undefined identifier `__warn_unused_result__`"); // /usr/include/sys/cdefs.h:577:10
pub const __wur = "";
pub const __always_inline = @compileError("unable to translate macro: undefined identifier `__always_inline__`"); // /usr/include/sys/cdefs.h:595:10
pub const __attribute_artificial__ = @compileError("unable to translate macro: undefined identifier `__artificial__`"); // /usr/include/sys/cdefs.h:604:10
pub const __extern_inline = @compileError("unable to translate C expr: unexpected token 'extern'"); // /usr/include/sys/cdefs.h:626:11
pub const __extern_always_inline = @compileError("unable to translate C expr: unexpected token 'extern'"); // /usr/include/sys/cdefs.h:627:11
pub const __fortify_function = __extern_always_inline ++ __attribute_artificial__;
pub const __va_arg_pack = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg_pack`"); // /usr/include/sys/cdefs.h:638:10
pub const __va_arg_pack_len = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg_pack_len`"); // /usr/include/sys/cdefs.h:639:10
pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'"); // /usr/include/sys/cdefs.h:666:10
pub inline fn __glibc_unlikely(cond: anytype) @TypeOf(__builtin.expect(cond, @as(c_int, 0))) {
    _ = &cond;
    return __builtin.expect(cond, @as(c_int, 0));
}
pub inline fn __glibc_likely(cond: anytype) @TypeOf(__builtin.expect(cond, @as(c_int, 1))) {
    _ = &cond;
    return __builtin.expect(cond, @as(c_int, 1));
}
pub const __attribute_nonstring__ = "";
pub inline fn __attribute_copy__(arg: anytype) void {
    _ = &arg;
    return;
}
pub const __LDOUBLE_REDIRECTS_TO_FLOAT128_ABI = @as(c_int, 0);
pub inline fn __LDBL_REDIR1(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR(name: anytype, proto: anytype) @TypeOf(name ++ proto) {
    _ = &name;
    _ = &proto;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR1_NTH(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return name ++ proto ++ __THROW;
}
pub inline fn __LDBL_REDIR_NTH(name: anytype, proto: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = &name;
    _ = &proto;
    return name ++ proto ++ __THROW;
}
pub inline fn __LDBL_REDIR2_DECL(name: anytype) void {
    _ = &name;
    return;
}
pub inline fn __LDBL_REDIR_DECL(name: anytype) void {
    _ = &name;
    return;
}
pub inline fn __REDIRECT_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT(name, proto, alias);
}
pub inline fn __REDIRECT_NTH_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT_NTH(name, proto, alias);
}
pub const __glibc_macro_warning1 = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /usr/include/sys/cdefs.h:807:10
pub const __glibc_macro_warning = @compileError("unable to translate macro: undefined identifier `GCC`"); // /usr/include/sys/cdefs.h:808:10
pub const __HAVE_GENERIC_SELECTION = @as(c_int, 1);
pub inline fn __fortified_attr_access(a: anytype, o: anytype, s: anytype) void {
    _ = &a;
    _ = &o;
    _ = &s;
    return;
}
pub inline fn __attr_access(x: anytype) void {
    _ = &x;
    return;
}
pub inline fn __attr_access_none(argno: anytype) void {
    _ = &argno;
    return;
}
pub inline fn __attr_dealloc(dealloc: anytype, argno: anytype) void {
    _ = &dealloc;
    _ = &argno;
    return;
}
pub const __attr_dealloc_free = "";
pub const __attribute_returns_twice__ = @compileError("unable to translate macro: undefined identifier `__returns_twice__`"); // /usr/include/sys/cdefs.h:872:10
pub const __attribute_struct_may_alias__ = @compileError("unable to translate macro: undefined identifier `__may_alias__`"); // /usr/include/sys/cdefs.h:881:10
pub const __stub___compat_bdflush = "";
pub const __stub_chflags = "";
pub const __stub_fchflags = "";
pub const __stub_gtty = "";
pub const __stub_revoke = "";
pub const __stub_setlogin = "";
pub const __stub_sigreturn = "";
pub const __stub_stty = "";
pub const _BITS_TYPES_H = @as(c_int, 1);
pub const __S16_TYPE = c_short;
pub const __U16_TYPE = c_ushort;
pub const __S32_TYPE = c_int;
pub const __U32_TYPE = c_uint;
pub const __SLONGWORD_TYPE = c_long;
pub const __ULONGWORD_TYPE = c_ulong;
pub const __SQUAD_TYPE = c_long;
pub const __UQUAD_TYPE = c_ulong;
pub const __SWORD_TYPE = c_long;
pub const __UWORD_TYPE = c_ulong;
pub const __SLONG32_TYPE = c_int;
pub const __ULONG32_TYPE = c_uint;
pub const __S64_TYPE = c_long;
pub const __U64_TYPE = c_ulong;
pub const _BITS_TYPESIZES_H = @as(c_int, 1);
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __GID_T_TYPE = __U32_TYPE;
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const __PID_T_TYPE = __S32_TYPE;
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __SUSECONDS64_T_TYPE = __SQUAD_TYPE;
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __TIMER_T_TYPE = ?*anyopaque;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __FSID_T_TYPE = @compileError("unable to translate macro: undefined identifier `__val`"); // /usr/include/bits/typesizes.h:73:9
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __OFF_T_MATCHES_OFF64_T = @as(c_int, 1);
pub const __INO_T_MATCHES_INO64_T = @as(c_int, 1);
pub const __RLIM_T_MATCHES_RLIM64_T = @as(c_int, 1);
pub const __STATFS_MATCHES_STATFS64 = @as(c_int, 1);
pub const __KERNEL_OLD_TIMEVAL_MATCHES_TIMEVAL64 = @as(c_int, 1);
pub const __FD_SETSIZE = @as(c_int, 1024);
pub const _BITS_TIME64_H = @as(c_int, 1);
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub const _BITS_WCHAR_H = @as(c_int, 1);
pub const __WCHAR_MAX = __WCHAR_MAX__;
pub const __WCHAR_MIN = -__WCHAR_MAX - @as(c_int, 1);
pub const _BITS_STDINT_INTN_H = @as(c_int, 1);
pub const _BITS_STDINT_UINTN_H = @as(c_int, 1);
pub const _BITS_STDINT_LEAST_H = @as(c_int, 1);
pub const __intptr_t_defined = "";
pub const INT8_MIN = -@as(c_int, 128);
pub const INT16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const INT32_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT64_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT8_MAX = @as(c_int, 127);
pub const INT16_MAX = @as(c_int, 32767);
pub const INT32_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT64_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT8_MAX = @as(c_int, 255);
pub const UINT16_MAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT32_MAX = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT64_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INT_LEAST8_MIN = -@as(c_int, 128);
pub const INT_LEAST16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const INT_LEAST32_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT_LEAST64_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT_LEAST8_MAX = @as(c_int, 127);
pub const INT_LEAST16_MAX = @as(c_int, 32767);
pub const INT_LEAST32_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT_LEAST64_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT_LEAST8_MAX = @as(c_int, 255);
pub const UINT_LEAST16_MAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST32_MAX = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST64_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INT_FAST8_MIN = -@as(c_int, 128);
pub const INT_FAST16_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INT_FAST32_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INT_FAST64_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT_FAST8_MAX = @as(c_int, 127);
pub const INT_FAST16_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INT_FAST32_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INT_FAST64_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT_FAST8_MAX = @as(c_int, 255);
pub const UINT_FAST16_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST32_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INTPTR_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INTPTR_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const UINTPTR_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const INTMAX_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INTMAX_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINTMAX_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const PTRDIFF_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const PTRDIFF_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const SIG_ATOMIC_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const SIG_ATOMIC_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const SIZE_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const WCHAR_MIN = __WCHAR_MIN;
pub const WCHAR_MAX = __WCHAR_MAX;
pub const WINT_MIN = @as(c_uint, 0);
pub const WINT_MAX = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub inline fn INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub inline fn INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub inline fn INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const INT64_C = __helpers.L_SUFFIX;
pub inline fn UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub inline fn UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const UINT32_C = __helpers.U_SUFFIX;
pub const UINT64_C = __helpers.UL_SUFFIX;
pub const INTMAX_C = __helpers.L_SUFFIX;
pub const UINTMAX_C = __helpers.UL_SUFFIX;
pub const _STDIO_H = @as(c_int, 1);
pub const __GLIBC_USE_LIB_EXT2 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = @as(c_int, 0);
pub const __need_size_t = "";
pub const __need_NULL = "";
pub const __need___va_list = "";
pub const __STDC_VERSION_STDARG_H__ = @as(c_int, 0);
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`"); // /home/emo/Downloads/zig-x86_64-linux-0.16.0/lib/compiler/aro/include/stdarg.h:12:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`"); // /home/emo/Downloads/zig-x86_64-linux-0.16.0/lib/compiler/aro/include/stdarg.h:14:9
pub const va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`"); // /home/emo/Downloads/zig-x86_64-linux-0.16.0/lib/compiler/aro/include/stdarg.h:15:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /home/emo/Downloads/zig-x86_64-linux-0.16.0/lib/compiler/aro/include/stdarg.h:18:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /home/emo/Downloads/zig-x86_64-linux-0.16.0/lib/compiler/aro/include/stdarg.h:22:9
pub const __GNUC_VA_LIST = @as(c_int, 1);
pub const _____fpos_t_defined = @as(c_int, 1);
pub const ____mbstate_t_defined = @as(c_int, 1);
pub const _____fpos64_t_defined = @as(c_int, 1);
pub const ____FILE_defined = @as(c_int, 1);
pub const __FILE_defined = @as(c_int, 1);
pub const __struct_FILE_defined = @as(c_int, 1);
pub const __getc_unlocked_body = @compileError("TODO postfix inc/dec expr"); // /usr/include/bits/types/struct_FILE.h:113:9
pub const __putc_unlocked_body = @compileError("TODO postfix inc/dec expr"); // /usr/include/bits/types/struct_FILE.h:117:9
pub const _IO_EOF_SEEN = @as(c_int, 0x0010);
pub inline fn __feof_unlocked_body(_fp: anytype) @TypeOf((_fp.*._flags & _IO_EOF_SEEN) != @as(c_int, 0)) {
    _ = &_fp;
    return (_fp.*._flags & _IO_EOF_SEEN) != @as(c_int, 0);
}
pub const _IO_ERR_SEEN = @as(c_int, 0x0020);
pub inline fn __ferror_unlocked_body(_fp: anytype) @TypeOf((_fp.*._flags & _IO_ERR_SEEN) != @as(c_int, 0)) {
    _ = &_fp;
    return (_fp.*._flags & _IO_ERR_SEEN) != @as(c_int, 0);
}
pub const _IO_USER_LOCK = __helpers.promoteIntLiteral(c_int, 0x8000, .hex);
pub const __cookie_io_functions_t_defined = @as(c_int, 1);
pub const _VA_LIST_DEFINED = "";
pub const __off_t_defined = "";
pub const __ssize_t_defined = "";
pub const _IOFBF = @as(c_int, 0);
pub const _IOLBF = @as(c_int, 1);
pub const _IONBF = @as(c_int, 2);
pub const BUFSIZ = @as(c_int, 8192);
pub const EOF = -@as(c_int, 1);
pub const SEEK_SET = @as(c_int, 0);
pub const SEEK_CUR = @as(c_int, 1);
pub const SEEK_END = @as(c_int, 2);
pub const P_tmpdir = "/tmp";
pub const L_tmpnam = @as(c_int, 20);
pub const TMP_MAX = __helpers.promoteIntLiteral(c_int, 238328, .decimal);
pub const _BITS_STDIO_LIM_H = @as(c_int, 1);
pub const FILENAME_MAX = @as(c_int, 4096);
pub const L_ctermid = @as(c_int, 9);
pub const FOPEN_MAX = @as(c_int, 16);
pub const __attr_dealloc_fclose = __attr_dealloc(fclose, @as(c_int, 1));
pub const _BITS_FLOATN_H = "";
pub const __HAVE_FLOAT128 = @as(c_int, 1);
pub const __HAVE_DISTINCT_FLOAT128 = @as(c_int, 1);
pub const __HAVE_FLOAT64X = @as(c_int, 1);
pub const __HAVE_FLOAT64X_LONG_DOUBLE = @as(c_int, 1);
pub const __f128 = @compileError("unable to translate macro: undefined identifier `f128`"); // /usr/include/bits/floatn.h:72:12
pub const __CFLOAT128 = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn.h:86:12
pub const _BITS_FLOATN_COMMON_H = "";
pub const __HAVE_FLOAT16 = @as(c_int, 0);
pub const __HAVE_FLOAT32 = @as(c_int, 1);
pub const __HAVE_FLOAT64 = @as(c_int, 1);
pub const __HAVE_FLOAT32X = @as(c_int, 1);
pub const __HAVE_FLOAT128X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT16 = __HAVE_FLOAT16;
pub const __HAVE_DISTINCT_FLOAT32 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT32X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT128X = __HAVE_FLOAT128X;
pub const __HAVE_FLOAT128_UNLIKE_LDBL = (__HAVE_DISTINCT_FLOAT128 != 0) and (__LDBL_MANT_DIG__ != @as(c_int, 113));
pub const __HAVE_FLOATN_NOT_TYPEDEF = @as(c_int, 1);
pub const __f32 = @compileError("unable to translate macro: undefined identifier `f32`"); // /usr/include/bits/floatn-common.h:93:12
pub const __f64 = @compileError("unable to translate macro: undefined identifier `f64`"); // /usr/include/bits/floatn-common.h:105:12
pub const __f32x = @compileError("unable to translate macro: undefined identifier `f32x`"); // /usr/include/bits/floatn-common.h:113:12
pub const __f64x = @compileError("unable to translate macro: undefined identifier `f64x`"); // /usr/include/bits/floatn-common.h:125:12
pub const __CFLOAT32 = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:151:12
pub const __CFLOAT64 = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:163:12
pub const __CFLOAT32X = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:171:12
pub const __CFLOAT64X = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:183:12
pub const GGML_FILE_MAGIC = __helpers.promoteIntLiteral(c_int, 0x67676d6c, .hex);
pub const GGML_FILE_VERSION = @as(c_int, 2);
pub const GGML_QNT_VERSION = @as(c_int, 2);
pub const GGML_QNT_VERSION_FACTOR = @as(c_int, 1000);
pub const GGML_MAX_DIMS = @as(c_int, 4);
pub const GGML_MAX_PARAMS = @as(c_int, 2048);
pub const GGML_MAX_SRC = @as(c_int, 10);
pub const GGML_MAX_N_THREADS = @as(c_int, 512);
pub const GGML_MAX_OP_PARAMS = @as(c_int, 64);
pub const GGML_MAX_NAME = @as(c_int, 64);
pub const GGML_DEFAULT_N_THREADS = @as(c_int, 4);
pub const GGML_DEFAULT_GRAPH_SIZE = @as(c_int, 2048);
pub const GGML_MEM_ALIGN = @as(c_int, 16);
pub const GGML_EXIT_SUCCESS = @as(c_int, 0);
pub const GGML_EXIT_ABORTED = @as(c_int, 1);
pub const GGML_ROPE_TYPE_NORMAL = @as(c_int, 0);
pub const GGML_ROPE_TYPE_NEOX = @as(c_int, 2);
pub const GGML_ROPE_TYPE_MROPE = @as(c_int, 8);
pub const GGML_ROPE_TYPE_VISION = @as(c_int, 24);
pub const GGML_ROPE_TYPE_IMROPE = @as(c_int, 40);
pub const GGML_MROPE_SECTIONS = @as(c_int, 4);
pub const GGML_UNUSED = __helpers.DISCARD;
pub const GGML_UNUSED_VARS = @compileError("unable to translate C expr: unexpected token 'do'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:264:9
pub inline fn GGML_PAD(x: anytype, n: anytype) @TypeOf(((x + n) - @as(c_int, 1)) & ~(n - @as(c_int, 1))) {
    _ = &x;
    _ = &n;
    return ((x + n) - @as(c_int, 1)) & ~(n - @as(c_int, 1));
}
pub const GGML_UNREACHABLE = @compileError("unable to translate macro: undefined identifier `abort`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:270:12
pub const GGML_NORETURN = @compileError("unable to translate C expr: unexpected token '_Noreturn'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:284:12
pub const GGML_ABORT = @compileError("unable to translate macro: undefined identifier `__FILE__`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:287:9
pub const GGML_ASSERT = @compileError("unable to translate C expr: unexpected token 'if'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:288:9
pub const GGML_TENSOR_LOCALS_1 = @compileError("unable to translate C expr: unexpected token 'const'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:298:9
pub const GGML_TENSOR_LOCALS_2 = @compileError("unable to translate C expr: unexpected token 'const'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:301:9
pub const GGML_TENSOR_LOCALS_3 = @compileError("unable to translate C expr: unexpected token 'const'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:305:9
pub const GGML_TENSOR_LOCALS = @compileError("unable to translate C expr: unexpected token 'const'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:309:9
pub const GGML_TENSOR_UNARY_OP_LOCALS = @compileError("unable to translate macro: undefined identifier `ne0`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:314:9
pub const GGML_TENSOR_BINARY_OP_LOCALS = @compileError("unable to translate macro: undefined identifier `ne0`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:320:9
pub const GGML_TENSOR_TERNARY_OP_LOCALS = @compileError("unable to translate macro: undefined identifier `ne0`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:328:9
pub const GGML_TENSOR_BINARY_OP_LOCALS01 = @compileError("unable to translate macro: undefined identifier `ne0`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:338:9
pub const GGML_N_TASKS_MAX = -@as(c_int, 1);
pub const GGML_RESTRICT = @compileError("unable to translate C expr: unexpected token 'restrict'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml.h:2777:17
pub const GGML_BACKEND_API = @compileError("unable to translate C expr: unexpected token 'extern'"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/ggml/include/ggml-backend.h:17:13
pub const GGML_BACKEND_META_MAX_DEVICES = @as(c_int, 16);
pub const GGUF_MAGIC = "GGUF";
pub const GGUF_VERSION = @as(c_int, 3);
pub const GGUF_KEY_GENERAL_ALIGNMENT = "general.alignment";
pub const GGUF_DEFAULT_ALIGNMENT = @as(c_int, 32);
pub const LLAMA_API = "";
pub const DEPRECATED = @compileError("unable to translate macro: undefined identifier `deprecated`"); // /mnt/data1/projects/llm/zllm2/../llama.cpp/include/llama.h:30:13
pub const LLAMA_DEFAULT_SEED = __helpers.promoteIntLiteral(c_int, 0xFFFFFFFF, .hex);
pub const LLAMA_TOKEN_NULL = -@as(c_int, 1);
pub const LLAMA_FILE_MAGIC_GGLA = __helpers.promoteIntLiteral(c_uint, 0x67676c61, .hex);
pub const LLAMA_FILE_MAGIC_GGSN = __helpers.promoteIntLiteral(c_uint, 0x6767736e, .hex);
pub const LLAMA_FILE_MAGIC_GGSQ = __helpers.promoteIntLiteral(c_uint, 0x67677371, .hex);
pub const LLAMA_SESSION_MAGIC = LLAMA_FILE_MAGIC_GGSN;
pub const LLAMA_SESSION_VERSION = @as(c_int, 9);
pub const LLAMA_STATE_SEQ_MAGIC = LLAMA_FILE_MAGIC_GGSQ;
pub const LLAMA_STATE_SEQ_VERSION = @as(c_int, 2);
pub const LLAMA_STATE_SEQ_FLAGS_SWA_ONLY = @as(c_int, 1);
pub const LLAMA_STATE_SEQ_FLAGS_PARTIAL_ONLY = @as(c_int, 1);
pub const _G_fpos_t = struct__G_fpos_t;
pub const _G_fpos64_t = struct__G_fpos64_t;
pub const _IO_marker = struct__IO_marker;
pub const _IO_FILE = struct__IO_FILE;
pub const _IO_codecvt = struct__IO_codecvt;
pub const _IO_wide_data = struct__IO_wide_data;
pub const _IO_cookie_io_functions_t = struct__IO_cookie_io_functions_t;
pub const ggml_status = enum_ggml_status;
pub const ggml_object = struct_ggml_object;
pub const ggml_context = struct_ggml_context;
pub const ggml_cgraph = struct_ggml_cgraph;
pub const ggml_type = enum_ggml_type;
pub const ggml_prec = enum_ggml_prec;
pub const ggml_ftype = enum_ggml_ftype;
pub const ggml_op = enum_ggml_op;
pub const ggml_unary_op = enum_ggml_unary_op;
pub const ggml_glu_op = enum_ggml_glu_op;
pub const ggml_object_type = enum_ggml_object_type;
pub const ggml_log_level = enum_ggml_log_level;
pub const ggml_tensor_flag = enum_ggml_tensor_flag;
pub const ggml_tri_type = enum_ggml_tri_type;
pub const ggml_init_params = struct_ggml_init_params;
pub const ggml_tensor = struct_ggml_tensor;
pub const ggml_op_pool = enum_ggml_op_pool;
pub const ggml_scale_mode = enum_ggml_scale_mode;
pub const ggml_scale_flag = enum_ggml_scale_flag;
pub const ggml_sort_order = enum_ggml_sort_order;
pub const ggml_type_traits = struct_ggml_type_traits;
pub const ggml_sched_priority = enum_ggml_sched_priority;
pub const ggml_threadpool_params = struct_ggml_threadpool_params;
pub const ggml_threadpool = struct_ggml_threadpool;
pub const ggml_backend_buffer_type = struct_ggml_backend_buffer_type;
pub const ggml_backend = struct_ggml_backend;
pub const ggml_tallocr = struct_ggml_tallocr;
pub const ggml_gallocr = struct_ggml_gallocr;
pub const ggml_backend_event = struct_ggml_backend_event;
pub const ggml_backend_reg = struct_ggml_backend_reg;
pub const ggml_backend_device = struct_ggml_backend_device;
pub const ggml_backend_buffer_usage = enum_ggml_backend_buffer_usage;
pub const ggml_backend_dev_caps = struct_ggml_backend_dev_caps;
pub const ggml_backend_dev_props = struct_ggml_backend_dev_props;
pub const ggml_backend_feature = struct_ggml_backend_feature;
pub const ggml_backend_sched = struct_ggml_backend_sched;
pub const ggml_backend_meta_split_axis = enum_ggml_backend_meta_split_axis;
pub const ggml_backend_meta_split_state = struct_ggml_backend_meta_split_state;
pub const ggml_cplan = struct_ggml_cplan;
pub const ggml_numa_strategy = enum_ggml_numa_strategy;
pub const ggml_type_traits_cpu = struct_ggml_type_traits_cpu;
pub const ggml_opt_dataset = struct_ggml_opt_dataset;
pub const ggml_opt_context = struct_ggml_opt_context;
pub const ggml_opt_result = struct_ggml_opt_result;
pub const ggml_opt_loss_type = enum_ggml_opt_loss_type;
pub const ggml_opt_build_type = enum_ggml_opt_build_type;
pub const ggml_opt_optimizer_type = enum_ggml_opt_optimizer_type;
pub const ggml_opt_optimizer_params = struct_ggml_opt_optimizer_params;
pub const ggml_opt_params = struct_ggml_opt_params;
pub const gguf_type = enum_gguf_type;
pub const gguf_context = struct_gguf_context;
pub const gguf_init_params = struct_gguf_init_params;
pub const llama_vocab = struct_llama_vocab;
pub const llama_model = struct_llama_model;
pub const llama_context = struct_llama_context;
pub const llama_sampler_data = struct_llama_sampler_data;
pub const llama_sampler_i = struct_llama_sampler_i;
pub const llama_sampler = struct_llama_sampler;
pub const llama_memory_i = struct_llama_memory_i;
pub const llama_rope_type = enum_llama_rope_type;
pub const llama_token_type = enum_llama_token_type;
pub const llama_token_attr = enum_llama_token_attr;
pub const llama_ftype = enum_llama_ftype;
pub const llama_rope_scaling_type = enum_llama_rope_scaling_type;
pub const llama_attention_type = enum_llama_attention_type;
pub const llama_flash_attn_type = enum_llama_flash_attn_type;
pub const llama_split_mode = enum_llama_split_mode;
pub const llama_model_kv_override_type = enum_llama_model_kv_override_type;
pub const llama_model_meta_key = enum_llama_model_meta_key;
pub const llama_model_kv_override = struct_llama_model_kv_override;
pub const llama_model_tensor_buft_override = struct_llama_model_tensor_buft_override;
pub const llama_model_params = struct_llama_model_params;
pub const llama_sampler_seq_config = struct_llama_sampler_seq_config;
pub const llama_context_params = struct_llama_context_params;
pub const llama_model_tensor_override = struct_llama_model_tensor_override;
pub const llama_model_imatrix_data = struct_llama_model_imatrix_data;
pub const llama_adapter_lora = struct_llama_adapter_lora;
pub const llama_params_fit_status = enum_llama_params_fit_status;
pub const llama_perf_context_data = struct_llama_perf_context_data;
pub const llama_perf_sampler_data = struct_llama_perf_sampler_data;
pub const llama_opt_params = struct_llama_opt_params;
