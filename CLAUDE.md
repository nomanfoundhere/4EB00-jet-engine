# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Group 42's 4EB00 Thermodynamics (TU/e) jet engine assignment: a MATLAB cycle analysis of a turbojet (stations 1 to 6: diffuser, compressor, combustor, turbine, nozzle) with every species property computed from NASA polynomials. `README.md` is the working tracker: changes to the course files, the to-do list, the operating point, the method, the grading rules, report contents, deadlines, and the verbatim Canvas brief. Read it first and keep it current.

Repo: github.com/nomanfoundhere/4EB00-jet-engine (public; the lecturer checks submissions for copying).

## Running

MATLAB only; there is no build or test suite. The script is run whole (it starts with `clear all`), so there is no partial entry point.

```matlab
addpath('<repo root>'); Assignment     % from any MATLAB current folder
```

Calling it by name from another folder is the meaningful check: `run('Assignment.m')` temporarily changes into the script's folder and would hide path bugs. Sanity output for the diffuser with the group 42 inputs: `T2 = 319.78 K`, `P2 = 125.11 kPa`, identical to within about 1 mK between the interpolation and bisection methods.

## How the code fits together

- `Assignment.m` is the lecturer's skeleton, adapted. It resolves `General/` relative to its own location (`mfilename('fullpath')`, lines 4–7), sets the globals `Runiv` and `Pref`, loads `NasaThermalDatabase` (struct array `Sp`, 56 species), and selects species with `myfind` in the fixed order `{cFuel,'O2','CO2','H2O','N2'}`. Every composition vector (`Xair`, `Yair`, `Yfuel`) and property matrix (`hia`, `sia`) relies on that order.
- Mixture properties are mass-fraction-weighted sums: `h_mix = Y * h_i'`. `HNasa` includes the formation enthalpy, which is how combustion enters the energy balance with no heating value. `SNasa` returns only the temperature part of the entropy; the pressure part is `-Rg*log(P/Pref)`.
- The diffuser (the lecturer's worked example, not graded) is solved twice: interpolation on the tabulated `h(T)` over `TR = 200:1:3000` K, and bisection. Group work starts at line 142 (`%% Here starts your part`) with the compressor, combustor, turbine, and nozzle, using either method.
- `General/*.m` (CpNasa, CvNasa, HNasa, UNasa, SNasa, myfind) are course-supplied and unchanged. They return per-kg values (`Runiv/Sp.Mass`, with `Mass` in kg/mol).

## Rules that constrain the model

- No Poisson relations (`pV^γ = const`) and no lower heating value. Isentropic steps come from the entropy balance (`Δs_thermal = Rg ln(P2/P1)`), and heat release from the formation enthalpies.
- Lecturer's rulings (course discussion board): all isentropic efficiencies are 1, and the combustor is isobaric (`P4 = P3`).
- `T4` is computed from the combustor energy balance at the given `AF` rather than prescribed as in Turns. With H2 fuel the products are H2O plus excess O2 and N2; CO2 stays in the species list with zero mass fraction because Table 2 of the report has a CO2 row.
- Group 42 inputs (`Groep042.txt`): H2, `Tamb` 300 K, `Pamb` 100 kPa, `P3/P2` 9, `mfurate` 0.58 kg/s, `AF` 170.35, `v1` 200 m/s. These are set on lines 19–20 of `Assignment.m`.

## Gotchas

- `Pref = 1.01235e5` is labelled "1 atm" but has transposed digits (1 atm = 1.01325e5). It cancels in every entropy difference, so leave the lecturer's value as it is unless absolute entropies are reported.
- The NASA functions print a warning and return zeros if the global `Runiv` is unset. Any new function that calls them needs `global Runiv`.
- The diffuser's bisection upper bracket `TH = 1000` K will likely be too low for the combustor. Choose the bracket per stage.
- The turbine carries air plus fuel while the compressor carries only air: the work balance is `m_air (h3 - h2) = (m_air + m_fuel)(h4 - h5)`.

## Conventions

- MATLAB style follows the course files, not a general style: several statements packed on one line with `;`, terse names (`hia`, `SpS`, `NSp`), `%%` cell headers, short trailing comments aligned near column 77, `for i=1:NSp` loops over species, and `fprintf` stage tables like the diffuser's.
- Any edit to a course-supplied file gets recorded, with line numbers, in the README's "Changes to the course files" section. Keep the README's section order (working sections on top, lookup material below) and its anchor links intact.
- Deliverables for Canvas: `Group42.zip` containing `Group42_report.pdf` (exported from `Group42_report.docx`, which must follow the course template) and `Group42_scripts.zip` (runnable when unzipped). Deadline 9 October 2026, late until 16 October 2026 with the grade capped at 8. Leave names and student numbers in the report empty unless the user supplies them.

## Status (2026-09-25)

Done: repo set up, group 42 inputs in `Assignment.m`, diffuser verified, conditions table filled in `Group42_report.docx`, lecturer's rulings recorded. Next: compressor (stage 2→3), then combustor (solve `T4` at `P4 = P3`), turbine, nozzle (exit velocity at `P6 = Pamb`); then fill Table 1 (P, T, v at states 1 to 6) and Table 2 (compositions, `Rg`, equivalence ratio). Open question: the grading rubric (asked on the course discussion board, no answer yet).
