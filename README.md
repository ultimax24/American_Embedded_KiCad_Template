# American Embedded KiCad Template

<p align="center">
  <img src="meta/logo.png" alt="American Embedded Logo">
</p>

This repository contains a KiCad project template provided by American Embedded. It is designed to be a starting point for new electronic designs, pre-configured with common settings, layers, and manufacturing outputs.

## Features

*   **Standardized Layers:** Pre-defined layer setup for consistency across projects.
*   **Manufacturing Outputs:** Includes a `Build.kicad_jobset` file for generating common manufacturing files like Gerbers, drill files, BOMs, and 3D models.
*   **Build Script:** A `build.sh` script is provided to automate the process of running the jobset and formatting the component placement file.
*   **Project Structure:** A clean and organized directory structure.

## Usage

1.  Use this repository as a template for a new KiCad project.
2.  Rename the `Template.kicad_*` files to match your project name.
3.  Modify the schematic and PCB as needed for your design.
4.  Run the build script to generate manufacturing outputs.

## Building

To generate all the output files, run the provided shell script:

```bash
./build.sh
```

This script will:
1.  Execute the KiCad CLI to run the jobs defined in `Build.kicad_jobset`.
2.  Place all generated files into the `build/` directory.
3.  Convert the raw component placement file into a more user-friendly CSV format (`build/positions.csv`).

The `Build.kicad_jobset` is configured to output:
- ERC and DRC reports
- PDF of the schematic
- BOMs for JLCPCB and NextPCB
- Gerbers and drill files (in a zip archive)
- 3D model (STEP file)
- Component position files
