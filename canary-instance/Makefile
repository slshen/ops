include ../config.mk
include ../rules.mk

gen: lambda-terminator/function.zip

lambda-terminator/function.zip: lambda-terminator/function.py
	cd lambda-terminator && zip function.zip function.py
