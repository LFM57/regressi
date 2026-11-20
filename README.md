# Regressi

**A community-maintained FireMonkey (`FMX` + `TMS FNC`) continuation of [Jean-Michel Millet](https://www.jeanmillet.org/)'s scientific data analysis and curve-fitting software.**

> **Credits & Attribution**
> Regressi was originally created and developed for decades by **Jean-Michel Millet** ([jeanmillet.org](https://www.jeanmillet.org/)) and the **EVARISTE** association. It continues to help thousands of French students, teachers, and professionals around the world every day. All credit for the original software, mathematical engine, and design belongs to **Jean-Michel Millet**, and the GNU GPL v3 license is held in his name.

---

## Overview

Regressi is a desktop application for experimental physics, chemistry, and engineering data analysis, designed for classroom labs and scientific measurements.

### Core Capabilities
- **Data & Expressions (`valeurs`)**: Multi-page experimental tables, uncertainty propagation ($\pm \Delta x$), unit checking and automatic SI prefix scaling, derived variables, numerical derivatives, integrals, smoothing, and simulation expressions.
- **Graphing (`graphker`, `axes`)**: Multi-curve and multi-page plotting, dual/multiple Y-axes, log/polar/split plots, velocity/acceleration vectors, tangent/reticle/equivalence tools, error ellipses, and image/PDF export.
- **Curve Fitting & Modeling (`modele`, `modelegr`, `systdiff`)**: Linear and nonlinear regression (Levenberg–Marquardt), predefined physics/electronics/filter/oscillation models, custom expressions, 1st- and 2nd-order ODE solvers, residual plots, and reduced $\chi^2$ evaluation.
- **Fourier Analysis (`graphfft`, `fft`)**: FFT amplitude/phase spectra, windowing functions (Rectangular, Hamming, Blackman, Flat-top), dB scaling, and sonogram visualization.
- **Statistics (`optStat`, `statCalc`)**: Descriptive statistics (mean, median, 95% confidence interval, standard deviation, CV), histograms, Gaussian curve overlay, Poisson and binomial distributions.

---

## Current Status (`v1.8.0-beta`)

This maintained fork focuses on stabilizing and modernizing the FireMonkey / TMS FNC port (`FMX` + `TTMSFNCGrid` / `TTMSFNCColorPicker`).

**Highlights in `v1.8.0-beta`:**
- Fixed `StatTab` layout overlaps (unnested `ListeNom`, `StatGrid`, `OptionStatBtn`, added `SplitterStat`).
- Moved the `Radian`/`Degré` angle toggle (`TrigoBtn`) into the status bar so it stays visible on single-page files.
- Fixed `ModeleToolBar` button clipping and `ParamGrid` column count, editing events, and off-by-one indexing bugs.
- Re-wired broken `TTMSFNCGrid` events in the **Grandeurs** tables (`GridVariab`, `GridParam`), fixed `valeurs.pas` UTF-8 encoding, repaired the 24-letter Greek palette (`GrecGrid`), and added splitters to the Expressions toolbox.
- Fixed crashes, overlapping controls, wrong default buttons, missing preview curves, and non-working `Help` buttons across 15 configuration dialogs (`PropCourbe`, `optModele`, `optline`, `coordphys`, `choixmodele`, `optcolordlg`, `ChoixParamAnim`, `selpage`, `graphfft`, `optfft`, `newvar`, `options`, `varkeyb`, etc.).
- Disabled `DesignTimeSampleData` on all `TTMSFNCGrid` instances and cleaned up English/French UI localization entries.

---

## Building from Source

### Prerequisites
- **Embarcadero RAD Studio / Delphi** (FireMonkey `FMX`, tested with RAD Studio 13 / `37.0` on Windows 64-bit)
- **TMS FNC Core** and **TMS FNC UI Pack** (for `TTMSFNCGrid`, `TTMSFNCColorPicker`, etc.)

### Build Steps (Windows)
1. Install **TMS FNC Core** and **TMS FNC UI Pack** in RAD Studio.
   - Make sure your Delphi **Library Path** (*Tools → Options → Language → Delphi → Library*, `Win64`) includes the `TMSFNCUIPack` and `TMSFNCUIPack\Win64` folders (avoid mixing separate `TMSFNCCore` DCUs ahead of `TMSFNCUIPack` if `TMSFNCUIPack` already bundles Core DCUs).
2. Open `regressiM.dproj` in RAD Studio.
3. Select **Release** / **Windows 64-bit** and run **Project → Build regressiM** (or use `msbuild regressiM.dproj /t:Build /p:Config=Release;Platform=Win64` on commercial Delphi editions).
4. The compiled binary is output to `Win64\Release\regressiM.exe`.

> **Note on Community Edition**: RAD Studio Community Edition disables `dcc64.exe` command-line builds (`This version of the product does not support command line compiling`), so compile from inside the RAD Studio IDE.

---

## License

This project is licensed under the **GNU General Public License v3.0 (GNU GPL v3)** — in the name of **Jean-Michel Millet** ([jeanmillet.org](https://www.jeanmillet.org/)).
The `LICENSE` file will be added to this repository shortly.
