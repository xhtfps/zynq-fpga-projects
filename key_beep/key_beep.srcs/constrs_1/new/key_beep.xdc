#蜂鸣器
set_property PACKAGE_PIN M14 [get_ports beep]
#按键KEY0 L14
set_property PACKAGE_PIN L14 [get_ports {key[0]}]
#按键KEY1 K16（备用）
set_property PACKAGE_PIN K16 [get_ports {key[1]}]
#时钟复位
set_property PACKAGE_PIN U18 [get_ports clk]
set_property PACKAGE_PIN N16 [get_ports rst_n]
#IO电平
set_property IOSTANDARD LVCMOS33 [get_ports *]

#时钟约束：U18为50 MHz系统时钟，周期20 ns
create_clock -period 20.000 -name clk [get_ports clk]
