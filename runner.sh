#!/usr/bin/env bash
set -e

export TIME="/usr/bin/time -v"

export PYTHONMALLOC=malloc
export G_SLICE=always-malloc

rm -rf bin
mkdir -p bin dumps

function massif() {
    name="$1"
    cmd="$2"
    #valgrind --tool=massif --stacks=yes --depth=100 --massif-out-file="massif.out.${name}.bin" ${cmd} 2>/dev/null
    #valgrind --tool=massif --pages-as-heap=yes --massif-out-file="massif.out.${name}.bin" ${cmd} 2>/dev/null
    echo "massif $name"
    $TIME $cmd 2>&1|grep Maximum
    valgrind \
    --stacks=yes \
    --smc-check=all --trace-children=yes \
    --tool=massif \
    --depth=100 \
    --alloc-fn=brk \
    --alloc-fn=sbrk \
    --alloc-fn='operator new(unsigned long)' \
    --alloc-fn='PickChunk(JSRuntime*)' \
    --alloc-fn='RefillFinalizableFreeList(JSContext*, unsigned int)' \
    --alloc-fn='XPConnectGCChunkAllocator::doAlloc()' \
    --alloc-fn=_objalloc_alloc \
    --alloc-fn=_obstack_begin \
    --alloc-fn=_obstack_newchunk \
    --alloc-fn=arena_bin_malloc_hard \
    --alloc-fn=arena_run_alloc \
    --alloc-fn=bfd_alloc \
    --alloc-fn=bfd_zalloc \
    --alloc-fn=chunk_alloc \
    --alloc-fn=Malloc \
    --alloc-fn=Calloc \
    --alloc-fn=UncheckedMalloc \
    --alloc-fn=UncheckedCalloc \
    --alloc-fn=uprv_malloc \
    --alloc-fn=CRYPTO_malloc \
    --alloc-fn=g_malloc \
    --alloc-fn=g_malloc0 \
    --alloc-fn=htab_expand \
    --alloc-fn=huge_malloc \
    --alloc-fn=JS_ArenaAllocate \
    --alloc-fn=malloc \
    --alloc-fn=mallocWithAlarm \
    --alloc-fn=mmap \
    --alloc-fn=moz_xmalloc \
    --alloc-fn=NS_Alloc_P \
    --alloc-fn=NS_Realloc_P \
    --alloc-fn=objalloc_create \
    --alloc-fn=pages_map \
    --alloc-fn=PL_ArenaAllocate \
    --alloc-fn=posix_memalign \
    --alloc-fn=PyObject_Malloc \
    --alloc-fn=realloc \
    --alloc-fn=sqlite3Malloc \
    --alloc-fn=sqlite3MemMalloc \
    --alloc-fn=syscall \
    --alloc-fn=xcalloc \
    --alloc-fn=xmalloc \
    --alloc-fn=xrealloc \
    --alloc-fn=xstrdup \
    --alloc-fn=xzalloc \
    --massif-out-file="dumps/massif.out.${name}.bin" \
   ${cmd} 2>/dev/null
}


go build -o bin/fetch_go ./src/fetch.go
massif fetch_go ./bin/fetch_go

gcc ./src/fetch.c -lcurl -o bin/fetch_c
massif fetch_c ./bin/fetch_c

g++ ./src/fetch.cpp -lcurl -o bin/fetch_cpp
massif fetch_cpp ./bin/fetch_cpp

find . -name \*.pyc -delete
massif fetch_py "python -B ./src/fetch.py"
massif fetch_py_O "python -B -O ./src/fetch.py"
massif fetch_py_OO "python -B -OO ./src/fetch.py"

python -m compileall -b -q ./src/fetch.py
massif fetch_compiled_py "python ./src/fetch.pyc"

massif fetch_requests.py "python -B ./src/fetch_requests.py"
massif fetch_aiohttp.py "python -B ./src/fetch_aiohttp.py"

#massif fetch.micro.py "micropython fetch.micro.py"

massif fetch.lua "lua ./src/fetch.lua"
massif fetch.js "node ./src/fetch.js"

pushd src/fetch_rs
cargo build --release --quiet
mv ./target/release/fetch_rs ../../bin/
popd
massif fetch.rs "./bin/fetch_rs"

#massif fetch.pl "perl ./src/fetch.pl"

# sudo systemd-run --scope  --unit limit-test.scope -p MemoryAccounting=true -p MemorySwapMax=1 -p MemoryMax='10M' ./fetch
