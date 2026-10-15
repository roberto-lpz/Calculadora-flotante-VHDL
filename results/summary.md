# Simulation results - ADDMult

**Status: PASS** (802/802 tests passed)

| Operation      | Tests | Failures | Max relative error |
|----------------|-------|----------|--------------------|
| Addition       | 401 | 0 | 1.84e-07 |
| Multiplication | 401 | 0 | 2.63e-07 |
| **Total**      | 802 | 0 | 2.63e-07 |

## Method

- Test vectors: `vectores.txt` (random operands, integer part up to 10^6, plus fixed cases such as 3.5 and 2.25).
- Reference: Python `float` arithmetic on `(int + frac/10000)` with the given signs.
- Tolerance: 1e-06 relative error. For additions the error is measured relative to the larger operand, so near-total cancellations are not penalised by truncation.
- Results that reach 2^32 or more are expected to saturate to infinity (by design).
- The design truncates (does not round), so errors of about 1-2 ULP of float32 are expected.

## Reproduce

```
ghdl -a --std=08 IEEE754ConvComb.vhd ADDMult.vhd tb_ADDMult.vhd
ghdl -e --std=08 tb_ADDMult
ghdl -r --std=08 tb_ADDMult
python3 compare.py
```

## Environment

- Simulator: GHDL 4.1.0 (Ubuntu 4.1.0+dfsg-0ubuntu2.1) [Dunoon edition]
- Date: 2026-10-15

Per-test detail: [`comparison.csv`](comparison.csv).
