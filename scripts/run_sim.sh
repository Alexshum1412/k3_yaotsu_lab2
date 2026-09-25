#!/usr/bin/env bash
# Моделирование всех заданий в GHDL (VHDL-2008).
# Результаты: build/*.vcd (временные диаграммы) и build/*.log (вывод report).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
B="$ROOT/build"; mkdir -p "$B"
G="ghdl"; OPT="--std=08 --workdir=$B"

run() { # $1 - top, $2 - stop time
  $G -e $OPT "$1"
  $G -r $OPT "$1" --vcd="$B/$1.vcd" --stop-time="$2" 2>&1 | tee "$B/$1.log"
}

# Задание 3.1 - преобразователь кода 2421 -> код Грея
T1="$ROOT/task1_code_converter"
$G -a $OPT "$T1/XOR2.vhd" "$T1/OR2.vhd" "$T1/AND2.vhd" "$T1/device_01.vhd" "$T1/device_01_tb.vhd"
run device_01_tb 200ns

# Задание 3.2 - приоритетный шифратор 10-4
$G -a $OPT "$ROOT/task2_priority_encoder/encoder_12to4.vhd" "$ROOT/task2_priority_encoder/tb_encoder_12to4.vhd"
run tb_encoder_12to4 11us

# Задание 3.3 - мультиплексор 45-1 со стробированием
$G -a $OPT "$ROOT/task3_mux45/mux45_1.vhd" "$ROOT/task3_mux45/tb_mux45_1.vhd"
run tb_mux45_1 3us

# Задание 3.3 (доп.) - MUX/DEMUX с приоритетизацией
$G -a $OPT "$ROOT/task3_extra_mux_demux/mux_demux_prio.vhd" "$ROOT/task3_extra_mux_demux/tb_mux_demux_prio.vhd"
run tb_mux_demux_prio 70us

# Задание 3.4 - нерегулярная логическая схема
$G -a $OPT "$ROOT"/task4_irregular/elements/*.vhd "$ROOT/task4_irregular/circuit_v7.vhd" "$ROOT/task4_irregular/tb_circuit_v7.vhd"
run tb_circuit_v7 500ns
