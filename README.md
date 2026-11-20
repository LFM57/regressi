# Regressi

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS-lightgrey.svg)](#building-from-source)

**Regressi** is a scientific data processing, graphing, and curve-fitting desktop application widely used in physics, chemistry, engineering, and laboratory education.

This repository is a maintained, modern FireMonkey (`FMX` + `TMS FNC`) continuation of **Jean-Michel Millet**'s work, originally created with the **EVARISTE** association and used by thousands of students, teachers, and professionals around the world.

---

## Features

- **Data Tables & Expressions**
  - Multi-page experimental data tables with measurement uncertainties ($\pm \Delta x$)
  - Automatic unit parsing, dimensional consistency checking, and SI prefix scaling
  - Formula editor for derived variables, numerical derivatives, integrals, smoothing, and simulations
- **Scientific Graphing**
  - Multi-curve and multi-page plotting with independent or shared axes
  - Linear, logarithmic, polar, and split-view plots
  - Velocity and acceleration vector overlays, tangent lines, measurement reticles, error ellipses, and image/PDF export
- **Curve Fitting & Differential Equations**
  - Linear and nonlinear regression (Levenberg–Marquardt) with uncertainty estimation and reduced $\chi^2$
  - Built-in physics, electronics, filter, and oscillation models alongside custom user expressions
  - First- and second-order ordinary differential equation (ODE) solvers and residual plots
- **Fourier Analysis**
  - Fast Fourier Transform (FFT) amplitude and phase spectra
  - Windowing functions (Rectangular, Hamming, Blackman, Flat-top), decibel scaling, and sonogram views
- **Statistics**
  - Descriptive statistics (mean, median, 95% confidence interval, standard deviation, coefficient of variation)
  - Histograms with Gaussian, Poisson, and binomial distribution overlays

---

## Download

Pre-built binaries are published on the [Releases](../../releases) page.

---

## Building from Source

### Prerequisites
- **Embarcadero RAD Studio / Delphi** (FireMonkey `FMX`, tested with RAD Studio 13 on Windows 64-bit)
- **TMS FNC Core** and **TMS FNC UI Pack**

### Windows (RAD Studio)
1. Install **TMS FNC Core** and **TMS FNC UI Pack** in RAD Studio and ensure the `TMSFNCUIPack` library paths are configured for your target platform (`Win64` / `Win32`).
2. Open `regressiM.dproj` in RAD Studio.
3. Select the **Release** configuration and **Windows 64-bit** platform, then run **Project → Build regressiM** (or build via `msbuild` on commercial editions).
4. The compiled executable is generated in `Win64\Release\`.

---

## Credits

Regressi was created and developed by **Jean-Michel Millet** and the **EVARISTE** association. All credit for the original software, mathematical algorithms, and decades of dedication to science education goes to **Jean-Michel Millet**.

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
