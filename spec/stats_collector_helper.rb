def fake_free(mem_used=200, mem_free=56, swap_used=50, swap_free=50)
  ("             total       used       free     shared    buffers     cached\n" +
  "Mem:           #{mem_used + mem_free}        #{mem_used}         #{mem_free}          0          4        110\n" +
  "Swap:          #{swap_used + swap_free}        #{swap_used}         #{swap_free}\n").split(/\n/)
end

def fake_vmstat(cpu_idle=50)
  ("procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----\n" +
  "r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa\n" +
  "1  0  10976  50992   4900 113188    1    2   109   244  101  183 11 10 77  1\n" +
  "0  0  10976  50992   4900 113188    0    0     0     0 8366  315 10  5 #{cpu_idle} 0\n").split(/\n/)
end
