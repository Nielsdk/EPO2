onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset
add wave -noupdate /tb/rx
add wave -noupdate /tb/tx
add wave -noupdate /tb/motor_l
add wave -noupdate /tb/motor_r
add wave -noupdate -radix binary /tb/C00/C07/translator_out
add wave -noupdate /tb/C00/C07/override
add wave -noupdate /tb/C00/C07/translator_out_reset
add wave -noupdate /tb/C00/C07/tx_out
add wave -noupdate /tb/C00/C07/tx_send_out
add wave -noupdate /tb/C00/C07/station_state
add wave -noupdate /tb/C00/C07/override_cont_state
add wave -noupdate -radix decimal /tb/C00/C07/pwm_count
add wave -noupdate -radix decimal /tb/C00/C07/distance_count
add wave -noupdate /tb/C00/C01/state
add wave -noupdate -radix binary -childformat {{/tb/C00/C01/sensor(2) -radix binary} {/tb/C00/C01/sensor(1) -radix binary} {/tb/C00/C01/sensor(0) -radix binary}} -subitemconfig {/tb/C00/C01/sensor(2) {-height 15 -radix binary} /tb/C00/C01/sensor(1) {-height 15 -radix binary} /tb/C00/C01/sensor(0) {-height 15 -radix binary}} /tb/C00/C01/sensor
add wave -noupdate /tb/sseg
add wave -noupdate /tb/led
add wave -noupdate /tb/an
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45000080 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 313
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {315 ms}
