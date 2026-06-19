import math

def x(z):
    return math.floor(0.5 * (3 + math.sqrt(8 * z  - 7))) - 1

def y(z):
    return int(z - 1 - 0.5 * x(z) * (x(z) - 1))

def clique(n):
    return [(x(z), y(z)) for z in range(1, int(0.5 * n * (n - 1) + 1))]