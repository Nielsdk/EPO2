onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group CLK /tb/clk
add wave -noupdate -group Debug /tb/C00/C01/reset
add wave -noupdate -group Debug /tb/C00/C02/count_reset
add wave -noupdate -group Debug /tb/C00/C07/distance_count_reset
add wave -noupdate -group Debug /tb/C00/C07/pwm_count_reset
add wave -noupdate -group Debug /tb/C00/C07/tx_state_reg
add wave -noupdate -group Debug /tb/C00/C07/override_cont_state
add wave -noupdate -group Debug /tb/C00/C07/station_state
add wave -noupdate -group Debug /tb/C00/C01/state
add wave -noupdate -group {Main signals} /tb/clk_time
add wave -noupdate -group {Main signals} /tb/motor_l
add wave -noupdate -group {Main signals} /tb/motor_r
add wave -noupdate -group {Main signals} /tb/reset
add wave -noupdate -group {Main signals} /tb/reset_time
add wave -noupdate -group {Main signals} /tb/rx
add wave -noupdate -group {Main signals} /tb/sensor_l
add wave -noupdate -group {Main signals} /tb/sensor_m
add wave -noupdate -group {Main signals} /tb/sensor_r
add wave -noupdate -group {Main signals} /tb/tx
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_l_in
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_m_in
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_r_in
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_l_out
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_m_out
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_r_out
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_l_buf_t
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_m_buf_t
add wave -noupdate -group {Input Buffer} /tb/C00/C00/sensor_r_buf_t
add wave -noupdate -group Controller /tb/C00/C01/reset
add wave -noupdate -group Controller /tb/C00/C01/sensor_l
add wave -noupdate -group Controller /tb/C00/C01/sensor_m
add wave -noupdate -group Controller /tb/C00/C01/sensor_r
add wave -noupdate -group Controller /tb/C00/C01/count_in
add wave -noupdate -group Controller /tb/C00/C01/override_vector
add wave -noupdate -group Controller /tb/C00/C01/override
add wave -noupdate -group Controller /tb/C00/C01/count_reset
add wave -noupdate -group Controller /tb/C00/C01/motor_l_reset
add wave -noupdate -group Controller /tb/C00/C01/motor_l_direction
add wave -noupdate -group Controller /tb/C00/C01/motor_l_speed
add wave -noupdate -group Controller /tb/C00/C01/motor_r_reset
add wave -noupdate -group Controller /tb/C00/C01/motor_r_direction
add wave -noupdate -group Controller /tb/C00/C01/motor_r_speed
add wave -noupdate -group Controller /tb/C00/C01/state
add wave -noupdate -group Controller /tb/C00/C01/new_state
add wave -noupdate -group Controller /tb/C00/C01/sensor
add wave -noupdate -group Timebase /tb/C00/C02/count_reset
add wave -noupdate -group Timebase /tb/C00/C02/count_out
add wave -noupdate -group Timebase /tb/C00/C02/count
add wave -noupdate -group Timebase /tb/C00/C02/new_count
add wave -noupdate -group Motoren /tb/C00/C03/direction
add wave -noupdate -group Motoren /tb/C00/C03/count_in
add wave -noupdate -group Motoren /tb/C00/C03/speed
add wave -noupdate -group Motoren /tb/C00/C03/pwm
add wave -noupdate -group Motoren /tb/C00/C03/state
add wave -noupdate -group Motoren /tb/C00/C03/new_state
add wave -noupdate -group Motoren /tb/C00/C04/direction
add wave -noupdate -group Motoren /tb/C00/C04/count_in
add wave -noupdate -group Motoren /tb/C00/C04/speed
add wave -noupdate -group Motoren /tb/C00/C04/pwm
add wave -noupdate -group Motoren /tb/C00/C04/state
add wave -noupdate -group Motoren /tb/C00/C04/new_state
add wave -noupdate -group UART /tb/C00/C05/rx
add wave -noupdate -group UART /tb/C00/C05/tx
add wave -noupdate -group UART /tb/C00/C05/uart_in
add wave -noupdate -group UART /tb/C00/C05/uart_out
add wave -noupdate -group UART /tb/C00/C05/write_data
add wave -noupdate -group UART /tb/C00/C05/read_data
add wave -noupdate -group UART /tb/C00/C05/receiver_flag
add wave -noupdate -group UART /tb/C00/C05/s_tick
add wave -noupdate -group UART /tb/C00/C05/rx_done_tick
add wave -noupdate -group UART /tb/C00/C05/tx_done_tick
add wave -noupdate -group UART /tb/C00/C05/d_buf_tx
add wave -noupdate -group UART /tb/C00/C05/d_rx_buf
add wave -noupdate -group UART /tb/C00/C05/flag_tx_start
add wave -noupdate -group UART /tb/C00/C05/sseg_enable
add wave -noupdate -group rx_translator /tb/C00/C06/receiver_in
add wave -noupdate -group rx_translator /tb/C00/C06/flag_in
add wave -noupdate -group rx_translator /tb/C00/C06/translator_out_reset
add wave -noupdate -group rx_translator /tb/C00/C06/flag_reset
add wave -noupdate -group rx_translator /tb/C00/C06/translator_out
add wave -noupdate -group rx_translator /tb/C00/C06/receiver_check
add wave -noupdate -group rx_translator /tb/C00/C06/send_check
add wave -noupdate -group rx_translator /tb/C00/C06/translator_reg
add wave -noupdate -group rx_translator /tb/C00/C06/translator_next
add wave -noupdate -group rx_translator /tb/C00/C06/receiver_check_reg
add wave -noupdate -group rx_translator /tb/C00/C06/receiver_check_next
add wave -noupdate -group rx_translator /tb/C00/C06/receiver_in_reg
add wave -noupdate -group rx_translator /tb/C00/C06/receiver_in_next
add wave -noupdate -group rx_translator /tb/C00/C06/state_reg
add wave -noupdate -group rx_translator /tb/C00/C06/state_next
add wave -noupdate -group rx_translator /tb/C00/C06/flag_reg
add wave -noupdate -group rx_translator /tb/C00/C06/flag_next
add wave -noupdate -group Override_Controller /tb/C00/C07/translator_out
add wave -noupdate -group Override_Controller /tb/C00/C07/override_vector
add wave -noupdate -group Override_Controller /tb/C00/C07/override
add wave -noupdate -group Override_Controller /tb/C00/C07/translator_out_reset
add wave -noupdate -group Override_Controller /tb/C00/C07/count_reset
add wave -noupdate -group Override_Controller /tb/C00/C07/sensor_l
add wave -noupdate -group Override_Controller /tb/C00/C07/sensor_m
add wave -noupdate -group Override_Controller /tb/C00/C07/sensor_r
add wave -noupdate -group Override_Controller /tb/C00/C07/tx_out
add wave -noupdate -group Override_Controller /tb/C00/C07/tx_send_out
add wave -noupdate -group Override_Controller /tb/C00/C07/station_state
add wave -noupdate -group Override_Controller /tb/C00/C07/new_station_state
add wave -noupdate -group Override_Controller /tb/C00/C07/override_cont_state
add wave -noupdate -group Override_Controller /tb/C00/C07/override_cont_new_state
add wave -noupdate -group Override_Controller /tb/C00/C07/tx_state_reg
add wave -noupdate -group Override_Controller /tb/C00/C07/tx_state_next
add wave -noupdate -group Override_Controller /tb/C00/C07/pwm_count
add wave -noupdate -group Override_Controller /tb/C00/C07/new_pwm_count
add wave -noupdate -group Override_Controller /tb/C00/C07/distance_count
add wave -noupdate -group Override_Controller /tb/C00/C07/new_distance_count
add wave -noupdate -group Override_Controller /tb/C00/C07/pwm_count_out
add wave -noupdate -group Override_Controller /tb/C00/C07/pwm_count_reset
add wave -noupdate -group Override_Controller /tb/C00/C07/distance_count_reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23512037 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
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
WaveRestoreZoom {0 ns} {135520770 ns}
