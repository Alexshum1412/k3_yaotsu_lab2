# Синтез проектов ЛР №2 (задания 3.3 и 3.4) в САПР Vivado для ПЛИС Zynq-7010.
# Запуск из корня репозитория:
#   vivado -mode batch -source scripts/vivado_synth.tcl
# Отчёты сохраняются в vivado_reports/.
set part xc7z010clg400-1
set root [file normalize [file dirname [info script]]/..]
set out  $root/vivado_reports
file mkdir $out

proc run_synth {name top files arch_top} {
    global part out
    close_project -quiet
    create_project -in_memory -part $part
    read_vhdl -vhdl2008 $files
    synth_design -top $top -part $part {*}$arch_top
    report_utilization    -file $out/${name}_utilization.rpt
    report_timing_summary -file $out/${name}_timing.rpt
    catch {write_schematic -force -format pdf $out/${name}_schematic.pdf}
    puts "== $name: done"
}

# 3.3 - мультиплексор 45-1 со стробированием
run_synth mux45_1 mux45_1 [list $root/task3_mux45/mux45_1.vhd] {}
# 3.3 (доп.) - MUX/DEMUX с приоритетизацией
run_synth mux_demux_prio mux_demux_prio [list $root/task3_extra_mux_demux/mux_demux_prio.vhd] {}
# 3.4 - нерегулярная схема (в circuit_v7.vhd последней описана архитектура
# Behavioral; Vivado по умолчанию берёт последнюю архитектуру).
# Задержки "after" синтезатором игнорируются (предупреждение Synth 8-...).
set el [glob $root/task4_irregular/elements/*.vhd]
run_synth circuit_v7 circuit_v7 [concat $el [list $root/task4_irregular/circuit_v7.vhd]] {}
