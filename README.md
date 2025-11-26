# PAR-MTDMS-CMOEA: Parallel Multi-Task Dynamic Membrane Computing for Tri-Objective Optimization

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Under_Review-yellow.svg)]()

## Overview

This repository contains the implementation of **PAR-MTDMS-CMOEA** (Parallel Multi-Task Dynamic Membrane System with Constrained Multi-Objective Evolutionary Algorithm), a novel tri-objective optimization framework for IoT edge computing task offloading.

**Paper**: *MTDMS-CMOEA: A Multi-Task Dynamic Membrane Computing Framework for Tri-Objective Optimization of Latency, Energy, and Security in IoT Edge Offloading*

**Author**: Shouheng Tuo

**Journal**: Expert Systems With Applications (Under Review)

---

## Key Features

- **Tri-Objective Optimization**: Simultaneously minimizes latency, energy consumption, and security risk
- **Three-Stage Evolution**: 
  - Stage 1: Parallel membrane exploration (50% iterations)
  - Stage 2: Constraint-aware convergence (30% iterations)
  - Stage 3: Security-aware refinement (20% iterations)
- **Four-Membrane Architecture**: Parallel evolution with different optimization strategies
- **Security-Aware**: Integrates dynamic security policy optimization
- **Parallel Computing**: Supports parallel execution for faster computation

---

## Problem Formulation

### Decision Variables
- **x**: Task offloading decisions (local/edge)
- **f**: Edge server assignment
- **y**: Computing resource allocation
- **z**: Security level assignment (Stage 3)

### Objectives
1. **Latency (f₁)**: Total task completion time
2. **Energy (f₂)**: Total energy consumption
3. **Security Risk (f₃)**: Vulnerability exposure (minimized in Stage 3)

### Constraints
- Resource capacity constraints
- Deadline constraints
- Security compliance requirements

---

## System Requirements

### Required
- MATLAB R2020a or higher
- Data files: `data_10.mat`, `dataOffT.mat`, `dataOfftasks.mat`

### Optional
- Parallel Computing Toolbox (for parallel execution)

---

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/Par_MTDMS_CMOEA.git
cd Par_MTDMS_CMOEA
```

2. Add to MATLAB path:
```matlab
addpath(genpath('Par_MTDMS_CMOEA'));
```

3. Verify data files are present in the root directory.

---

## Quick Start

### Basic Usage

```matlab
% Run with default parameters
PAR_MTDMS_CMOEA_Main;
```

### Custom Parameters

```matlab
% Set parameters
N = 100;              % Population size
iter_max = 1000;      % Maximum iterations
device_count = 30;    % Number of IoT devices
use_parallel = true;  % Enable parallel computing

% Run algorithm
[pop_final, pop_stage2, fes, runtime] = ...
    PAR_MTDMS_CMOEA(N, iter_max, device_count, use_parallel);

% Visualize Pareto front
visualize_pareto_front(pop_final);
```

---

## Algorithm Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    PAR-MTDMS-CMOEA                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Stage 1: Parallel Membrane Evolution (50% iterations)      │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Membrane 1  │  Membrane 2  │  Membrane 3  │  Membrane 4│
│  │ (Constrained)│(Unconstrained)│  (Energy)   │ (Latency) │
│  └────────────────────────────────────────────────────┘    │
│           ↓              ↓              ↓              ↓    │
│                    Exchange & Merge                         │
│                           ↓                                  │
│  Stage 2: Constraint-Aware Refinement (30% iterations)      │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Dynamic constraint handling and convergence        │    │
│  │  Non-dominated sorting and elite preservation       │    │
│  └────────────────────────────────────────────────────┘    │
│           ↓                                                  │
│                                                              │
│  Stage 3: Security-Aware Optimization (20% iterations)      │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Security policy optimization (z-variables)         │    │
│  │  Tri-objective Pareto front extraction              │    │
│  └────────────────────────────────────────────────────┘    │
│                           ↓                                  │
│              Final Pareto Front (f₁, f₂, f₃)                │
└─────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
Par_MTDMS_CMOEA/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── PAR_MTDMS_CMOEA_Main.m            # Main entry point
├── PAR_MTDMS_CMOEA.m                 # Core algorithm implementation
├── visualize_pareto_front.m          # Visualization utility
│
├── core/                              # Core algorithm modules
│   ├── PAR_stage1.m                  # Stage 1: Parallel exploration
│   ├── PAR_stage2.m                  # Stage 2: Constraint handling
│   ├── PAR_stage3.m                  # Stage 3: Security optimization
│   ├── PAR_evolve1.m                 # Membrane 1 evolution
│   ├── PAR_evolve2.m                 # Membrane 2 evolution
│   ├── PAR_evolve3.m                 # Membrane 3 evolution
│   └── PAR_evolve4.m                 # Membrane 4 evolution
│
├── operators/                         # Evolutionary operators
│   ├── OperatorDE_rand_1.m           # DE/rand/1
│   ├── PAR_OperatorDE_best.m         # DE/best/1
│   ├── PAR_OperatorDE_current.m      # DE/current-to-best/1
│   ├── OperatorDE_pbest_1.m          # DE/pbest/1
│   ├── OperatorDE_pbest_1_main.m     # DE/pbest/1 for main tasks
│   └── OperatorSafeDE.m              # DE for security optimization
│
├── selection/                         # Selection mechanisms
│   ├── EnvironmentalSelection.m      # General environmental selection
│   ├── Main_task_EnvironmentalSelection.m     # Main task selection
│   ├── Auxiliray_task_EnvironmentalSelection.m # Auxiliary task selection
│   ├── TournamentSelection.m         # Tournament selection
│   └── nonDominatedSorting.m         # Fast non-dominated sorting
│
├── evaluation/                        # Objective and constraint evaluation
│   ├── get_objective.m               # Bi-objective evaluation (Stage 1-2)
│   ├── get_safe_f_CV.m               # Security objective evaluation (Stage 3)
│   ├── get_f_CV.m                    # Constraint violation calculation
│   ├── CalFitness.m                  # Fitness assignment
│   └── creatsafemodel.m              # Security model creation
│
├── utils/                             # Utility functions
│   ├── init_pop.m                    # Population initialization
│   ├── dividepop.m                   # Population division
│   ├── top.m                         # Top solution extraction
│   ├── top1.m                        # Alternative top extraction
│   ├── gnR1R2R3.m                    # Random index generation
│   └── Neighbor_Pairing_Strategy.m   # Neighbor pairing
│
└── data/                              # Data files
    ├── data_10.mat                   # Device configuration (K=10)
    ├── dataOffT.mat                  # Task offloading parameters
    └── dataOfftasks.mat              # Task characteristics
```

---

## Output Format

The algorithm returns a Pareto front of solutions with the following structure:

```matlab
pop_final: [M × (D+4)] matrix
  - Columns 1:D        : Decision variables (x, f, y, z)
  - Column D+1         : Latency (ms)
  - Column D+2         : Energy (J)
  - Column D+3         : Security Risk (normalized, 0-1)
  - Column D+4         : Constraint Violation
```

Where:
- **M**: Number of Pareto-optimal solutions
- **D**: Problem dimension (depends on device count K)

---

## Example Results

### Small-Scale Problem (K=10 devices)
- **Pareto Front Size**: 15-25 solutions
- **Latency Range**: 0.5-2.0 ms
- **Energy Range**: 20-30 J
- **Security Risk Range**: 0.15-0.45 (lower is better)
- **Runtime**: ~30-60 seconds

### Medium-Scale Problem (K=30 devices)
- **Pareto Front Size**: 20-35 solutions
- **Latency Range**: 1.5-5.0 ms
- **Energy Range**: 70-100 J
- **Security Risk Range**: 0.20-0.50
- **Runtime**: ~2-4 minutes

---

## Performance Tips

1. **Parallel Computing**: Enable `use_parallel=true` for 1.5-2× speedup
2. **Population Size**: Recommended N=100 for K≤30, N=150 for K>30
3. **Iterations**: 1000 iterations sufficient for convergence
4. **Memory**: Ensure sufficient RAM for large-scale problems (K>50)

---

## Citation

If you use this code in your research, please cite:

```bibtex
@article{tuo2025mtdms,
  title={MTDMS-CMOEA: A Multi-Task Dynamic Membrane Computing Framework for Tri-Objective Optimization of Latency, Energy, and Security in IoT Edge Offloading},
  author={Tuo, Shouheng},
  journal={Expert Systems With Applications},
  year={2025},
  note={Under Review}
}
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

**Author**: Shouheng Tuo

For questions or collaboration opportunities, please open an issue on GitHub.

---

## Acknowledgments

This work is supported by research on IoT edge computing optimization and multi-objective evolutionary algorithms.

---

## Version History

- **v1.0.0** (2025-01): Initial release
  - Three-stage tri-objective optimization
  - Four-membrane parallel architecture
  - Security-aware refinement

---

**Note**: This code is currently under review for publication in *Expert Systems With Applications*. Please check back for updates after the review process is complete.
