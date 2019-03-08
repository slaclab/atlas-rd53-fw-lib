# Verilog abstract generation from OA cell views

Use the ``oa2verilog`` command line utility to generate Verilog abstracts from OA schematic or symbol views for top-level macros:

```
linux% oa2verilog -lib RD53_ANALOG_CHIP_BOTTOM -cell RD53_ANALOG_CHIP_BOTTOM -view symbol -excludeLeaf -verilog RD53_ANALOG_CHIP_BOTTOM.pins.v
linux% oa2verilog -lib RD53_IO                 -cell RD53_PADFRAME_BOTTOM    -view symbol -excludeLeaf -verilog RD53_PADFRAME_BOTTOM.pins.v
linux% oa2verilog -lib RD53_AFE_BGPV           -cell RD53_AFE_BGPV           -view symbol -excludeLeaf -verilog RD53_AFE_BGPV.pins.v
```

**Notes**

1. all bias lines and power/ground pins should be declared as **inout** ports

2. all digital inputs are **input** ports

3. all digital outputs are **output** ports

