
all: build

build:
	lsc -o static src_ls/*.ls

spy:
	lsc -w -o static src_ls/*.ls

