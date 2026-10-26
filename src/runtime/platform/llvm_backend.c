/* Compiler-only adapter to LLVM's typed C API. No LLVM link dependency.
 * See tools/generate-llvm-bridge.py. Generated IR is internalized so ordinary
 * executables discard it. LLVM is loaded only on an explicit backend call. */
#include <stdint.h>
#include <stddef.h>
#include <llvm-c/Core.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/IRReader.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <llvm-c/Error.h>
extern void *dlopen(const char *, int);
extern void *dlsym(void *, const char *);
extern char *dlerror(void);
extern int strcmp(const char *, const char *);
extern int snprintf(char *, size_t, const char *, ...);

#define API_LIST(X) \
 X(LLVMContextCreate) X(LLVMContextDispose) \
 X(LLVMCreateMemoryBufferWithContentsOfFile) X(LLVMParseIRInContext) \
 X(LLVMDisposeModule) X(LLVMDisposeMessage) X(LLVMVerifyModule) \
 X(LLVMGetTargetFromTriple) X(LLVMCreateTargetMachine) \
 X(LLVMDisposeTargetMachine) X(LLVMCreateTargetDataLayout) \
 X(LLVMSetModuleDataLayout) X(LLVMDisposeTargetData) X(LLVMSetTarget) \
 X(LLVMCreatePassBuilderOptions) X(LLVMDisposePassBuilderOptions) \
 X(LLVMRunPasses) X(LLVMGetErrorMessage) X(LLVMDisposeErrorMessage) \
 X(LLVMTargetMachineEmitToFile) X(LLVMGetVersion)
#define FIELD(name) static __typeof__(&name) p_##name;
API_LIST(FIELD)
static void *library_handle;
static char library_name[4096];
static char diagnostic[4096];
static int target_initialized;

static int fail(const char *message, const char *detail) {
    snprintf(diagnostic, sizeof(diagnostic), "LLVM backend: %s: %s", message,
             detail ? detail : "unknown error");
    return 0;
}

static int load(const char *path, const char *triple) {
    if (library_handle) {
        if (strcmp(path, library_name))
            return fail("library cannot change within one process", path);
        return 1;
    }
    void *handle = dlopen(path, 2); /* RTLD_NOW; default local on both platforms. */
    if (!handle) return fail("cannot load shared library", dlerror());
    /* Retain loaded LLVM until process exit: it owns process-wide registries.
     * This also avoids repeated initialization/unloading after bad input. */
#define RESOLVE(name) do { \
    p_##name = (__typeof__(p_##name))dlsym(handle, #name); \
    if (!p_##name) return fail("missing C API symbol", #name); \
} while (0);
    API_LIST(RESOLVE)
    unsigned major=0, minor=0, patch=0;
    p_LLVMGetVersion(&major, &minor, &patch);
    if (major < 18 || major > 22)
        return fail("supported LLVM versions are 18 through 22", path);
    const char *family = triple[0] == 'x' ? "X86" : "AArch64";
    const char *suffixes[] = {"TargetInfo", "Target", "TargetMC", "AsmPrinter"};
    if (!target_initialized) {
        for (unsigned i=0; i<4; ++i) {
            char symbol[80];
            snprintf(symbol, sizeof(symbol), "LLVMInitialize%s%s", family, suffixes[i]);
            void (*initialize)(void) = (void (*)(void))dlsym(handle, symbol);
            if (!initialize) return fail("missing native target symbol", symbol);
            initialize();
        }
        target_initialized = 1;
    }
    snprintf(library_name, sizeof(library_name), "%s", path);
    library_handle = handle;
    return 1;
}

/* The outer ABI deliberately matches Faz's i64 runtime boundary. LLVM calls
 * below use their actual ptr/i32/void signatures from the installed headers. */
int64_t rt_os_llvm_object(int64_t library, int64_t input, int64_t output,
                         int64_t target, int64_t optimization) {
    const char *path = (const char *)(uintptr_t)library;
    const char *triple = (const char *)(uintptr_t)target;
    diagnostic[0] = 0;
    if (optimization < 0 || optimization > 3) {
        fail("invalid optimization level", "expected 0, 1, 2, or 3");
        return (int64_t)(uintptr_t)diagnostic;
    }
    if (!load(path, triple)) return (int64_t)(uintptr_t)diagnostic;
    LLVMContextRef context = p_LLVMContextCreate();
    LLVMModuleRef module = NULL;
    LLVMMemoryBufferRef buffer = NULL;
    LLVMTargetMachineRef machine = NULL;
    LLVMTargetDataRef layout = NULL;
    LLVMPassBuilderOptionsRef options = NULL;
    char *message = NULL;
    if (p_LLVMCreateMemoryBufferWithContentsOfFile((const char *)(uintptr_t)input,
                                                  &buffer, &message)) {
        fail("cannot read IR", message);
        goto cleanup;
    }
    /* ParseIRInContext consumes the buffer on success AND failure. */
    if (p_LLVMParseIRInContext(context, buffer, &module, &message)) {
        fail("invalid IR", message);
        goto cleanup;
    }
    if (p_LLVMVerifyModule(module, LLVMReturnStatusAction, &message)) {
        fail("IR verification failed", message);
        goto cleanup;
    }
    if (message) { p_LLVMDisposeMessage(message); message = NULL; }
    LLVMTargetRef native_target = NULL;
    if (p_LLVMGetTargetFromTriple(triple, &native_target, &message)) {
        fail("unsupported target", message);
        goto cleanup;
    }
    machine = p_LLVMCreateTargetMachine(native_target, triple, "generic", "",
                 (LLVMCodeGenOptLevel)optimization, LLVMRelocPIC, LLVMCodeModelDefault);
    if (!machine) { fail("cannot create target machine", triple); goto cleanup; }
    p_LLVMSetTarget(module, triple);
    layout = p_LLVMCreateTargetDataLayout(machine);
    p_LLVMSetModuleDataLayout(module, layout);
    options = p_LLVMCreatePassBuilderOptions();
    const char *pipelines[] = {"default<O0>", "default<O1>", "default<O2>", "default<O3>"};
    LLVMErrorRef error = p_LLVMRunPasses(module, pipelines[optimization], machine, options);
    if (error) {
        char *detail = p_LLVMGetErrorMessage(error); /* consumes LLVMErrorRef */
        fail("optimization failed", detail);
        p_LLVMDisposeErrorMessage(detail);
        goto cleanup;
    }
    if (p_LLVMTargetMachineEmitToFile(machine, module, (char *)(uintptr_t)output,
                                     LLVMObjectFile, &message))
        fail("cannot emit object", message);
cleanup:
    if (message) p_LLVMDisposeMessage(message);
    if (options) p_LLVMDisposePassBuilderOptions(options);
    if (layout) p_LLVMDisposeTargetData(layout);
    if (machine) p_LLVMDisposeTargetMachine(machine);
    if (module) p_LLVMDisposeModule(module);
    p_LLVMContextDispose(context);
    return (int64_t)(uintptr_t)diagnostic;
}
