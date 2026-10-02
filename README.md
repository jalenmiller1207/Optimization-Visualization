# Optimization Visualization Suite

## Overview

This project provides interactive visualizations of several common optimization algorithms used in scientific computing and machine learning. The goal is to demonstrate how different optimization strategies explore a search space and converge toward local or global optima.

The application allows users to observe algorithm behavior on two-dimensional and three-dimensional objective functions, compare convergence patterns, and examine the strengths and weaknesses of each optimization approach.

## Implemented Algorithms

### Particle Swarm Optimization (PSO)

Particle Swarm Optimization models a population of particles moving through a search space.

Each particle updates its position based on:

- Its current velocity
- The best position it has personally discovered
- The best position discovered by the swarm

A stochastic component encourages exploration while collective information sharing encourages convergence toward optimal regions.

### Gradient Ascent / Gradient Descent

Gradient methods use derivative information to move toward maxima or minima of a function.

- Gradient Ascent follows the direction of greatest increase.
- Gradient Descent follows the direction of greatest decrease.

These methods are efficient for smooth objective functions but may become trapped in local extrema.

### Hill Climbing

Hill Climbing is a local search algorithm that evaluates neighboring points and moves to the best available neighboring location.

The algorithm continues until no neighboring position provides improvement.

Hill Climbing is computationally simple but can become trapped in local optima.

### Simulated Annealing

Simulated Annealing introduces controlled randomness into the optimization process.

At high temperatures, less favorable moves may be accepted, allowing the algorithm to escape local optima. As the temperature decreases, the search gradually becomes more selective and converges toward promising regions of the search space.

This approach can often identify better solutions than purely local search methods.

## Features

- Interactive visualization of optimization paths
- Real-time animation of algorithm behavior
- 2D contour visualizations
- 3D objective function visualizations
- Adjustable algorithm parameters
- Side-by-side comparison of optimization strategies

## Concepts Demonstrated

- Scientific Computing
- Numerical Optimization
- Swarm Intelligence
- Stochastic Search
- Local Search
- Gradient-Based Methods
- Computational Visualization

## Example Outputs

### Particle Swarm Optimization

<img width="1592" height="946" alt="Screenshot 2026-10-02 at 12 05 40 AM" src="https://github.com/user-attachments/assets/693170b0-5e6c-4f04-af3c-752d0bf56c10" />


### Gradient Ascent / Gradient Descent

<img width="1592" height="946" alt="Screenshot 2026-10-02 at 12 11 10 AM" src="https://github.com/user-attachments/assets/a85a0a75-7ec0-4856-8059-c3342f2fe174" />

### Hill Climbing

<img width="1592" height="946" alt="Screenshot 2026-10-02 at 12 11 52 AM" src="https://github.com/user-attachments/assets/afc2d191-4f7d-40d9-8957-d483d8e0411e" />

### Simulated Annealing

<img width="1592" height="946" alt="Screenshot 2026-10-02 at 12 12 20 AM" src="https://github.com/user-attachments/assets/9c16dc8f-980f-45a6-8225-d8260cfb44bd" />


## Technologies

- MATLAB
- Numerical Optimization
- Interactive Scientific Visualization

## Educational Motivation

This project was developed to better understand how optimization algorithms behave on complex objective functions, particularly how exploration, exploitation, and convergence differ between deterministic and stochastic search strategies.
