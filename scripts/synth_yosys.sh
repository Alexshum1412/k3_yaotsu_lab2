#!/usr/bin/env bash
# Синтез всех проектов под ПЛИС Xilinx 7-series (семейство Zynq-7000, xc7z010)
# с помощью Yosys + GHDL-плагин. Отчёты: synth/*_stat.txt, схемы: report/img/*.png
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
S="$ROOT/synth"; IMG="$ROOT/report/img"; mkdir -p "$S" "$IMG"; cd "$S"
EL="$(ls "$ROOT"/task4_irregular/elements/*.vhd | tr '\n' ' ')"
CIRC="$ROOT/task4_irregular/circuit_v7.vhd"
Y() { yosys -q -m ghdl -p "$1"; }

T1="$ROOT/task1_code_converter"
T1F="$T1/XOR2.vhd $T1/OR2.vhd $T1/AND2.vhd $T1/device_01.vhd"
Y "ghdl --std=08 $T1F -e device_01;
   synth_xilinx -family xc7 -flatten -top device_01; tee -q -o device_01_stat.txt stat"
Y "ghdl --std=08 $ROOT/task2_priority_encoder/encoder_12to4.vhd -e encoder_12to4;
   synth_xilinx -family xc7 -flatten -top encoder_12to4; tee -q -o encoder_12to4_stat.txt stat"
Y "ghdl --std=08 $ROOT/task3_mux45/mux45_1.vhd -e mux45_1;
   synth_xilinx -family xc7 -flatten -top mux45_1; tee -q -o mux45_1_stat.txt stat"
Y "ghdl --std=08 $ROOT/task3_extra_mux_demux/mux_demux_prio.vhd -e mux_demux_prio;
   synth_xilinx -family xc7 -flatten -top mux_demux_prio; tee -q -o mux_demux_prio_stat.txt stat"
for A in Structural Behavioral; do
  Y "ghdl --std=08 $EL $CIRC -e circuit_v7 $A;
     synth_xilinx -family xc7 -flatten -top circuit_v7; opt_clean -purge;
     tee -q -o circuit_v7_${A}_stat.txt stat; write_verilog -noattr circuit_v7_${A}_netlist.v"
done
# структурная модель с сохранением иерархии (каждый элемент - отдельный модуль)
Y "ghdl --std=08 $EL $CIRC -e circuit_v7 Structural;
   synth_xilinx -family xc7 -top circuit_v7; tee -q -o circuit_v7_Structural_hier_stat.txt stat"

# схемы
Y "ghdl --std=08 $EL $CIRC -e circuit_v7 Structural; hierarchy -top circuit_v7; proc; opt_clean;
   show -format dot -prefix rtl_struct -notitle circuit_v7"
Y "ghdl --std=08 $EL $CIRC -e circuit_v7 Behavioral;
   synth_xilinx -family xc7 -flatten -top circuit_v7; opt_clean -purge;
   show -format dot -prefix map_beh -notitle circuit_v7"
Y "ghdl --std=08 $T1F -e device_01; hierarchy -top device_01; proc; opt_clean;
   show -format dot -prefix rtl_device_01 -notitle device_01"
Y "ghdl --std=08 $ROOT/task2_priority_encoder/encoder_12to4.vhd -e encoder_12to4;
   synth_xilinx -family xc7 -flatten -top encoder_12to4; opt_clean -purge;
   show -format dot -prefix map_encoder -notitle encoder_12to4"
dot -Tpng -Gdpi=150 -Grankdir=LR rtl_device_01.dot -o "$IMG/rtl_device_01.png"
dot -Tpng -Gdpi=150 -Grankdir=LR map_encoder.dot   -o "$IMG/map_encoder.png"
dot -Tpng -Gdpi=150 -Grankdir=LR rtl_struct.dot -o "$IMG/rtl_struct.png"
dot -Tpng -Gdpi=150 -Grankdir=LR map_beh.dot    -o "$IMG/map_beh.png"
echo "Synthesis done: $S"
