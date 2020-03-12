#!/bin/bash

vi input.txt
iverilog logicFunctions.v
./a.out >> input.txt
iverilog adder.v
./a.out >> input.txt
iverilog mult.v
./a.out >> input.txt
iverilog subtractor.v
./a.out >> input.txt
