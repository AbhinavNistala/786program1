# Location of the CUDA Toolkit
NVCC := $(CUDA_PATH)/bin/nvcc
CCFLAGS := -O2

build: quamsimV2

quamsimV2.o:quamsimV2.cu
	$(NVCC) $(INCLUDES) $(CCFLAGS) $(GENCODE_FLAGS) -o $@ -c $<

quamsimV2: quamsimV2.o
	$(NVCC) $(LDFLAGS) $(GENCODE_FLAGS) -o $@ $+ $(LIBRARIES)

run: build
	$(EXEC) ./quamsimV2

clean:
	rm -f quamsimV2 *.o
