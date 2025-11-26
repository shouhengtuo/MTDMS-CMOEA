# Project Structure - PAR-MTDMS-CMOEA

This document describes the organization and purpose of all files in the repository.

---

## Root Directory

```
Par_MTDMS_CMOEA/
├── README.md                          # Main documentation
├── LICENSE                            # MIT License
├── USER_GUIDE.md                      # Detailed usage guide
├── QUICK_REFERENCE.md                 # Quick reference card
├── PROJECT_STRUCTURE.md               # This file
│
├── PAR_MTDMS_CMOEA_Main.m            # Main entry point (run this!)
├── PAR_MTDMS_CMOEA.m                 # Core algorithm implementation
├── visualize_pareto_front.m          # Visualization utility
├── Example_Usage.m                    # Example script
├── Verify_Installation.m              # Installation verification
│
├── core/                              # Core algorithm stages
├── operators/                         # Evolutionary operators
├── selection/                         # Selection mechanisms
├── evaluation/                        # Objective/constraint evaluation
├── utils/                             # Utility functions
└── data/                              # Data files
```

---

## Core Modules (`core/`)

Contains the three-stage evolution logic.

| File | Description | Called By |
|------|-------------|-----------|
| `PAR_stage1.m` | Stage 1: Multi-task exploration | `PAR_MTDMS_CMOEA.m` |
| `PAR_stage2.m` | Stage 2: Constraint-aware convergence | `PAR_MTDMS_CMOEA.m` |
| `PAR_stage3.m` | Stage 3: Security-aware refinement | `PAR_MTDMS_CMOEA.m` |
| `PAR_evolve1.m` | Membrane 1 evolution (constrained) | `PAR_stage1.m`, `PAR_stage2.m` |
| `PAR_evolve2.m` | Membrane 2 evolution (unconstrained) | `PAR_stage1.m`, `PAR_stage2.m` |
| `PAR_evolve3.m` | Membrane 3 evolution (energy-focused) | `PAR_stage1.m`, `PAR_stage2.m` |
| `PAR_evolve4.m` | Membrane 4 evolution (latency-focused) | `PAR_stage1.m`, `PAR_stage2.m` |

**Workflow:**
```
PAR_MTDMS_CMOEA
    ├─> PAR_stage1 ──> [PAR_evolve1, PAR_evolve2, PAR_evolve3, PAR_evolve4]
    ├─> PAR_stage2 ──> [PAR_evolve1, PAR_evolve2, PAR_evolve3, PAR_evolve4]
    └─> PAR_stage3 ──> Security optimization
```

---

## Operators (`operators/`)

Differential Evolution (DE) operators for offspring generation.

| File | Description | Strategy | Used In |
|------|-------------|----------|---------|
| `OperatorDE_rand_1.m` | Random-based DE | DE/rand/1 | PAR_evolve2 |
| `PAR_OperatorDE_best.m` | Best-based DE | DE/best/1 | PAR_evolve1 |
| `PAR_OperatorDE_current.m` | Current-to-best DE | DE/current-to-best/1 | PAR_evolve3, PAR_evolve4 |
| `OperatorDE_pbest_1.m` | Pbest-based DE (auxiliary) | DE/pbest/1 | Auxiliary tasks |
| `OperatorDE_pbest_1_main.m` | Pbest-based DE (main) | DE/pbest/1 | Main tasks |
| `OperatorSafeDE.m` | Security-aware DE | Custom | PAR_stage3 |

**Notes:**
- Different operators suit different membrane types
- `OperatorSafeDE.m` specialized for discrete security levels

---

## Selection (`selection/`)

Environmental selection and fitness assignment mechanisms.

| File | Description | Purpose |
|------|-------------|---------|
| `EnvironmentalSelection.m` | General selection | Combines parents and offspring |
| `Main_task_EnvironmentalSelection.m` | Main task selection | Specialized for main tasks |
| `Auxiliray_task_EnvironmentalSelection.m` | Auxiliary task selection | Specialized for auxiliary tasks |
| `TournamentSelection.m` | Tournament selection | Parent selection for DE |
| `nonDominatedSorting.m` | Non-dominated sorting | Pareto ranking (NSGA-II style) |

**Selection Flow:**
```
Population + Offspring
    ├─> nonDominatedSorting (rank solutions)
    ├─> EnvironmentalSelection (select next generation)
    └─> Return N best solutions
```

---

## Evaluation (`evaluation/`)

Objective function and constraint violation calculations.

| File | Description | Objectives | Used In |
|------|-------------|------------|---------|
| `get_objective.m` | Bi-objective evaluation | Latency, Energy | Stage 1, 2 |
| `get_safe_f_CV.m` | Security evaluation | Security cost, Risk | Stage 3 |
| `get_f_CV.m` | General constraint check | All constraints | Multiple |
| `CalFitness.m` | Fitness assignment | Scalar fitness | Selection |
| `creatsafemodel.m` | Security model creation | Task offloading count | Stage 3 |

**Objective Structure:**
- **Stage 1-2**: `[Latency, Energy, CV]`
- **Stage 3**: `[Security_Cost, Security_Risk, CV]`
- **Final**: `[Latency, Energy, Risk, CV]` (tri-objective)

---

## Utils (`utils/`)

General utility functions.

| File | Description | Purpose |
|------|-------------|---------|
| `init_pop.m` | Population initialization | Random solutions within bounds |
| `dividepop.m` | Population division | Split main/auxiliary tasks |
| `top.m` | Non-dominated extraction | Get Pareto front from population |
| `top1.m` | Alternative extraction | Similar to `top.m` |
| `gnR1R2R3.m` | Random index generation | For DE operator |
| `Neighbor_Pairing_Strategy.m` | Neighbor pairing | Task pairing for evolution |

---

## Data (`data/`)

Problem instance data files.

| File | Description | Format |
|------|-------------|--------|
| `data_10.mat` | Device configuration | MATLAB struct/array |
| `dataOffT.mat` | Offloading parameters | Task characteristics |
| `dataOfftasks.mat` | Task specifications | Task types and requirements |

**Note:** File names determined by device count (K).  
For K=30, algorithm looks for `data_30.mat` (if available).

---

## Main Scripts

### `PAR_MTDMS_CMOEA_Main.m`
**Purpose:** Main entry point for running the algorithm  
**Features:**
- Configurable parameters
- Automatic visualization
- Result saving
- Progress reporting

**Usage:**
```matlab
PAR_MTDMS_CMOEA_Main;  % Run with defaults
```

### `PAR_MTDMS_CMOEA.m`
**Purpose:** Core algorithm implementation  
**Inputs:** `(N, iter_max, device_count, use_parallel)`  
**Outputs:** `[pop_final, pop_stage2, fes, runtime]`  

**Algorithm Flow:**
1. Initialize four membrane populations
2. Stage 1: Parallel exploration (50%)
3. Stage 2: Constraint-aware convergence (30%)
4. Stage 3: Security refinement (20%)
5. Return tri-objective Pareto front

### `visualize_pareto_front.m`
**Purpose:** Generate publication-quality visualizations  
**Outputs:**
- 3D Pareto front (scatter plot)
- 2D projections (3 plots)
- Objective distributions (histograms)

**Saved Files:**
- `Pareto_Front_3D.fig/png`
- `Pareto_Front_2D_Projections.fig/png`
- `Objective_Distributions.fig/png`

### `Example_Usage.m`
**Purpose:** Demonstrate various use cases  
**Includes:**
- Quick test (K=10, 500 iter)
- Standard run (K=30, 1000 iter)
- Large-scale (K=50, 1500 iter)
- Results analysis
- Save/load examples

### `Verify_Installation.m`
**Purpose:** Verify correct installation  
**Checks:**
1. MATLAB version (R2020a+)
2. Core functions present
3. Data files accessible
4. Parallel toolbox availability
5. Quick functional test

---

## Documentation Files

### `README.md`
- Project overview
- Key features
- Installation instructions
- Quick start guide
- Citation information

### `USER_GUIDE.md`
- Detailed usage instructions
- Advanced examples
- Troubleshooting
- FAQ
- Performance tips

### `QUICK_REFERENCE.md`
- One-page quick reference
- Common commands
- Recommended settings
- Quick examples

### `LICENSE`
- MIT License
- Citation requirement

---

## File Dependencies

### High-Level Dependencies
```
PAR_MTDMS_CMOEA_Main
    └─> PAR_MTDMS_CMOEA
            ├─> core/* (PAR_stage1/2/3, PAR_evolve1/2/3/4)
            ├─> operators/* (OperatorDE_*, OperatorSafeDE)
            ├─> selection/* (EnvironmentalSelection, nonDominatedSorting, etc.)
            ├─> evaluation/* (get_objective, get_safe_f_CV, CalFitness, etc.)
            ├─> utils/* (init_pop, top, dividepop, etc.)
            └─> data/* (data_10.mat, dataOffT.mat, dataOfftasks.mat)
```

### Critical Dependencies
- All `core/*` files require `operators/*`, `selection/*`, `evaluation/*`, `utils/*`
- All modules require `data/*` files
- Visualization requires MATLAB plotting functions

---

## Adding New Components

### Add New Operator
1. Create in `operators/` directory
2. Follow signature: `offspring = NewOperator(pop, parent1, parent2, parent3)`
3. Update relevant `PAR_evolve*.m` file

### Add New Selection Method
1. Create in `selection/` directory
2. Follow signature: `[Next, fitness] = NewSelection(Q, Q_CV, N, ...)`
3. Update `PAR_stage*.m` if needed

### Add New Data File
1. Place in `data/` directory
2. Name as `data_K.mat` (K = device count)
3. Ensure format matches existing files

---

## Code Conventions

### Naming
- **Functions:** `PascalCase` or `camelCase`
- **Variables:** `snake_case` or `camelCase`
- **Constants:** `UPPER_CASE`
- **File names:** Match main function name

### Comments
- Header: Function purpose, inputs, outputs
- Inline: Explain complex logic
- Section markers: `%%` for major sections

### Global Variables
- `fes`: Function evaluation counter (used across modules)

---

## Version Information

**Current Version:** 1.0.0  
**Release Date:** 2025-01  
**Author:** Shouheng Tuo  
**Compatibility:** MATLAB R2020a+

---

## Future Extensions

Potential additions (not included in v1.0):
- `examples/` - More example scripts
- `tests/` - Unit tests
- `benchmarks/` - Comparison with other algorithms
- `docs/` - Additional documentation
- `results/` - Sample results

---

**Last Updated:** 2025-01-22  
**Maintained By:** Shouheng Tuo
