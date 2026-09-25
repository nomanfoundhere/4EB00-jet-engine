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

Known inputs: `P1 = Pamb`, `T1 = Tamb`, `v1`, `P3/P2` and `P6 = Pamb`. Two further conditions come from the lecturer on the course discussion board:

- **Isentropic efficiencies are 1.** Every component is an ideal machine, so each compression and expansion is isentropic: `s_out = s_in`, with no efficiency correction applied afterwards.
- **The combustor is isobaric:** `P4 = P3`.

Each control volume is closed with conservation of mass, energy and entropy, for example in the diffuser:

- energy: `h2(T2) = h1(T1) + v1^2/2`
- isentropic step: `s2(T2,P2) - s1(T1,P1) = 0`, where the temperature part of `s` comes from `SNasa` and the pressure part is `-Rg ln(P2/P1)`

Two differences from Turns decide the grade:

- **No engineering shortcuts.** Poisson relations (`pV^γ = const`) and the lower heating value must not appear. The isentropic relation comes from the entropy balance, and the heat release follows from the formation enthalpies built into the NASA `h`.
- **`T4` is computed, not given.** Turns prescribes the turbine inlet temperature, but here it follows from the combustor energy balance at the given `AF`, with the product composition obtained from H2 + air stoichiometry (water and excess O2/N2, no CO2).

## Deliverables and deadlines

Weight: 30% of the final 4EB00 grade. One zip per group, `Group42.zip`, submitted to Canvas only, containing:

- `Group42_report.pdf`: compact report explaining the model and results, strictly following the Word template (`GroupSettings/4EB00Special Topic Jet Engine Report Template 2026.docx`)
- `Group42_scripts.zip`: the MATLAB model, runnable as soon as it is unzipped

Canvas spells the names with `Group`. The 2025 info sheet in this repo uses `Groep`, so Canvas takes precedence.

| Deadline | Date |
|---|---|
| Regular submission | 9 October 2026 |
| Late submission (grade capped: `min(grade, 8)`) | 16 October 2026 |

The template fixes what the report contains:

- the group settings table
- **Table 1**: `P` (kPa), `T` (K) and `v` (m/s) at states 1 to 6
- for each component, a code snippet with its line numbers and a procedure explaining the equations solved and where they are implemented. The diffuser page is a worked example and is not graded: graded work starts at the compressor. The combustor takes two snippets, one for the composition before and after combustion and one for the thermodynamics.
- **Table 2**: mass fractions of fuel, O2, N2, CO2 and H2O before and after the combustor, the specific gas constant `Rg` of each mixture, plus `AF` and the equivalence ratio

Dates are confirmed by both Canvas and Lecture 2 (2026). The 2025 info sheet in this repo still lists 7 and 14 October.

### Assignment description (Canvas, verbatim)

> The submission should be a single zip-file containing named GroupNR.zip containing
>
> GroupNr_report.pdf<br>
> GroupNr_scripts.zip (containing a working script when unzipped).<br>
> Submit this to Canvas only.
>
> Stick to the template provided for the report and please use the naming convention as mentioned above.  Here is the template: 4EB00Special Topic Jet Engine Report Template 2026.docxDownload 4EB00Special Topic Jet Engine Report Template 2026.docx
>
> Note that each group will get different engine settings (parameters like fuel, ambient pressure etc..). These settings can be found in this zip-file: GroupSettings.zipDownload GroupSettings.zip
>
> The assignment will make up 30% of your final grade for the 4EB00 course. There is a regular due date (9th of October) and a late due date (16 October). If you submit late, the grade will be computed according to Grade = min(8,ReportGrade), or in words it will be at most an 8.

## Files

- `GroupSettings/Groep042.txt`: the group's operating point.
- `GroupSettings/4EB00 Special Topic Jet Engine Info 2025.pdf` (2 pp.): assignment brief, covering relevant Turns sections, MATLAB requirement, groups of two, submission format and grading of late work.
- `GroupSettings/Lecture 1 Ideal Gas Mixtures 2026.pdf` (35 pp.): mole and mass fractions, Dalton's law, mixture properties as mass-weighted sums (`u_mix = Σ Y_i u_i`), NASA polynomials with formation enthalpy included in `h_i(T)`, and warm-up exercises: species enthalpies at `Tref` (Ex. 1), air properties (Ex. 2), constant-volume explosion of C2H2/air (Ex. 3), adiabatic flame temperature (Ex. 4).
- `GroupSettings/Lecture 2 Cycle analysis 2026.pdf` (15 pp.): station layout of the engine, the given quantities, the diffuser worked through as a template for the other components, the NASA function list (`CpNasa`, `CvNasa`, `HNasa`, `UNasa`, `SNasa`), and the deadlines.
- `GroupSettings/4EB00Special Topic Jet Engine Report Template 2026.docx`: the Word template the report must follow (see above).
- `GroupSettings/Assignment.m`: skeleton for the cycle script. It sets up air and fuel compositions and solves the diffuser twice, by interpolation on an `h(T)` table and by bisection. It runs on the group 42 conditions with H2 as the fuel (diffuser result: `T2 = 319.78 K`, `P2 = 125.11 kPa`). The compressor, combustor, turbine and nozzle are left to the group.
- `GroupSettings/General/`: NASA polynomial database (`NasaThermalDatabase.mat`, 56 species) and the property functions `CpNasa`, `CvNasa`, `HNasa`, `UNasa`, `SNasa`, plus the lookup helper `myfind`. `Assignment.m` finds this folder relative to its own location, so it runs from any MATLAB current folder.

## To do

- [x] Get the `General` folder from Canvas and make `Assignment.m` find it regardless of MATLAB's current folder.
- [x] Replace the Turns example conditions in `Assignment.m` with the group 42 values and H2 as the fuel.
- [x] Find the isentropic efficiency of each component: 1 for all (lecturer, course discussions).
- [x] Ask in the course discussions how the report is graded. None of the files here includes a rubric, only the template.
- [ ] Build the cycle script: diffuser → compressor → combustor (solve for `T4` at `P4 = P3`) → turbine (work balance with the compressor) → nozzle (exit velocity at `P6 = Pamb`).
- [ ] Check mass, energy and entropy balances per control volume, then fill Table 1 (states 1–6) and Table 2 (compositions, `Rg`, equivalence ratio).
- [ ] Write the report in the template, citing line numbers for every snippet, and package `Group42_report.pdf` and `Group42_scripts.zip` into `Group42.zip` for Canvas.
