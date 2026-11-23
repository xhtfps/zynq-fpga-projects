# 按键 key_in
set_property PACKAGE_PIN L14 [get_ports {key_in[0]}]
set_property PACKAGE_PIN K16 [get_ports {key_in[1]}]

# LED
set_property PACKAGE_PIN H15 [get_ports {led[0]}]
set_property PACKAGE_PIN L15 [get_ports {led[1]}]

# 时钟、复位
set_property PACKAGE_PIN U18 [get_ports clk]
set_property PACKAGE_PIN N16 [get_ports rst_n]

# IO电平标准 LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[*]}]