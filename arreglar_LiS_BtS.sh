#!/bin/bash

# Creamos la librería necesaria
touch test.c

# Ponemos el código necesario
echo '#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>

void *
__libc_dlopen_mode (const char *file, int mode)
{
  printf("__libc_dlopen_mode %s \n", file);
  return dlopen (file, mode);
}

void *
__libc_dlsym (void *handle, const char *name)
{
  printf("__libc_dlsym %s \n", name);
  return dlsym (handle, name);
}' >> test.c

# La compilamos
gcc test.c -g -O0 -shared -fPIC -o lisbts_patch-0.1.so

# Y movemos la librería a su carpeta correspondiente dentro del juego
script_dir=$(dirname "$0")
cp lisbts_patch-0.1.so "$script_dir/lib/"

# Script a parchear
target_file='LifeIsStrangeBTS.sh'

# Diff file
patch_file='
285a286,287
> 	# Add in the patch for new glibc:
> 	LD_PRELOAD_ADDITIONS="/usr/local/lib/lisbts_patch-0.1.so:${LD_PRELOAD_ADDITIONS}"
'

# Aplicamos el parche
patch -b $target_file <<EOF
$patch_file
EOF

echo "It should go if it hasn't given any errors"
