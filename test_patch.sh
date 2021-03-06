#!/usr/bin/env bash
set -euxo pipefail

declare -a python_urls=(
"https://www.python.org/ftp/python/2.6.9/Python-2.6.9.tgz" 
"https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz" 
"https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz" 
"https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz" 
"https://www.python.org/ftp/python/3.3.7/Python-3.3.7.tgz" 
)
declare -a patches=( 
"patches/2.6/pep445.patch" 
"patches/2.7/pep445.patch" 
"patches/2.7.10/2.7/pep445.patch" 
"patches/2.7.12/2.7/pep445.patch" 
"patches/3.3/pep445.patch" 
)
src=$(dirname "$BASH_SOURCE")
test_py_file="test_tracemalloc_env_var.py"

for i in "${!python_urls[@]}"; do 
    rm -rf /tmp/test-pytracemalloc-patch
    mkdir -p /tmp/test-pytracemalloc-patch
    cd /tmp/test-pytracemalloc-patch
    python_url="${python_urls[$i]}"
    patch_path="${src}/${patches[$i]}"
    printf "%s\t%s\n" "${patch_path}" "${python_url}"
    
    # Download Python source
    wget -O python.tgz "${python_url}"
    tar -xf python.tgz
    cd $(ls -d */|head -n 1)
    
    # Patch and compile
    patch -p1 < "${patch_path}"
    ./configure --enable-unicode=ucs4 --prefix=/tmp/test-pytracemalloc-patch/py
    make install
    
    cd ${src}
    py="/tmp/test-pytracemalloc-patch/py/bin/python"
    if [ ! -f "${py}" ]
    then
        py="/tmp/test-pytracemalloc-patch/py/bin/python3"
    fi
    ${py} setup.py install
    PYTHONTRACEMALLOC=1 ${py} "${test_py_file}"
    printf "%s\t%s OK\n" "${patch_path}" "${python_url}"
done

rm -rf /tmp/test-pytracemalloc-patch
