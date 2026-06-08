# Inverting Buck-Boost Converter — Discrete PCMC Design

A complete design of a discrete **inverting buck-boost DC-DC converter** 
operating under **Peak Current Mode Control (PCMC)**, from theoretical 
calculations through simulation and PCB layout.

## Purpose

The primary goal of this project is to develop a deep understanding of:
- How to derive and implement a **small-signal model** of a switching 
  converter in MATLAB using Christophe Basso's transfer function methodology
- How to design a **Type II compensator** using the SISO tool and verify 
  stability margins (phase margin, gain margin, crossover frequency)
- How to go from **math to real hardware** — translating theoretical models 
  into a working discrete PCB design

## Specifications

| Parameter | Value |
|-----------|-------|
| Input Voltage | 24V nominal (18V – 32V) |
| Output Voltage | -12V |
| Output Current | 3A |
| Switching Frequency | 300 kHz |
| Control | Peak Current Mode Control (PCMC) |
| Efficiency | 88% |

## Tools

- **MATLAB** — Small-signal modeling, Bode plots, compensator design
- **LTspice** — Circuit simulation with real manufacturer SPICE models
- **Altium Designer** — Schematic capture and PCB layout

## What's Covered

- Power stage design (inductor, MOSFET, diode, capacitors)
- Third-order Basso PCMC small-signal model including sampling effect
- Type II compensator design and stability verification
- Input EMI filter design with Middlebrook criterion verification
- Inrush current limiting circuit
- Full closed-loop LTspice simulation with load step transient
