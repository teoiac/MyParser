#!/bin/bash

rm -rf complete_symbol_table.txt
rm -rf symbol_table.txt
rm -rf function_symbol_table.txt

./parser < input.txt 