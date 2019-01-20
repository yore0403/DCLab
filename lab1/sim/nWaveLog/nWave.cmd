wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/team06/b05901084/lab1/sim/Lab1_test.fsdb}
wvSelectGroup -win $_nWave1 {G1}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Top_test"
wvGetSignalSetScope -win $_nWave1 "/Top_test/dut/top0"
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Top_test/dut/top0/Q_r\[15:0\]} \
{/Top_test/dut/top0/Q_w\[15:0\]} \
{/Top_test/dut/top0/clk} \
{/Top_test/dut/top0/count_r\[31:0\]} \
{/Top_test/dut/top0/count_w\[31:0\]} \
{/Top_test/dut/top0/i_clk} \
{/Top_test/dut/top0/i_rst} \
{/Top_test/dut/top0/i_start} \
{/Top_test/dut/top0/my_state\[1:0\]} \
{/Top_test/dut/top0/next_state\[1:0\]} \
{/Top_test/dut/top0/o_random_out\[3:0\]} \
{/Top_test/dut/top0/seed_r\[15:0\]} \
{/Top_test/dut/top0/seed_w\[15:0\]} \
{/Top_test/dut/top0/temp_r\[3:0\]} \
{/Top_test/dut/top0/temp_w\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 )} 
wvSetPosition -win $_nWave1 {("G1" 15)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoom -win $_nWave1 184272.053977 2471787.206792
wvZoom -win $_nWave1 1329051.755117 1560051.944812
wvZoom -win $_nWave1 1388504.887049 1413483.459840
wvZoom -win $_nWave1 1399331.167481 1400603.534460
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoom -win $_nWave1 3543425.504690 3677325.357597
wvZoom -win $_nWave1 3596315.348287 3608161.715970
wvZoom -win $_nWave1 3600168.858417 3601566.285168
