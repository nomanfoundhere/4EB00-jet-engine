# 4EB00 Jet Engine Assignment

Group 42 assignment for 4EB00 Thermodynamics (TU/e): cycle analysis of a turbojet in MATLAB, with every species property computed from NASA polynomials rather than the constant-cp models used in Turns.

## Group 42 operating point

From `GroupSettings/Groep042.txt`:

| Parameter | Value |
|---|---|
| Fuel | H2 |
| Ambient temperature `Tamb` | 300 K |
| Ambient pressure `Pamb` | 100 000 Pa |
| Compressor pressure ratio `P3/P2` | 9 |
| Fuel mass flow `mfurate` | 0.58 kg/s |
| Air/fuel ratio `AF` (m_air / m_fuel) | 170.35 |
| Flight speed `v1` | 200 m/s |

Settings differ per group, and the lecturer checks submitted code for copying.

## The task

A working MATLAB script that follows the control-volume analysis of Turns (1st ed. Section 5.2b and pp. 551–554; 2nd ed. Section 9.4c and pp. 556–560) station by station:

| Stations | Component |
|---|---|
| 1 → 2 | Diffuser |
| 2 → 3 | Compressor |
| 3 → 4 | Combustor |
| 4 → 5 | Turbine (drives the compressor through the shaft) |
| 5 → 6 | Nozzle |

Known inputs: `P1 = Pamb`, `T1 = Tamb`, `v1`, `P3/P2`, the isentropic efficiency of each component, and `P6 = Pamb`. Each control volume is closed with conservation of mass, energy and entropy, for example in the diffuser:

- energy: `h2(T2) = h1(T1) + v1^2/2`
- isentropic step: `s2(T2,P2) - s1(T1,P1) = 0`, where the temperature part of `s` comes from `SNasa` and the pressure part is `-Rg ln(P2/P1)`

Two differences from Turns decide the grade:

- **No engineering shortcuts.** Poisson relations (`pV^γ = const`) and the lower heating value must not appear. The isentropic relation comes from the entropy balance, and the heat release follows from the formation enthalpies built into the NASA `h`.
- **`T4` is computed, not given.** Turns prescribes the turbine inlet temperature, but here it follows from the combustor energy balance at the given `AF`, with the product composition obtained from H2 + air stoichiometry (water and excess O2/N2, no CO2).

## Deliverables and deadlines

One zip per group, submitted online, containing:

- `Groep42_report.pdf`: compact report explaining the model and results, strictly following the Word template on Canvas
- `Groep42_scripts.zip`: the MATLAB model, runnable as soon as it is unzipped

| Deadline | Date |
|---|---|
| Regular submission | 9 October 2026 |
| Late submission (grade capped: `min(grade, 8)`) | 16 October 2026 |

Dates come from Lecture 2 (2026). The info sheet in this repo is the 2025 edition and still lists 7 and 14 October.

## Files

- `GroupSettings/Groep042.txt`: the group's operating point.
- `GroupSettings/4EB00 Special Topic Jet Engine Info 2025.pdf` (2 pp.): assignment brief, covering relevant Turns sections, MATLAB requirement, groups of two, submission format and grading of late work.
- `GroupSettings/Lecture 1 Ideal Gas Mixtures 2026.pdf` (35 pp.): mole and mass fractions, Dalton's law, mixture properties as mass-weighted sums (`u_mix = Σ Y_i u_i`), NASA polynomials with formation enthalpy included in `h_i(T)`, and warm-up exercises: species enthalpies at `Tref` (Ex. 1), air properties (Ex. 2), constant-volume explosion of C2H2/air (Ex. 3), adiabatic flame temperature (Ex. 4).
- `GroupSettings/Lecture 2 Cycle analysis 2026.pdf` (15 pp.): station layout of the engine, the given quantities, the diffuser worked through as a template for the other components, the NASA function list (`CpNasa`, `CvNasa`, `HNasa`, `UNasa`, `SNasa`), and the deadlines.
- `GroupSettings/Exercise1Start.m`: starter script for Exercise 1. It loads `NasaThermalDatabase` and evaluates `HNasa` for O2 and O.

## To do

- [ ] Get the `General` folder from Canvas (`NasaThermalDatabase.mat`, `HNasa`, `SNasa`, `CpNasa`, `myfind`, ...) and replace the hard-coded `addpath` in `Exercise1Start.m`, which points to the lecturer's Dropbox.
- [ ] Get the report template from Canvas, along with the isentropic efficiencies if they are not in the template.
- [ ] Work through Exercises 1–4 to check the NASA functions against the answers in Lecture 1.
- [ ] Build the cycle script: diffuser → compressor → combustor (solve for `T4`) → turbine (work balance with the compressor) → nozzle (exit velocity at `P6 = Pamb`).
- [ ] Check mass, energy and entropy balances per control volume, and report thrust and efficiencies.
- [ ] Write the report in the Canvas template and package `Groep42_report.pdf` and `Groep42_scripts.zip`.
