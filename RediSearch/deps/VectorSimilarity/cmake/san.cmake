option(USE_ASAN "Use AddressSanitizer (clang)" OFF)
option(USE_MSAN "Use MemorySanitizer (clang)" OFF)
if (USE_ASAN OR USE_MSAN)
	# define this before project()
	find_file(CMAKE_C_COMPILER "clang")
	find_file(CMAKE_CXX_COMPILER "clang++")
	set(CMAKE_LINKER "${CMAKE_C_COMPILER}")

	if (USE_ASAN)
		set(CLANG_SAN_FLAGS "-fno-omit-frame-pointer -fsanitize=address")

	elseif (USE_MSAN)
		set(CLANG_SAN_FLAGS "-fno-omit-frame-pointer -fsanitize=memory -fsanitize-memory-track-origins=2")
		if (NOT MSAN_PREFIX)
			set(MSAN_PREFIX "/opt/llvm-project/build-msan")
			if (NOT EXISTS ${MSAN_PREFIX})
				message(FATAL_ERROR "LLVM/MSAN stdlibc++ directory '${MSAN_PREFIX}' is missing")
			endif()
		endif()
		set(LLVM_CXX_FLAGS "-stdlib=libc++ -I${MSAN_PREFIX}/include -I${MSAN_PREFIX}/include/c++/v1")
		set(LLVM_LD_FLAGS "-stdlib=libc++ -Wl,-rpath=${MSAN_PREFIX}/lib -L${MSAN_PREFIX}/lib -lc++abi")
	endif()
endif()