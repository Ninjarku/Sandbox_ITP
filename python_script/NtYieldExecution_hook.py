import ctypes
import ctypes.wintypes as wintypes

try:
    import win32api
except ImportError:
    import subprocess
    import sys

    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pywin32'])

# loading the DLLs into memory for access to the windows API function
kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
ntdll = ctypes.WinDLL('ntdll', use_last_error=True)
PAGE_EXECUTE_READWRITE = 0x40

def new_NtYieldExecution():
    return 0

def hook_nt_yield_execution():
    # Define function type for NtYieldExecution
    NtYieldExecutionProto = ctypes.WINFUNCTYPE(wintypes.BOOL)

    new_func_ptr = NtYieldExecutionProto(new_NtYieldExecution)

    # converts the function pointer to its address in memory so that is can be used to generate assembly code
    new_func_addr = ctypes.cast(new_func_ptr, ctypes.c_void_p).value
    patch_code = get_patch_code(new_func_addr)

    # Address of NtYieldExecution
    NtYieldExecution_addr = ctypes.cast(ntdll.NtYieldExecution, ctypes.c_void_p).value

    # writing the patch code into the new NtYieldExecution
    original_function = ctypes.c_void_p(NtYieldExecution_addr)
    protect_memory(original_function, patch_code)
    write_memory(original_function, patch_code)

    print("NtYieldExecution hooked successfully.")

def get_patch_code(func_addr):
    if ctypes.sizeof(ctypes.c_void_p) == 8:
        return b"\x48\xb8" + func_addr.to_bytes(8, byteorder='little') + b"\xFF\xE0"  # mov rax, func_addr; jmp rax
    else:
        return b"\xB8" + func_addr.to_bytes(4, byteorder='little') + b"\xFF\xE0"  # mov eax, func_addr; jmp eax

# changing the permission of that memory to read and write
def protect_memory(addr, code):
    kernel32.VirtualProtect(addr, len(code), PAGE_EXECUTE_READWRITE, ctypes.byref(ctypes.c_ulong()))

# writing into the specified memory address
def write_memory(addr, code):
    kernel32.WriteProcessMemory(kernel32.GetCurrentProcess(), addr, code, len(code), ctypes.byref(ctypes.c_size_t()))

hook_nt_yield_execution()
